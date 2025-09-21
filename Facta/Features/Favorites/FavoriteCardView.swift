import SwiftUI
import ComposableArchitecture

struct FavoriteCardView: View {
    let fact: Fact
    let isListMode: Bool
    
    var body: some View {
        if isListMode {
            // List mode: HStack layout
            HStack(alignment: .top, spacing: UI.Spacing.medium) {
                // Category Chip
                HStack(spacing: 4) {
                    Text(categoryEmoji(fact.category))
                        .font(.caption)
                    
                    Text(fact.category)
                        .font(.caption)
                        .foregroundColor(.mutedForeground)
                }
                .padding(.horizontal, UI.Padding.small)
                .padding(.vertical, 4)
                .background(Color.muted)
                .cornerRadius(50)
                
                // Content
                VStack(alignment: .leading, spacing: UI.Spacing.small) {
                    Text(fact.content)
                        .font(.body)
                        .foregroundColor(.adaptiveForeground)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)
                    
                    // Tags
                    if !fact.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: UI.Padding.small) {
                                ForEach(fact.tags, id: \.self) { tag in
                                    Text("\(tag.emoji) \(tag.label)")
                                        .font(.caption)
                                        .foregroundColor(.mutedForeground)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.muted)
                                            .cornerRadius(50)
                                }
                            }
                        }
                    }
                    
                    // Read time and premium badge
                    HStack {
                        if let readTime = fact.readTime {
                            Text("\(readTime)s")
                                .font(.caption)
                                .foregroundColor(.mutedForeground)
                        }
                        
                        if fact.isPremium {
                            Text("PREMIUM")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, UI.Padding.small)
                                .padding(.vertical, 2)
                                .background(LinearGradient(colors: [.primary, .secondary], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(50)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.muted.opacity(0.3))
            .cornerRadius(UI.corner)
        } else {
            // Grid mode: VStack layout
            VStack(alignment: .leading, spacing: UI.Spacing.small) {
                // Category Chip
                HStack {
                    Text(categoryEmoji(fact.category))
                        .font(.caption)
                    
                    Text(fact.category)
                        .font(.caption)
                        .foregroundColor(.mutedForeground)
                    
                    Spacer()
                }
                .padding(.horizontal, UI.Padding.small)
                .padding(.vertical, 4)
                .background(Color.muted)
                .cornerRadius(50)
                
                // Content
                Text(fact.content)
                    .font(.body)
                    .foregroundColor(.adaptiveForeground)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                // Tags
                if !fact.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: UI.Padding.small) {
                            ForEach(fact.tags, id: \.self) { tag in
                                Text("\(tag.emoji) \(tag.label)")
                                    .font(.caption)
                                    .foregroundColor(.mutedForeground)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.muted)
                                            .cornerRadius(50)
                            }
                        }
                    }
                }
                
                // Read time and premium badge
                HStack {
                    if let readTime = fact.readTime {
                        Text("\(readTime)s")
                            .font(.caption)
                            .foregroundColor(.mutedForeground)
                    }
                    
                    if fact.isPremium {
                        Text("PREMIUM")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, UI.Padding.small)
                            .padding(.vertical, 2)
                            .background(LinearGradient(colors: [.primary, .secondary], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(50)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.muted.opacity(0.3))
            .cornerRadius(UI.corner)
        }
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
