import SwiftUI
import ComposableArchitecture
import UIKit

struct FactCardView: View {
    let fact: Fact
    let isSaved: Bool
    let onSave: () -> Void
    let onShare: () -> Void
    let onNext: (() -> Void)?
    @State private var showingShare = false
    
    init(fact: Fact, isSaved: Bool = false, onSave: @escaping () -> Void, onShare: @escaping () -> Void, onNext: (() -> Void)? = nil) {
        self.fact = fact
        self.isSaved = isSaved
        self.onSave = onSave
        self.onShare = onShare
        self.onNext = onNext
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
            // Tags
            if !fact.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(fact.tags, id: \.label) { tag in
                        Text("\(tag.emoji) \(tag.label)")
                            .font(Typography.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.muted)
                            .cornerRadius(UI.corner)
                    }
                }
            }
            
            // Title
            Text(fact.title)
                .font(Typography.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Content preview
            Text(fact.content)
                .font(Typography.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Actions
            HStack {
                Button(action: onSave) {
                    Label("Spara", systemImage: isSaved ? "heart.fill" : "heart")
                }
                .buttonStyle(.plain)
                .foregroundColor(isSaved ? .red : .primary)
                
                Button(action: {
                    showingShare = true
                }) {
                    Label("Dela", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
                
                Spacer()
                
                if let onNext = onNext {
                    Button(action: onNext) {
                        HStack(spacing: 4) {
                            Text("Nästa")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(Typography.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.top, UI.Padding.small)
            .overlay(
                Rectangle()
                    .fill(Color.adaptiveSeparator)
                    .frame(height: 1),
                alignment: .top
            )
        }
        .padding(UI.Padding.medium)
        .background(cardBackground)
        .cornerRadius(UI.corner)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingShare) {
            ActivityView(activityItems: [
                "\(fact.title)\n\n\(fact.content)\n\nLadda ner Facta för mer fantastiska fakta! 📱"
            ])
        }
    }
    
    private var cardBackground: LinearGradient {
        if fact.isPremium {
            return LinearGradient(
                colors: [Color.primary.opacity(0.1), Color.accent.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - ActivityView
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
