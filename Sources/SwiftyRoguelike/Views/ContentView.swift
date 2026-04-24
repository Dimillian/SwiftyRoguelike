import SwiftUI

struct ContentView: View {
    let game: GameStore

    var body: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(alignment: .top, spacing: Layout.panelSpacing) {
                SidebarView(game: game)
                    .frame(width: Layout.sidebarWidth)

                VStack(spacing: 16) {
                    TopHUDView(game: game)
                    AsciiDungeonView(game: game)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    CommandBarView(game: game)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                InspectorView(game: game)
                    .frame(width: Layout.inspectorWidth)
            }
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.top, Layout.topPadding)
        .padding(.bottom, Layout.bottomPadding)
        .background(DungeonBackdrop())
        .onReceive(NotificationCenter.default.publisher(for: .dungeonDirectionKeyPressed), perform: handleDirectionKey)
        .toolbar {
            DungeonToolbar(game: game)
        }
    }

    private func handleDirectionKey(_ notification: Notification) {
        guard let direction = notification.object as? Direction else { return }
        game.perform(.move(direction))
    }
}

private enum Layout {
    static let sidebarWidth: CGFloat = 260
    static let inspectorWidth: CGFloat = 310
    static let panelSpacing: CGFloat = 16
    static let horizontalPadding: CGFloat = 20
    static let topPadding: CGFloat = 18
    static let bottomPadding: CGFloat = 20
}

private struct DungeonBackdrop: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(alignment: .top) {
                RadialGradient(
                    colors: [Color.cyan.opacity(0.16), .clear],
                    center: .top,
                    startRadius: 80,
                    endRadius: 760
                )
                .blendMode(.screen)
            }
            .overlay(alignment: .bottomLeading) {
                RadialGradient(
                    colors: [Color.green.opacity(0.08), .clear],
                    center: .bottomLeading,
                    startRadius: 40,
                    endRadius: 620
                )
                .blendMode(.screen)
            }
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.10), .black.opacity(0.28)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
    }
}

private struct DungeonToolbar: ToolbarContent {
    let game: GameStore

    var body: some ToolbarContent {
        ToolbarSpacer(.flexible, placement: .primaryAction)

        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                game.newRun()
            } label: {
                Label("New Run", systemImage: "sparkles")
            }

            Button {
                game.perform(.descend)
            } label: {
                Label("Descend", systemImage: "arrow.down.forward.and.arrow.up.backward")
            }
            .disabled(game.map[game.player.position] != .stairs)
        }
    }
}
