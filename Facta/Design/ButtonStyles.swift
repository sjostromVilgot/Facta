import SwiftUI

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.button)
            .foregroundColor(.white)
            .padding(.horizontal, UI.Padding.large)
            .padding(.vertical, UI.Padding.medium)
            .background(Color.primary)
            .cornerRadius(UI.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.button)
            .foregroundColor(.primary)
            .padding(.horizontal, UI.Padding.large)
            .padding(.vertical, UI.Padding.medium)
            .background(Color.muted)
            .cornerRadius(UI.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.button)
            .foregroundColor(.primary)
            .padding(.horizontal, UI.Padding.large)
            .padding(.vertical, UI.Padding.medium)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: UI.corner)
                    .stroke(Color.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
