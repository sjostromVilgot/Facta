import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<ProfileReducer>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    // Profile Section
                    Section("Profil") {
                        HStack {
                            Text("Namn")
                            Spacer()
                            TextField("Ditt namn", text: viewStore.binding(
                                get: \.settings.displayName,
                                send: ProfileAction.setDisplayName
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                        }
                        
                        NavigationLink(destination: AvatarSelectionView(store: store)) {
                            HStack {
                                Text("Avatar")
                                Spacer()
                                AvatarView(avatarData: viewStore.avatarData, displayName: viewStore.settings.displayName)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    
                    // Notifications Section
                    Section("Notiser") {
                        Toggle("Dagens fakta (09:00)", isOn: viewStore.binding(
                            get: \.settings.dailyFactNotifications,
                            send: ProfileAction.toggleDailyFact
                        ))
                        
                        Toggle("Quiz-påminnelse", isOn: viewStore.binding(
                            get: \.settings.quizReminders,
                            send: ProfileAction.toggleQuizReminder
                        ))
                    }
                    
                    // Appearance Section
                    Section("Utseende") {
                        Picker("Tema", selection: viewStore.binding(
                            get: \.settings.theme,
                            send: ProfileAction.setTheme
                        )) {
                            Text("Ljust").tag(ThemeChoice.light)
                            Text("Mörkt").tag(ThemeChoice.dark)
                            Text("System").tag(ThemeChoice.system)
                            Text("Mint").tag(ThemeChoice.mint)
                            Text("Ocean").tag(ThemeChoice.ocean)
                            Text("Sunset").tag(ThemeChoice.sunset)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Language Section
                    Section("Språk") {
                        Picker("Språk", selection: viewStore.binding(
                            get: \.settings.language,
                            send: ProfileAction.setLanguage
                        )) {
                            Text("Svenska").tag("sv")
                            Text("English").tag("en")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // About Section
                    Section("Om") {
                        Button(NSLocalizedString("Integritetspolicy", comment: "Privacy Policy button")) {
                            if let url = URL(string: "https://www.facta.app/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Button("Om Facta") {
                            // TODO: Show about sheet
                        }
                        .foregroundColor(.primary)
                    }
                    
                    // Footer
                    VStack(spacing: UI.Spacing.small) {
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Kontakta oss") {
                            if let url = URL(string: "mailto:support@facta.app") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                .navigationTitle("Inställningar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Stäng") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
