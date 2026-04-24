import SwiftUI

struct DungeonCommands: Commands {
    let game: GameStore

    var body: some Commands {
        CommandMenu("Dungeon") {
            Button("New Run") {
                game.newRun()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Divider()

            Button("Move North") {
                game.perform(.move(.north))
            }
            .keyboardShortcut("w", modifiers: [])

            Button("Move West") {
                game.perform(.move(.west))
            }
            .keyboardShortcut("a", modifiers: [])

            Button("Move South") {
                game.perform(.move(.south))
            }
            .keyboardShortcut("s", modifiers: [])

            Button("Move East") {
                game.perform(.move(.east))
            }
            .keyboardShortcut("d", modifiers: [])

            Button("Wait") {
                game.perform(.wait)
            }
            .keyboardShortcut(".", modifiers: [])

            Button("Rest") {
                game.perform(.rest)
            }
            .keyboardShortcut("r", modifiers: [])
        }
    }
}
