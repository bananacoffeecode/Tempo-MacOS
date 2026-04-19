import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) var viewModel

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            content
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.dismissSettings()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Account section
            sectionHeader("Account")

            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Google Calendar")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(viewModel.authManager.userEmail.isEmpty ? "—" : viewModel.authManager.userEmail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider().padding(.horizontal, 20)

            Button("Disconnect Calendar") {
                viewModel.signOut()
            }
            .foregroundStyle(.red)
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 6)
    }
}
