import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) var viewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .onboarding:
                OnboardingView()
            case .idle, .running:
                TimerView()
            case .review:
                ReviewView()
            case .settings:
                SettingsView()
            }
        }
        .frame(width: 320)
        .animation(.easeInOut(duration: 0.15), value: viewModel.state)
    }
}
