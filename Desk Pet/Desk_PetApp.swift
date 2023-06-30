//
//  Desk_PetApp.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/24/23.
//

import SwiftUI
import ComposableArchitecture

struct Grave: Equatable, Codable {
    var id = UUID()
    var position: CGFloat = CGFloat.random(in: -120...120)
}


struct Pet: Equatable, Codable {
    var timeLastFed: Date = Date()
    var isAlive: Bool = true
}

struct Poop: Equatable, Codable {
    var id = UUID()
    var position: CGFloat = CGFloat.random(in: -150...150)
    var createdAt: Date = Date()
    var isCleared: Bool = false
}

struct DeskPet: ReducerProtocol {
    var fm: FileManager
    init() {
        fm = FileManager()
    }
    
    struct State: Equatable {
        var pet: Pet
        var graves: [Grave]
        var poops: [Poop]
        var feedingAnimation: Bool = false
        
        init() {
            // get pet from storage
            let fm = FileManager()
            let fromStorage = fm.getFromStorage(storagePaths: ["pet", "graves", "poops"])
            var petFromStorage = fromStorage.pet ?? Pet()
            var gravesFromStorage = fromStorage.graves ?? []
            var poopsFromStorage = fromStorage.poops ?? []
            
            if(!checkPetIsAlive(timeLastFed: petFromStorage.timeLastFed)){
                // it's a sad day 😭
                petFromStorage.isAlive = false
                gravesFromStorage.append(Grave())
            }
            
            // determine how many poops the pet has made while gone
            let numNewPoops = getNumberOfNewPoops(timeLastFed: petFromStorage.timeLastFed, existingPoops: poopsFromStorage)
            if(numNewPoops > 0) {
                for _ in 0..<numNewPoops {
                    poopsFromStorage.append(Poop())
                }
            }
            
            
            // set the state
            self.pet = petFromStorage
            self.graves = gravesFromStorage
            self.poops = poopsFromStorage
            
            // update saved storage
            fm.updatePetInStorage(pet: self.pet)
            fm.updateGravesInStorage(graves: self.graves)
            fm.updatePoopsInStorage(poops: self.poops)
        }
        
    }
    enum Action: Equatable {
        case feedPet
        case endAnimation
        case addPoop(CGFloat)
        case clearPoop(UUID)
        case poopClicked(UUID)
      }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .feedPet:
            state.pet.timeLastFed = Date()
            fm.updatePetInStorage(pet: state.pet)
            
            state.feedingAnimation = true
            return .none
            
        case .endAnimation:
            state.feedingAnimation = false
            return .none
            
        case let .addPoop(position):
            state.poops.append(Poop(position: position))
            return .none
        
        case let .clearPoop(id):
            if let i = state.poops.firstIndex(where: {$0.id == id}) {
                state.poops[i].isCleared = true
            }
            return.none
            
        case let .poopClicked(id):
            return .run { [poops = state.poops] send in
                var filteredPoops = poops
                if let i = filteredPoops.firstIndex(where: {$0.id == id}) {
                    filteredPoops[i].isCleared = true
                }
                fm.updatePoopsInStorage(poops: filteredPoops)
                await send(.clearPoop(id))
            }
        }
    }
}

@main
struct Desk_PetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: DeskPet.State()) {
                DeskPet()
              })
        }.windowResizabilityContentSize()
    }
}


extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}

struct FileStorageReturnType {
    var pet: Pet?
    var graves: [Grave]?
    var poops: [Poop]?
}
enum FileStorageOptions {
    case pet(Pet)
    case graves([Grave])
    case poops([Poop])
}



extension FileManager {
    private func getFileStorageUrl(path: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("deskPet/\(path)")
    }
    
    func getFromStorage(storagePaths: [String]?) -> FileStorageReturnType {
        var fileStorageReturn = FileStorageReturnType()
        
        let jsonDecoder = JSONDecoder()
        for storagePath in storagePaths!{
            let fileStorageUrl = self.getFileStorageUrl(path: storagePath)
            do {
                let json = try Data(contentsOf: fileStorageUrl)
                switch storagePath {
                case "pet":
                    let decoded = try jsonDecoder.decode(Pet.self, from: json)
                    fileStorageReturn.pet = decoded
                case "graves":
                        let decoded = try jsonDecoder.decode([Grave].self, from: json)
                        fileStorageReturn.graves = decoded
                case "poops":
                    let decoded = try jsonDecoder.decode([Poop].self, from: json)
                    fileStorageReturn.poops = decoded
                default:
                    print("\(storagePath) is not a valid path option")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return fileStorageReturn
    }
    
    func updatePetInStorage(pet: Pet) -> Void {
        let jsonEncoder = JSONEncoder()
        let fileStorageUrl = self.getFileStorageUrl(path: "pet")
        do {
            let json = try jsonEncoder.encode(pet)
            try json.write(to: fileStorageUrl)
        } catch {
            print("Could not upload pet")
            // TODO: add an error toast/alert of some kind
        }
    }

    func updateGravesInStorage(graves: [Grave]) -> Void {
        let jsonEncoder = JSONEncoder()
        let fileStorageUrl = self.getFileStorageUrl(path: "graves")
        do {
            let json = try jsonEncoder.encode(graves)
            try json.write(to: fileStorageUrl)
        } catch {
            print("Could not upload graves")
            // TODO: add an error toast/alert of some kind
        }
    }
    
    func updatePoopsInStorage(poops: [Poop]) -> Void {
        let jsonEncoder = JSONEncoder()
        let fileStorageUrl = self.getFileStorageUrl(path: "poops")
        do {
            let json = try jsonEncoder.encode(poops)
            try json.write(to: fileStorageUrl)
        } catch {
            print("Could not upload poops")
            // TODO: add an error toast/alert of some kind
        }
    }
}
