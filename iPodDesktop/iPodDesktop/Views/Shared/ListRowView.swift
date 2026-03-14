import SwiftUI

// MARK: - ListRowView

/// A single row in any iPod-style list, with an optional leading icon or
/// artwork, main label, optional sub-label and a chevron when selected.
struct ListRowView: View {
    let text: String
    var subText: String? = nil
    var isSelected: Bool = false
    var artwork: NSImage? = nil
    var showChevron: Bool = true

    var body: some View {
        ZStack {
            if isSelected { selectionBackground }

            HStack(spacing: 6) {
                if let img = artwork {
                    Image(nsImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(text)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : .primary)
                        .lineLimit(1)

                    if let sub = subText {
                        Text(sub)
                            .font(.system(size: 10))
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                if isSelected && showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(height: artwork != nil ? 36 : 28)
    }

    // MARK: - Selection gradient background

    @ViewBuilder
    private var selectionBackground: some View {
        VStack(spacing: 0) {
            Color(hex: 0xADDBF7)
                .frame(height: 1)
            LinearGradient(
                colors: [Color(hex: 0x70A9DB), Color(hex: 0x5382C9)],
                startPoint: .top,
                endPoint: .bottom
            )
            Color(hex: 0x2F4A81)
                .frame(height: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - EmptyStateView

/// Shown when a list has no content.
struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note.list")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            Text(message)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
