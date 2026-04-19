import Foundation
import SwiftUI

// MARK: - App State

enum AppState: Equatable {
    case onboarding(OnboardingStep)
    case idle
    case running
    case review
    case settings
}

enum OnboardingStep: Equatable {
    case email
    case auth
}

// MARK: - AppViewModel

@Observable
final class AppViewModel {

    // MARK: State

    var state: AppState = .onboarding(.email)
    var session         = Session()
    var elapsedSeconds  = 0
    var isLoggingEvent  = false
    var logError: String?
    var logSuccess      = false

    // MARK: Dependencies

    var authManager = AuthManager()
    private let calendarService = CalendarService()
    private var timerTask: Task<Void, Never>?

    // MARK: Init

    init() {
        authManager.loadStoredAuth()
        state = authManager.isAuthenticated ? .idle : .onboarding(.email)
    }

    // MARK: - Onboarding

    func advanceToAuthStep() {
        state = .onboarding(.auth)
    }

    func startGoogleAuth() async {
        await authManager.startOAuthFlow()
        if authManager.isAuthenticated {
            state = .idle
        }
    }

    // MARK: - Session Lifecycle

    func startSession() {
        session = Session(name: session.name, colorId: session.colorId, startTime: .now)
        elapsedSeconds = 0
        startTimer()
        state = .running
    }

    func stopSession() {
        session.endTime = .now
        stopTimer()
        state = .review
    }

    func discardSession() {
        stopTimer()
        elapsedSeconds = 0
        logError = nil
        state = .idle
    }

    func logSession() async {
        isLoggingEvent = true
        logError = nil
        defer { isLoggingEvent = false }

        do {
            let token = try await authManager.validAccessToken()
            let event = CalendarEvent(
                title:     session.name,
                startTime: session.startTime,
                endTime:   session.endTime,
                colorId:   session.colorId
            )
            _ = try await calendarService.createEvent(event, accessToken: token)
            logSuccess = true
            elapsedSeconds = 0
            state = .idle
        } catch {
            logError = error.localizedDescription
        }
    }

    /// Opens the review panel pre-filled with a 1-hour window ending now,
    /// for manually logging a past event without having run the timer.
    func openManualLog() {
        session = Session(
            name: "Work session",
            colorId: 7,
            startTime: Date(timeIntervalSinceNow: -3600)
        )
        session.endTime = .now
        logError = nil
        state = .review
    }

    // MARK: - Settings

    func showSettings() { state = .settings }
    func dismissSettings() { state = .idle }

    func signOut() {
        stopTimer()
        authManager.signOut()
        state = .onboarding(.email)
    }

    // MARK: - Timer

    var elapsedFormatted: String { elapsedSeconds.asElapsedTime }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                self.elapsedSeconds = Int(Date.now.timeIntervalSince(self.session.startTime))
                self.syncStatusBar()
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        clearStatusBar()
    }

    // MARK: - Menu Bar Title

    private func syncStatusBar() {
        guard let delegate = NSApp.delegate as? AppDelegate else { return }
        delegate.updateStatusTitle(elapsedFormatted)
    }

    private func clearStatusBar() {
        guard let delegate = NSApp.delegate as? AppDelegate else { return }
        delegate.clearStatusTitle()
    }
}
