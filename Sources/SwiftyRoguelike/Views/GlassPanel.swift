import SwiftUI

struct GlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var padding: CGFloat = 14
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            }
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.7)
    }
}

struct StatBar: View {
    let title: String
    let value: Int
    let maximum: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                    .font(.caption.weight(.bold))
                Spacer()
                Text("\(value)/\(maximum)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(value), total: Double(maximum))
                .tint(tint)
                .controlSize(.small)
        }
    }
}
