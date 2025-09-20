import SwiftUI
import ComposableArchitecture

struct NotificationSettingsView: View {
    let store: StoreOf<OnboardingReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: UI.Spacing.large) {
                Spacer()
                
                VStack(spacing: UI.Spacing.medium) {
                    Text("Notisinställningar")
                        .font(Typography.largeTitle)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Ställ in dina notifieringar för att få det bästa av Facta")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: UI.Spacing.medium) {
                    // Notification status
                    HStack {
                        Image(systemName: viewStore.notificationsEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewStore.notificationsEnabled ? .green : .red)
                        
                        Text("Notiser \(viewStore.notificationsEnabled ? "aktiverade" : "inaktiverade")")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                    
                    // Daily fact toggle
                    HStack {
                        VStack(alignment: .leading, spacing: UI.Spacing.small) {
                            Text("Dagens fakta 09:00")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Få en ny fascinerande fakta varje dag")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: viewStore.binding(
                            get: \.dailyFactEnabled,
                            send: OnboardingAction.toggleDailyFact
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .primary))
                    }
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                }
                
                Spacer()
                
                Button("Börja utforska fakta") {
                    viewStore.send(.finish)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, UI.Padding.large)
                
                Spacer()
            }
            .padding()
        }
    }
}
