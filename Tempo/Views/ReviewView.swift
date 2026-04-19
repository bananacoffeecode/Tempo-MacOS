import SwiftUI

struct ReviewView: View {
    @Environment(AppViewModel.self) var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            toolbar
            Divider()
            form
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            Text("Log session")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Form

    @MainActor
    private var form: some View {
        @Bindable var viewModel = viewModel

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                field(label: "Session name") {
                    TextField("What did you work on?", text: $viewModel.session.name)
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 16) {
                    field(label: "Start") {
                        TimePickerView(date: $viewModel.session.startTime)
                    }
                    field(label: "End") {
                        TimePickerView(date: $viewModel.session.endTime)
                    }
                }

                field(label: "Color") {
                    ColorPickerView(selectedColorId: $viewModel.session.colorId)
                }

                if let error = viewModel.logError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                VStack(spacing: 8) {
                    Button {
                        Task { await viewModel.logSession() }
                    } label: {
                        HStack(spacing: 8) {
                            if viewModel.isLoggingEvent {
                                ProgressView().controlSize(.small)
                            }
                            Text("Log to Calendar")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoggingEvent)

                    Button("Discard") {
                        viewModel.discardSession()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                }
            }
            .padding(24)
        }
    }

    @ViewBuilder
    private func field<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
    }
}
