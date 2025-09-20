import Foundation
import ComposableArchitecture

// MARK: - PersistenceClient
struct PersistenceClient {
    var loadFavorites: () -> [Fact]
    var saveFavorite: (Fact) -> Void
    var removeFavorite: (String) -> Void
    var loadReadFacts: () -> [String: Date]
    var markRead: (String) -> Void
    var loadQuizHistory: () -> [QuizResult]
    var saveQuizResult: (QuizResult) -> Void
}

extension PersistenceClient: DependencyKey {
    static let liveValue = PersistenceClient(
        loadFavorites: {
            guard let data = UserDefaults.standard.data(forKey: "favorites"),
                  let favorites = try? JSONDecoder().decode([Fact].self, from: data) else {
                return []
            }
            return favorites
        },
        saveFavorite: { fact in
            guard let data = UserDefaults.standard.data(forKey: "favorites"),
                  var favorites = try? JSONDecoder().decode([Fact].self, from: data) else {
                var newFavorites = [fact]
                if let data = try? JSONEncoder().encode(newFavorites) {
                    UserDefaults.standard.set(data, forKey: "favorites")
                }
                return
            }
            if !favorites.contains(where: { $0.id == fact.id }) {
                favorites.append(fact)
                if let data = try? JSONEncoder().encode(favorites) {
                    UserDefaults.standard.set(data, forKey: "favorites")
                }
            }
        },
        removeFavorite: { id in
            guard let data = UserDefaults.standard.data(forKey: "favorites"),
                  var favorites = try? JSONDecoder().decode([Fact].self, from: data) else {
                return
            }
            favorites.removeAll { $0.id == id }
            if let data = try? JSONEncoder().encode(favorites) {
                UserDefaults.standard.set(data, forKey: "favorites")
            }
        },
        loadReadFacts: {
            guard let data = UserDefaults.standard.data(forKey: "readFacts"),
                  let readFacts = try? JSONDecoder().decode([String: Date].self, from: data) else {
                return [:]
            }
            return readFacts
        },
        markRead: { id in
            guard let data = UserDefaults.standard.data(forKey: "readFacts"),
                  var readFacts = try? JSONDecoder().decode([String: Date].self, from: data) else {
                var newReadFacts = [id: Date()]
                if let data = try? JSONEncoder().encode(newReadFacts) {
                    UserDefaults.standard.set(data, forKey: "readFacts")
                }
                return
            }
            readFacts[id] = Date()
            if let data = try? JSONEncoder().encode(readFacts) {
                UserDefaults.standard.set(data, forKey: "readFacts")
            }
        },
        loadQuizHistory: {
            guard let data = UserDefaults.standard.data(forKey: "quizHistory"),
                  let history = try? JSONDecoder().decode([QuizResult].self, from: data) else {
                return []
            }
            return history
        },
        saveQuizResult: { result in
            guard let data = UserDefaults.standard.data(forKey: "quizHistory"),
                  var history = try? JSONDecoder().decode([QuizResult].self, from: data) else {
                var newHistory = [result]
                if let data = try? JSONEncoder().encode(newHistory) {
                    UserDefaults.standard.set(data, forKey: "quizHistory")
                }
                return
            }
            history.append(result)
            if let data = try? JSONEncoder().encode(history) {
                UserDefaults.standard.set(data, forKey: "quizHistory")
            }
        }
    )
    
    static let testValue = PersistenceClient(
        loadFavorites: { [] },
        saveFavorite: { _ in },
        removeFavorite: { _ in },
        loadReadFacts: { [:] },
        markRead: { _ in },
        loadQuizHistory: { [] },
        saveQuizResult: { _ in }
    )
}

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}