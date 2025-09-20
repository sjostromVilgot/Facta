import Foundation
import ComposableArchitecture

// MARK: - Seed Data
let seedFacts: [Fact] = [
    .init(id:"honung", title:"Honung förstörs aldrig",
          content:"Arkeologer har hittat krukor med honung från forntiden som fortfarande är ätbar.",
          category:"Matvetenskap",
          tags:[.init(emoji:"🍯",label:"Mat"), .init(emoji:"🏺",label:"Historia")],
          readTime:30, isPremium:true),
    .init(id:"bleckfisk-hjartan", title:"Bläckfiskar har tre hjärtan",
          content:"Två pumpar blod till gälarna och ett till resten av kroppen.",
          category:"Djur",
          tags:[.init(emoji:"🐙",label:"Djur")], readTime:20, isPremium:false),
    .init(id:"flamingo", title:"Flamingos färg kommer från maten",
          content:"De blir rosa av karotenoider i räkor och alger.",
          category:"Djur", tags:[.init(emoji:"🦩",label:"Djur"), .init(emoji:"🌊",label:"Natur")],
          readTime:20, isPremium:false),
    .init(id:"banan-berry", title:"Bananer är bär – jordgubbar är det inte",
          content:"Botaniskt är bananer bär medan jordgubbar inte är det.",
          category:"Botanik", tags:[.init(emoji:"🍌",label:"Växter")], readTime:20, isPremium:false),
    .init(id:"anglo-zanzibar", title:"Kortaste kriget varade ~40 minuter",
          content:"Anglo–Zanzibar-kriget 1896 tros vara det kortaste i historien.",
          category:"Historia", tags:[.init(emoji:"⚔️",label:"Historia")], readTime:25, isPremium:false),
    .init(id:"eiffel-summer", title:"Eiffeltornet blir högre på sommaren",
          content:"Värme gör metallen längre – upp till runt 15 cm skillnad.",
          category:"Vetenskap", tags:[.init(emoji:"🌡️",label:"Fysik")], readTime:20, isPremium:false),
    .init(id:"sharks-before-trees", title:"Hajar fanns före träden",
          content:"Hajar dök upp för ~450 miljoner år sedan; träd senare.",
          category:"Naturhistoria", tags:[.init(emoji:"🦈",label:"Paleontologi")], readTime:20, isPremium:false),
    .init(id:"olympus-mons", title:"Högsta vulkanen ligger på Mars",
          content:"Olympus Mons är ~22 km hög.",
          category:"Rymden", tags:[.init(emoji:"🪐",label:"Rymden")], readTime:20, isPremium:false),
    .init(id:"sound-water", title:"Ljud går snabbare i vatten än i luft",
          content:"Vatten leder ljud ~4x snabbare än luft.",
          category:"Fysik", tags:[.init(emoji:"🔊",label:"Akustik")], readTime:20, isPremium:false),
    .init(id:"nitrogen", title:"Jordens luft är mest kväve",
          content:"Cirka 78% kväve, 21% syre.",
          category:"Vetenskap", tags:[.init(emoji:"🌬️",label:"Atmosfär")], readTime:15, isPremium:false)
]

let seedTF: [QuizQuestion] = [
    .init(id:"tf1", mode:.trueFalse, question:"Bananer är tekniskt sett bär.", options:nil, correctIndex:nil, correctAnswer:true, explanation:"Botaniskt är bananer bär.", category:"Botanik"),
    .init(id:"tf2", mode:.trueFalse, question:"Kinesiska muren syns lätt med blotta ögat från rymden.", options:nil, correctIndex:nil, correctAnswer:false, explanation:"Det är en myt.", category:"Historia"),
    .init(id:"tf3", mode:.trueFalse, question:"Bläckfiskar har tre hjärtan.", options:nil, correctIndex:nil, correctAnswer:true, explanation:"Två till gälar, ett till kroppen.", category:"Djur"),
    .init(id:"tf4", mode:.trueFalse, question:"Eiffeltornet blir högre på vintern.", options:nil, correctIndex:nil, correctAnswer:false, explanation:"Det blir högre på sommaren p.g.a. värme.", category:"Fysik"),
    .init(id:"tf5", mode:.trueFalse, question:"Honung blir dålig efter några år.", options:nil, correctIndex:nil, correctAnswer:false, explanation:"Honung kan hålla i princip för evigt.", category:"Matvetenskap"),
    .init(id:"tf6", mode:.trueFalse, question:"Hajar fanns före träden.", options:nil, correctIndex:nil, correctAnswer:true, explanation:"Hajar är mycket äldre i fossilregistret.", category:"Naturhistoria"),
    .init(id:"tf7", mode:.trueFalse, question:"Ljud går snabbare i luft än i vatten.", options:nil, correctIndex:nil, correctAnswer:false, explanation:"Vatten leder ljud snabbare.", category:"Fysik"),
    .init(id:"tf8", mode:.trueFalse, question:"Olympus Mons ligger på Mars.", options:nil, correctIndex:nil, correctAnswer:true, explanation:"Det är solsystemets högsta vulkan.", category:"Rymden"),
    .init(id:"tf9", mode:.trueFalse, question:"Flamingos föds rosa.", options:nil, correctIndex:nil, correctAnswer:false, explanation:"De blir rosa av sin kost.", category:"Djur"),
    .init(id:"tf10", mode:.trueFalse, question:"Jordens luft består mest av syre.", options:nil, correctIndex:nil, correctAnswer:false, explanation:"Det mesta är kväve (~78%).", category:"Vetenskap")
]

let seedRecap: [QuizQuestion] = [
    .init(id:"r1", mode:.recap, question:"Vilken metall gör bläckfiskars blod blått?", options:["Järn","Koppar","Silver","Tenn"], correctIndex:1, correctAnswer:nil, explanation:"Hemocyanin använder koppar.", category:"Djur"),
    .init(id:"r2", mode:.recap, question:"Hur mycket högre kan Eiffeltornet bli på sommaren?", options:["~2 cm","~7 cm","~15 cm","~30 cm"], correctIndex:2, correctAnswer:nil, explanation:"Termisk expansion ger runt 15 cm.", category:"Fysik"),
    .init(id:"r3", mode:.recap, question:"Vad färgar flamingos rosa?", options:["Sol","Gener","Karotenoider","Mineraler"], correctIndex:2, correctAnswer:nil, explanation:"Karotenoider från räkor/alger.", category:"Djur"),
    .init(id:"r4", mode:.recap, question:"Vilket krig var kortast?", options:["Waterloo","Anglo–Zanzibar","Falklandskriget","Sexdagarskriget"], correctIndex:1, correctAnswer:nil, explanation:"Anglo–Zanzibar 1896 ~40 min.", category:"Historia"),
    .init(id:"r5", mode:.recap, question:"Vad är största andelen i luften?", options:["Syre","Kväve","Koldioxid","Argon"], correctIndex:1, correctAnswer:nil, explanation:"Kväve ~78%.", category:"Vetenskap"),
    .init(id:"r6", mode:.recap, question:"Var ligger Olympus Mons?", options:["Månen","Jorden","Mars","Venus"], correctIndex:2, correctAnswer:nil, explanation:"På Mars.", category:"Rymden")
]

// MARK: - LocalDataClient
struct LocalDataClient {
    var loadDailyFact: () -> Fact
    var loadDiscoveryFacts: () -> [Fact]
    var loadQuizQuestions: (QuizMode) -> [QuizQuestion]
}

extension LocalDataClient: DependencyKey {
    static let liveValue = LocalDataClient(
        loadDailyFact: {
            seedFacts.first!
        },
        loadDiscoveryFacts: {
            Array(seedFacts.dropFirst()).shuffled()
        },
        loadQuizQuestions: { mode in
            switch mode {
            case .trueFalse:
                return Array(seedTF.shuffled().prefix(10))
            case .recap:
                return Array(seedRecap.shuffled().prefix(5))
            }
        }
    )
}

extension DependencyValues {
    var localDataClient: LocalDataClient {
        get { self[LocalDataClient.self] }
        set { self[LocalDataClient.self] = newValue }
    }
}