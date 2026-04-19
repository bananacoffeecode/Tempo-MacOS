import SwiftUI

struct TimerView: View {
    @Environment(AppViewModel.self) var viewModel

    private var isRunning: Bool { viewModel.state == .running }
    private var accentColor: Color {
        CalendarColor(rawValue: viewModel.session.colorId)?.color ?? .accentColor
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            toolbar
            Divider()
            mainContent
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            Text("Tempo")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            if !isRunning {
                Button {
                    viewModel.showSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Main Content

    @MainActor
    private var mainContent: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 24) {
            if isRunning {
                runningState
            } else {
                idleState
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Idle

    @MainActor
    private var idleState: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Ready to track")
                    .font(.headline)
                Text("What are you working on?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("Session name", text: $viewModel.session.name)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)

            ColorPickerView(selectedColorId: $viewModel.session.colorId)

            VStack(spacing: 8) {
                Button("Start Session") {
                    viewModel.startSession()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("Log a past event") {
                    viewModel.openManualLog()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
        }
    }

    // MARK: - Running

    private var runningState: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(viewModel.session.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(viewModel.elapsedFormatted)
                    .font(.system(size: 44, weight: .thin, design: .monospaced))
                    .foregroundStyle(accentColor)
                    .contentTransition(.numericText())
            }

            Button("Stop Session") {
                viewModel.stopSession()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .frame(maxWidth: .infinity)
        }
    }
}
