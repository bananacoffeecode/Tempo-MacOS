import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            header
            Divider()

            switch viewModel.state {
            case .onboarding(.email): emailStep
            case .onboarding(.auth):  authStep
            default: EmptyView()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Tempo")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Step 1: Email

    @MainActor
    private var emailStep: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Welcome to Tempo")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Track work sessions and log them directly to Google Calendar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Your email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("name@example.com", text: $viewModel.authManager.userEmail)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
            }

            Button("Continue") {
                viewModel.advanceToAuthStep()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.authManager.userEmail.trimmingCharacters(in: .whitespaces).isEmpty)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
    }

    // MARK: - Step 2: Google Auth

    private var authStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Connect Google Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Tempo needs permission to create events in your calendar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let error = viewModel.authManager.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }

            Button {
                Task { await viewModel.startGoogleAuth() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.authManager.isLoading {
                        ProgressView().controlSize(.small)
                    }
                    Text("Authorize with Google")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.authManager.isLoading)

            Button("Back") {
                viewModel.state = .onboarding(.email)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.footnote)
        }
        .padding(24)
    }
}
