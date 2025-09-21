import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: UI.Spacing.large) {
                    // Daily Fact Section
                    if let dailyFact = viewStore.dailyFact {
                        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                            HStack {
                                Text("✨ Dagens fakta")
                                    .font(Typography.headline)
                                    .foregroundColor(Color.adaptiveForeground)
                                
                                if dailyFact.isPremium {
                                    Text("PREMIUM")
                                        .font(Typography.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, UI.Padding.small)
                                        .padding(.vertical, 4)
                                        .background(
                                            LinearGradient(colors: [.primary, .secondary],
                                                           startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(50)
                                }
                                
                                Spacer()
                                
                                // Streak Indicator
                                StreakIndicatorView(streakDays: viewStore.streakDays)
                            }
                            
                            FactCardView(
                                fact: dailyFact,
                                isSaved: viewStore.favorites.contains(dailyFact.id),
                                onSave: {
                                    viewStore.send(.save(dailyFact))
                                },
                                onShare: {
                                    viewStore.send(.share(dailyFact))
                                }
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.easeInOut(duration: 0.5), value: dailyFact.id)
                            .onAppear {
                                viewStore.send(.markRead(dailyFact))
                            }
                        }
                    }
                    
                    // Discovery Section
                    if !viewStore.discovery.isEmpty {
                        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                            HStack {
                                Text("Upptäck mer")
                                    .font(Typography.headline)
                                    .foregroundColor(.adaptiveForeground)
                                
                                Spacer()
                                
                                Text("\(viewStore.index + 1) av \(viewStore.discovery.count)")
                                    .font(Typography.caption)
                                    .foregroundColor(.mutedForeground)
                                
                                Button("Blanda") {
                                    viewStore.send(.shuffle)
                                }
                                .font(Typography.caption)
                                .foregroundColor(.primary)
                            }
                            
                            // Discovery Card with Swipe and Animation
                            ZStack {
                                if viewStore.index < viewStore.discovery.count {
                                    ZStack {
                                        FactCardView(
                                            fact: viewStore.discovery[viewStore.index],
                                            isSaved: viewStore.favorites.contains(viewStore.discovery[viewStore.index].id),
                                            onSave: {
                                                viewStore.send(.save(viewStore.discovery[viewStore.index]))
                                            },
                                            onShare: {
                                                viewStore.send(.share(viewStore.discovery[viewStore.index]))
                                            },
                                            onNext: {
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    _ = viewStore.send(.next)
                                                }
                                            },
                                            dragOffset: dragOffset
                                        )
                                        .offset(x: dragOffset)
                                        .rotationEffect(.degrees(Double(dragOffset) * 0.03))
                                        .opacity(1 - min(abs(dragOffset) / 500.0, 0.3))
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                        .id(viewStore.index)
                                        
                                        // Swipe feedback overlays
                                        if dragOffset > 50 {
                                            Text("Spara")
                                                .font(Typography.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.green.opacity(0.8))
                                                .cornerRadius(20)
                                                .position(x: 280, y: 40)
                                        } else if dragOffset < -50 {
                                            Text("Nästa")
                                                .font(Typography.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.red.opacity(0.8))
                                                .cornerRadius(20)
                                                .position(x: 60, y: 40)
                                        }
                                    }
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                // Ignorera svep om gesten rört sig mycket vertikalt
                                                if abs(value.translation.height) > 50 {
                                                    return
                                                }
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
                                .font(Typography.caption)
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
                                .font(Typography.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Kontrollera din internetanslutning och försök igen")
                                .font(Typography.caption)
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
            .font(Typography.caption)
            .padding(.horizontal, UI.Padding.medium)
            .padding(.vertical, UI.Padding.small)
            .background(Color.muted)
            .cornerRadius(UI.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
