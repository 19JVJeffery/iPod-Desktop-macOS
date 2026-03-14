import SwiftUI

// MARK: - iPodListScreen

/// A generic full-screen scrollable list used by all menu / browse screens.
/// Rows are rendered with `ListRowView` and the selection highlight tracks
/// `AppState.selectedIndex`.
struct iPodListScreen<Item: Identifiable>: View {

    let title:  String
    let items:  [Item]
    let label:  (Item) -> String
    var subLabel: ((Item) -> String?)? = nil
    var artwork:  ((Item) -> NSImage?)? = nil

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var player:   PlayerEngine

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: title,
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            if items.isEmpty {
                EmptyStateView(message: "No items found")
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                ListRowView(
                                    text: label(item),
                                    subText: subLabel?(item),
                                    isSelected: appState.selectedIndex == index,
                                    artwork: artwork?(item),
                                    showChevron: true
                                )
                                .id(index)
                                .onTapGesture {
                                    appState.selectedIndex = index
                                }
                                .background(rowBackground(index: index))

                                if index < items.count - 1 {
                                    Divider().padding(.leading, artwork != nil ? 42 : 8)
                                }
                            }
                        }
                    }
                    .onChange(of: appState.selectedIndex) { newIndex in
                        withAnimation { proxy.scrollTo(newIndex, anchor: .center) }
                    }
                }
            }
        }
        .background(screenBackground)
    }

    @ViewBuilder
    private func rowBackground(index: Int) -> some View {
        if index % 2 == 0 {
            Color(hex: appState.appTheme == .dark ? 0x1C1C1E : 0xFFFFFF).opacity(0.0)
        } else {
            Color(hex: appState.appTheme == .dark ? 0x2C2C2E : 0xF5F5F5).opacity(0.25)
        }
    }

    private var screenBackground: Color {
        appState.appTheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xDDE5ED)
    }
}
