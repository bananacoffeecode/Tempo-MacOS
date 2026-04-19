import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColorId: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CalendarColor.allCases) { calColor in
                    swatch(for: calColor)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func swatch(for calColor: CalendarColor) -> some View {
        let selected = selectedColorId == calColor.id

        return Button {
            selectedColorId = calColor.id
        } label: {
            ZStack {
                Circle()
                    .fill(calColor.color)
                    .frame(width: 26, height: 26)

                if selected {
                    Circle()
                        .strokeBorder(.white.opacity(0.7), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .help(calColor.label)
    }
}
