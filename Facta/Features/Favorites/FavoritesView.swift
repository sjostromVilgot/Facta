import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesReducer>
    
    private let categories = ["Alla", "Djur", "Rymden", "Mat", "Historia", "Vetenskap", "Naturhistoria", "Botanik", "Fysik", "Matvetenskap"]
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Favoriter")
                            .font(.largeTitle)
                            .foregroundColor(.adaptiveForeground)
                    }
                    
                    Spacer()
                    
                    Text("\(viewStore.items.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, UI.Padding.medium)
                        .padding(.vertical, UI.Padding.small)
                        .background(Color.primary)
                        .cornerRadius(UI.corner)
                    
                    // View Mode Toggle
                    HStack(spacing: 0) {
                        Button(action: {
                            viewStore.send(.setViewMode(.grid))
                        }) {
                            Image(systemName: "square.grid.2x2")
                                .font(.headline)
                                .foregroundColor(viewStore.viewMode == .grid ? .white : .primary)
                                .padding(.horizontal, UI.Padding.medium)
                                .padding(.vertical, UI.Padding.small)
                                .background(viewStore.viewMode == .grid ? Color.primary : Color.muted)
                                .cornerRadius(UI.corner, corners: [.topLeft, .bottomLeft])
                        }
                        
                        Button(action: {
                            viewStore.send(.setViewMode(.list))
                        }) {
                            Image(systemName: "list.bullet")
                                .font(.headline)
                                .foregroundColor(viewStore.viewMode == .list ? .white : .primary)
                                .padding(.horizontal, UI.Padding.medium)
                                .padding(.vertical, UI.Padding.small)
                                .background(viewStore.viewMode == .list ? Color.primary : Color.muted)
                                .cornerRadius(UI.corner, corners: [.topRight, .bottomRight])
                        }
                    }
                }
                .padding()
                
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mutedForeground)
                    
                    TextField("Sök i favoriter...", text: viewStore.binding(
                        get: \.query,
                        send: FavoritesAction.setQuery
                    ))
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.adaptiveForeground)
                    
                    if !viewStore.query.isEmpty {
                        Button(action: {
                            viewStore.send(.setQuery(""))
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.mutedForeground)
                        }
                    }
                }
                .padding()
                .background(Color.muted)
                .cornerRadius(UI.corner)
                .padding(.horizontal)
                
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UI.Padding.small) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                viewStore.send(.setCategory(category))
                            }) {
                                Text(categoryEmoji(category) + " " + category)
                                    .font(.caption)
                                    .foregroundColor(viewStore.category == category ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewStore.category == category ? Color.primary : Color.muted)
                                    .cornerRadius(50)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, UI.Padding.small)
                
                // Content
                if filteredItems.isEmpty {
                    // Empty State
                    VStack(spacing: UI.Spacing.large) {
                        Spacer()
                        
                        Image(systemName: "lightbulb")
                            .font(.system(size: 60))
                            .foregroundColor(.mutedForeground)
                        
                        Text("Ännu inga favoriter")
                            .font(.headline)
                            .foregroundColor(.adaptiveForeground)
                        
                        VStack(spacing: UI.Spacing.small) {
                            Text("Sparade fakta fungerar offline")
                                .font(.caption)
                                .foregroundColor(.mutedForeground)
                            
                            Text("Tryck på hjärtat för att spara fakta")
                                .font(.caption)
                                .foregroundColor(.mutedForeground)
                        }
                        .padding()
                        .background(Color.muted)
                        .cornerRadius(UI.corner)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // Items List/Grid
                    if viewStore.viewMode == .grid {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: UI.Spacing.medium) {
                            ForEach(filteredItems, id: \.id) { fact in
                                FavoriteCardView(fact: fact, isListMode: false)
                                    .contextMenu {
                                        Button("Dela") {
                                            viewStore.send(.share(fact))
                                        }
                                        
                                        Button("Ta bort från favoriter") {
                                            viewStore.send(.remove(fact.id))
                                        }
                                    }
                            }
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: UI.Spacing.medium) {
                            ForEach(filteredItems, id: \.id) { fact in
                                FavoriteCardView(fact: fact, isListMode: true)
                                    .contextMenu {
                                        Button("Dela") {
                                            viewStore.send(.share(fact))
                                        }
                                        
                                        Button("Ta bort från favoriter") {
                                            viewStore.send(.remove(fact.id))
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                // Footer Stats
                if !viewStore.items.isEmpty {
                    VStack(spacing: UI.Spacing.small) {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Totalt sparade")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewStore.items.count)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 4) {
                                Text("Kategorier")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(uniqueCategories.count)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Snitt ord")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(averageWordCount)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                    }
                    .background(Color.muted.opacity(0.5))
                }
            }
            .onAppear {
                viewStore.send(.reload)
            }
        }
    }
    
    private var filteredItems: [Fact] {
        let items = store.withState { $0.items }
        let query = store.withState { $0.query }
        let category = store.withState { $0.category }
        
        return items.filter { fact in
            let matchesQuery = query.isEmpty || fact.content.localizedCaseInsensitiveContains(query)
            let matchesCategory = category == "Alla" || fact.category == category
            return matchesQuery && matchesCategory
        }
    }
    
    private var uniqueCategories: [String] {
        let items = store.withState { $0.items }
        return Array(Set(items.map(\.category))).sorted()
    }
    
    private var averageWordCount: Int {
        let items = store.withState { $0.items }
        guard !items.isEmpty else { return 0 }
        
        let totalWords = items.reduce(0) { total, fact in
            total + fact.content.split(separator: " ").count
        }
        
        return totalWords / items.count
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
