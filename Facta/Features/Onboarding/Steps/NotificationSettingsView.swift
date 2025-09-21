import SwiftUI
import ComposableArchitecture

struct NotificationSettingsView: View {
    let store: StoreOf<OnboardingReducer>
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            VStack(spacing: UI.Spacing.large) {
                Spacer()
                
                VStack(spacing: UI.Spacing.medium) {
                    Text("Notisinställningar")
                        .font(Typography.largeTitle)
                        .foregroundColor(.adaptiveForeground)
                        .multilineTextAlignment(.center)
                    
                    Text("Ställ in dina notifieringar för att få det bästa av Facta")
                        .font(Typography.body)
                        .foregroundColor(.mutedForeground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: UI.Spacing.medium) {
                    // Notification status
                    HStack {
                        Image(systemName: viewStore.notificationsEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewStore.notificationsEnabled ? .green : .red)
                        
                        Text("Notiser \(viewStore.notificationsEnabled ? "aktiverade" : "inaktiverade")")
                            .font(Typography.headline)
                            .foregroundColor(.adaptiveForeground)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                    
                    // Daily fact toggle
                    HStack {
                        VStack(alignment: .leading, spacing: UI.Spacing.small) {
                            Text("Daglig fakta")
                                .font(Typography.headline)
                                .foregroundColor(.adaptiveForeground)
                            
                            Text("Få en ny fascinerande fakta varje dag kl 09:00")
                                .font(Typography.caption)
                                .foregroundColor(.mutedForeground)
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
                    
                    // Quiz reminder toggle
                    HStack {
                        VStack(alignment: .leading, spacing: UI.Spacing.small) {
                            Text("Quiz-påminnelse")
                                .font(Typography.headline)
                                .foregroundColor(.adaptiveForeground)
                            
                            Text("Få påminnelser om att spela quiz för att utveckla dina kunskaper")
                                .font(Typography.caption)
                                .foregroundColor(.mutedForeground)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: viewStore.binding(
                            get: \.quizReminderEnabled,
                            send: OnboardingAction.toggleQuizReminder
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .primary))
                    }
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                }
                
                Spacer()
                
                Button("Börja utforska fakta") {
                    Task {
                        withAnimation(.spring()) {
                            viewStore.send(.finish)
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, UI.Padding.large)
                
                Spacer()
            }
            .padding()
        }
    }
}
