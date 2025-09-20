import SwiftUI
import ComposableArchitecture

struct FactCardView: View {
    let fact: Fact
    
    var body: some View {
        VStack {
            Text("Hello Fact Card!")
                .font(.title2)
                .padding()
            
            Text("This is a fact card for: \(fact.title)")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
