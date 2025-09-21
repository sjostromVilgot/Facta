import SwiftUI
import ComposableArchitecture

struct AvatarSelectionView: View {
    let store: StoreOf<ProfileReducer>
    @Environment(\.dismiss) private var dismiss
    
    private let emojis = ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓", "🧐", "👶", "🧒", "👦", "👧", "🧑", "👨", "👩", "🧓", "👴", "👵", "👱", "👨‍🦰", "👩‍🦰", "👨‍🦱", "👩‍🦱", "👨‍🦳", "👩‍🦳", "👨‍🦲", "👩‍🦲", "🧔", "👨‍💼", "👩‍💼", "👨‍🔬", "👩‍🔬", "👨‍💻", "👩‍💻", "👨‍🎤", "👩‍🎤", "👨‍🎨", "👩‍🎨", "👨‍✈️", "👩‍✈️", "👨‍🚀", "👩‍🚀", "👨‍🚒", "👩‍🚒", "👮", "👮‍♂️", "👮‍♀️", "🕵️", "🕵️‍♂️", "🕵️‍♀️", "💂", "💂‍♂️", "💂‍♀️", "🥷", "👷", "👷‍♂️", "👷‍♀️", "🤴", "👸", "👳", "👳‍♂️", "👳‍♀️", "👲", "🧕", "🤵", "👰", "🤰", "🤱", "👼", "🎅", "🤶", "🦸", "🦸‍♂️", "🦸‍♀️", "🦹", "🦹‍♂️", "🦹‍♀️", "🧙", "🧙‍♂️", "🧙‍♀️", "🧚", "🧚‍♂️", "🧚‍♀️", "🧛", "🧛‍♂️", "🧛‍♀️", "🧜", "🧜‍♂️", "🧜‍♀️", "🧝", "🧝‍♂️", "🧝‍♀️", "🧞", "🧞‍♂️", "🧞‍♀️", "🧟", "🧟‍♂️", "🧟‍♀️", "💆", "💆‍♂️", "💆‍♀️", "💇", "💇‍♂️", "💇‍♀️", "🚶", "🚶‍♂️", "🚶‍♀️", "🧍", "🧍‍♂️", "🧍‍♀️", "🧎", "🧎‍♂️", "🧎‍♀️", "🏃", "🏃‍♂️", "🏃‍♀️", "💃", "🕺", "🕴", "👯", "👯‍♂️", "👯‍♀️", "🧖", "🧖‍♂️", "🧖‍♀️", "🧗", "🧗‍♂️", "🧗‍♀️", "🤺", "🏇", "⛷", "🏂", "🏌️", "🏌️‍♂️", "🏌️‍♀️", "🏄", "🏄‍♂️", "🏄‍♀️", "🚣", "🚣‍♂️", "🚣‍♀️", "🏊", "🏊‍♂️", "🏊‍♀️", "⛹️", "⛹️‍♂️", "⛹️‍♀️", "🏋️", "🏋️‍♂️", "🏋️‍♀️", "🚴", "🚴‍♂️", "🚴‍♀️", "🚵", "🚵‍♂️", "🚵‍♀️", "🤸", "🤸‍♂️", "🤸‍♀️", "🤼", "🤼‍♂️", "🤼‍♀️", "🤽", "🤽‍♂️", "🤽‍♀️", "🤾", "🤾‍♂️", "🤾‍♀️", "🤹", "🤹‍♂️", "🤹‍♀️", "🧘", "🧘‍♂️", "🧘‍♀️", "🛀", "🛌", "👭", "👫", "👬", "💏", "💑", "👪", "👨‍👩‍👧", "👨‍👩‍👧‍👦", "👨‍👩‍👦‍👦", "👨‍👩‍👧‍👧", "👨‍👨‍👦", "👨‍👨‍👧", "👨‍👨‍👧‍👦", "👨‍👨‍👦‍👦", "👨‍👨‍👧‍👧", "👩‍👩‍👦", "👩‍👩‍👧", "👩‍👩‍👧‍👦", "👩‍👩‍👦‍👦", "👩‍👩‍👧‍👧", "👨‍👦", "👨‍👦‍👦", "👨‍👧", "👨‍👧‍👦", "👨‍👧‍👧", "👩‍👦", "👩‍👦‍👦", "👩‍👧", "👩‍👧‍👦", "👩‍👧‍👧", "🗣", "👤", "👥", "🫂"]
    
    private let systemIcons = ["person.fill", "person.circle.fill", "person.2.fill", "person.3.fill", "star.fill", "heart.fill", "flame.fill", "bolt.fill", "leaf.fill", "drop.fill", "sun.max.fill", "moon.fill", "cloud.fill", "snow", "wind", "tornado", "hurricane", "thermometer", "gift.fill", "crown.fill", "diamond.fill", "sparkles", "star.circle.fill", "heart.circle.fill", "flame.circle.fill", "bolt.circle.fill", "leaf.circle.fill", "drop.circle.fill", "sun.max.circle.fill", "moon.circle.fill", "cloud.circle.fill", "snow.circle.fill", "wind.circle.fill", "tornado.circle.fill", "hurricane.circle.fill", "thermometer.circle.fill", "gift.circle.fill", "crown.circle.fill", "diamond.circle.fill", "sparkles.circle.fill"]
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                // Avatar Type Selection
                Section("Avatar-typ") {
                    Picker("Typ", selection: viewStore.binding(
                        get: \.settings.avatar,
                        send: { type in
                            let newAvatarData = AvatarData(
                                type: type,
                                emoji: type == .emoji ? viewStore.avatarData.emoji : nil,
                                systemIcon: type == .systemIcon ? viewStore.avatarData.systemIcon : nil,
                                initials: type == .initials ? viewStore.avatarData.initials : nil
                            )
                            return ProfileAction.setAvatar(newAvatarData)
                        }
                    )) {
                        ForEach(AvatarType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Avatar Content Selection
                if viewStore.settings.avatar == .initials {
                    Section("Initialer") {
                        TextField("Initialer", text: viewStore.binding(
                            get: { $0.avatarData.initials ?? String($0.settings.displayName.prefix(1)).uppercased() },
                            send: { initials in
                                let newAvatarData = AvatarData(
                                    type: .initials,
                                    emoji: nil,
                                    systemIcon: nil,
                                    initials: initials.isEmpty ? String(viewStore.settings.displayName.prefix(1)).uppercased() : initials
                                )
                                return ProfileAction.setAvatar(newAvatarData)
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } else if viewStore.settings.avatar == .emoji {
                    Section("Emoji") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button(action: {
                                    let newAvatarData = AvatarData(
                                        type: .emoji,
                                        emoji: emoji,
                                        systemIcon: nil,
                                        initials: nil
                                    )
                                    viewStore.send(.setAvatar(newAvatarData))
                                }) {
                                    Text(emoji)
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(viewStore.avatarData.emoji == emoji ? Color.blue.opacity(0.3) : Color.clear)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                } else if viewStore.settings.avatar == .systemIcon {
                    Section("Ikon") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                            ForEach(systemIcons, id: \.self) { icon in
                                Button(action: {
                                    let newAvatarData = AvatarData(
                                        type: .systemIcon,
                                        emoji: nil,
                                        systemIcon: icon,
                                        initials: nil
                                    )
                                    viewStore.send(.setAvatar(newAvatarData))
                                }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(viewStore.avatarData.systemIcon == icon ? Color.blue.opacity(0.3) : Color.muted)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                
                // Preview Section
                Section("Förhandsvisning") {
                    HStack {
                        Text("Din avatar:")
                        Spacer()
                        AvatarView(avatarData: viewStore.avatarData, displayName: viewStore.settings.displayName)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .navigationTitle("Välj Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
