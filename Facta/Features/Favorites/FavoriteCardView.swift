import SwiftUI
import ComposableArchitecture

struct FavoriteCardView: View {
    let fact: Fact
    let isListMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.small) {
            // Category Chip
            HStack {
                Text(categoryEmoji(fact.category))
                    .font(.caption)
                
                Text(fact.category)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, UI.Padding.small)
            .padding(.vertical, 4)
            .background(Color.muted)
            .cornerRadius(UI.corner)
            
            // Content
            Text(fact.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(isListMode ? 2 : nil)
                .multilineTextAlignment(.leading)
            
            // Tags
            if !fact.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UI.Padding.small) {
                        ForEach(fact.tags, id: \.self) { tag in
                            Text("\(tag.emoji) \(tag.label)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, UI.Padding.small)
                                .padding(.vertical, 2)
                                .background(Color.muted)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Read time and premium badge
            HStack {
                if let readTime = fact.readTime {
                    Text("\(readTime)s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if fact.isPremium {
                    Text("PREMIUM")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, UI.Padding.small)
                        .padding(.vertical, 2)
                        .background(Color.accent)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.muted.opacity(0.3))
        .cornerRadius(UI.corner)
    }
    
    private func categoryEmoji(_ category: String) -> String {
        switch category {
        case "Djur": return "🐾"
        case "Rymden": return "🪐"
        case "Mat": return "🍽️"
        case "Historia": return "📜"
        case "Vetenskap": return "🔬"
        case "Naturhistoria": return "🌿"
        case "Botanik": return "🌱"
        case "Fysik": return "⚡"
        case "Matvetenskap": return "🧪"
        default: return "📚"
        }
    }
}
