import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeReducer>
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            ScrollView {
                VStack(spacing: UI.Spacing.large) {
                    // Daily Fact Section
                    if let dailyFact = viewStore.dailyFact {
                        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                            HStack {
                                Text("✨ Dagens fakta")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if dailyFact.isPremium {
                                    Text("PREMIUM")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, UI.Padding.small)
                                        .padding(.vertical, 4)
                                        .background(Color.accent)
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                            }
                            
                            FactCardView(fact: dailyFact)
                                .onAppear {
                                    viewStore.send(.markRead(dailyFact))
                                }
                            
                            HStack(spacing: UI.Spacing.medium) {
                                Button(action: {
                                    viewStore.send(.save(dailyFact))
                                }) {
                                    HStack {
                                        Image(systemName: viewStore.favorites.contains(dailyFact.id) ? "heart.fill" : "heart")
                                        Text("Spara")
                                    }
                                    .foregroundColor(viewStore.favorites.contains(dailyFact.id) ? .red : .primary)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Button(action: {
                                    viewStore.send(.share(dailyFact))
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Dela")
                                    }
                                    .foregroundColor(.primary)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Discovery Section
                    if !viewStore.discovery.isEmpty {
                        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                            HStack {
                                Text("Upptäck mer")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(viewStore.index + 1) av \(viewStore.discovery.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Blanda") {
                                    viewStore.send(.shuffle)
                                }
                                .font(.caption)
                                .foregroundColor(.primary)
                            }
                            
                            // Discovery Card with Swipe
                            ZStack {
                                if viewStore.index < viewStore.discovery.count {
                                    FactCardView(fact: viewStore.discovery[viewStore.index])
                                        .offset(x: dragOffset)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    dragOffset = value.translation.width
                                                }
                                                .onEnded { value in
                                                    withAnimation(.spring()) {
                                                        if value.translation.width > 120 {
                                                            // Swipe right - save and next
                                                            viewStore.send(.save(viewStore.discovery[viewStore.index]))
                                                            viewStore.send(.next)
                                                        } else if value.translation.width < -120 {
                                                            // Swipe left - next
                                                            viewStore.send(.next)
                                                        }
                                                        dragOffset = 0
                                                    }
                                                }
                                        )
                                }
                            }
                            .frame(height: 200)
                            
                            // Progress Indicator
                            HStack(spacing: 4) {
                                ForEach(0..<min(5, viewStore.discovery.count), id: \.self) { index in
                                    Circle()
                                        .fill(index <= viewStore.index ? Color.primary : Color.muted)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                    
                    // Loading State
                    if viewStore.isLoading {
                        VStack {
                            ProgressView()
                            Text("Laddar fakta...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Empty State
                    if viewStore.discovery.isEmpty && !viewStore.isLoading {
                        VStack(spacing: UI.Spacing.medium) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 50))
                                .foregroundColor(.muted)
                            
                            Text("Inga fakta tillgängliga")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Kontrollera din internetanslutning och försök igen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, UI.Padding.medium)
            .padding(.vertical, UI.Padding.small)
            .background(Color.muted)
            .cornerRadius(UI.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
