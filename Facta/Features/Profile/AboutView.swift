import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Title
                    VStack(spacing: 16) {
                        // App Icon Placeholder
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.primary, .secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("F")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text(NSLocalizedString("Om Facta", comment: "About Facta title"))
                            .font(Typography.largeTitle)
                            .foregroundColor(.adaptiveForeground)
                        
                        Text("\(NSLocalizedString("Version", comment: "Version")) 1.0.0")
                            .font(Typography.caption)
                            .foregroundColor(.mutedForeground)
                    }
                    .padding(.top, 20)
                    
                    // App Description
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("Fascinerande fakta varje dag", comment: "App tagline"))
                            .font(Typography.title2)
                            .foregroundColor(.adaptiveForeground)
                            .multilineTextAlignment(.center)
                        
                        Text(NSLocalizedString("Facta är en app som ger dig fascinerande fakta varje dag och roliga quiz för att testa dina kunskaper. Appen är skapad för att göra lärande underhållande och lättillgängligt.", comment: "App description"))
                            .font(Typography.body)
                            .foregroundColor(.adaptiveForeground)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    // Features
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("Funktioner", comment: "Features section"))
                            .font(Typography.headline)
                            .foregroundColor(.adaptiveForeground)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "sparkles",
                                title: NSLocalizedString("Dagliga fakta", comment: "Daily facts feature"),
                                description: NSLocalizedString("Få en ny fascinerande fakta varje dag", comment: "Daily facts description")
                            )
                            
                            FeatureRow(
                                icon: "questionmark.circle",
                                title: NSLocalizedString("Quiz", comment: "Quiz feature"),
                                description: NSLocalizedString("Testa dina kunskaper med snabba frågor", comment: "Quiz description")
                            )
                            
                            FeatureRow(
                                icon: "heart",
                                title: NSLocalizedString("Favoriter", comment: "Favorites feature"),
                                description: NSLocalizedString("Spara dina favoritfakta för senare", comment: "Favorites description")
                            )
                            
                            FeatureRow(
                                icon: "trophy",
                                title: NSLocalizedString("Badges", comment: "Badges feature"),
                                description: NSLocalizedString("Samla poäng och lås upp nya nivåer", comment: "Badges description")
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Mission Statement
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("Vårt uppdrag", comment: "Our mission section"))
                            .font(Typography.headline)
                            .foregroundColor(.adaptiveForeground)
                        
                        Text(NSLocalizedString("Vi tror att kunskap ska vara tillgänglig, underhållande och lätt att dela. Genom att kombinera fascinerande fakta med interaktiva quiz skapar vi en plattform där lärande känns som lek.", comment: "Mission statement"))
                            .font(Typography.body)
                            .foregroundColor(.adaptiveForeground)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle(NSLocalizedString("Om Facta", comment: "About Facta title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Stäng", comment: "Close button")) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(.adaptiveForeground)
                
                Text(description)
                    .font(Typography.caption)
                    .foregroundColor(.mutedForeground)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AboutView()
}
