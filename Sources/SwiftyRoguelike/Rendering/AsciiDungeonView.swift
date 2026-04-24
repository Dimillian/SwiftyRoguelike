import SwiftUI

struct AsciiDungeonView: View {
    let game: GameStore
    private let viewportWidth = 48
    private let viewportHeight = 28

    var body: some View {
        GeometryReader { proxy in
            let gridSize = fittedGridSize(in: proxy.size)
            let origin = CGPoint(
                x: (proxy.size.width - gridSize.width) / 2,
                y: (proxy.size.height - gridSize.height) / 2
            )
            let viewport = viewportOrigin()
            let cell = gridSize.width / CGFloat(viewportWidth)
            let fontSize = max(8, floor(cell * 0.90))

            Canvas { context, _ in
                let terminalRect = CGRect(origin: origin, size: gridSize)
                context.fill(
                    Path(roundedRect: terminalRect, cornerRadius: 18),
                    with: .color(Color.black.opacity(0.76))
                )

                for row in 0..<viewportHeight {
                    for column in 0..<viewportWidth {
                        let point = GridPoint(x: viewport.x + column, y: viewport.y + row)
                        let discovered = game.map.discovered.contains(point)
                        let rect = CGRect(
                            x: origin.x + CGFloat(column) * cell,
                            y: origin.y + CGFloat(row) * cell,
                            width: cell,
                            height: cell
                        )

                        if game.map.contains(point), discovered {
                            context.fill(Path(rect), with: .color(cellBackground(for: point)))
                            let glyph = game.glyph(at: point)
                            let text = Text(glyph.character)
                                .font(.system(size: fontSize, weight: glyph.isBright ? .semibold : .regular, design: .monospaced))
                                .foregroundStyle(glyph.color.color)
                            context.draw(text, at: CGPoint(x: rect.midX, y: rect.midY), anchor: .center)
                        }
                    }
                }
            }
            .accessibilityLabel("ASCII dungeon map")
        }
        .aspectRatio(CGFloat(viewportWidth) / CGFloat(viewportHeight), contentMode: .fit)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.54))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.36), radius: 20, y: 14)
        }
        .overlay(alignment: .topLeading) {
            HStack(spacing: 8) {
                Image(systemName: "terminal")
                Text("SwiftUI ASCII Engine")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.thinMaterial, in: Capsule())
            .padding(16)
        }
    }

    private func viewportOrigin() -> GridPoint {
        return GridPoint(
            x: game.player.position.x - viewportWidth / 2,
            y: game.player.position.y - viewportHeight / 2
        )
    }

    private func fittedGridSize(in size: CGSize) -> CGSize {
        let aspect = CGFloat(viewportWidth) / CGFloat(viewportHeight)
        var width = size.width
        var height = width / aspect
        if height > size.height {
            height = size.height
            width = height * aspect
        }
        return CGSize(width: floor(width), height: floor(height))
    }

    private func cellBackground(for point: GridPoint) -> Color {
        switch game.map[point] {
        case .water:
            return Color.cyan.opacity(0.12)
        case .foliage:
            return Color.green.opacity(0.08)
        case .stairs:
            return Color.purple.opacity(0.12)
        default:
            return Color.black.opacity(0.02)
        }
    }
}
