import SwiftUI
import ComposableArchitecture

struct BadgesGridView: View {
    let badges: [Badge]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: UI.Spacing.small) {
            ForEach(badges, id: \.id) { badge in
                BadgeView(badge: badge)
            }
        }
    }
}

struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: UI.Spacing.small) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? badge.color.swiftUIColor.opacity(0.2) : Color.muted)
                    .frame(width: 50, height: 50)
                
                // Badge icon - always visible but grayed out if locked
                Text(badge.icon)
                    .font(.title2)
                    .foregroundColor(badge.isUnlocked ? badge.color.swiftUIColor : .gray)
                    .opacity(badge.isUnlocked ? 1.0 : 0.3)
                
                // Lock icon for locked badges
                if !badge.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .position(x: 40, y: 10)
                }
            }
            
            Text(badge.name)
                .font(.caption)
                .foregroundColor(badge.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, UI.Padding.small)
    }
}
