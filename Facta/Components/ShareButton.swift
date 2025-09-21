import SwiftUI
import UIKit

struct ShareButton: View {
    let shareText: String
    @State private var showingShareSheet = false
    
    var body: some View {
        Button(action: {
            showingShareSheet = true
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Dela resultat")
            }
        }
        .buttonStyle(SecondaryButtonStyle())
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(shareText: shareText)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let shareText: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
