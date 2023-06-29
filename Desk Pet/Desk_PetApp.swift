//
//  Desk_PetApp.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/24/23.
//

import SwiftUI
import ComposableArchitecture

struct Pet: Equatable, Codable {
    var timeLastFed: Date = Date()  // last meal is a timestamp
}


struct DeskPet: ReducerProtocol {
    var fm: FileManager
    init() {
        fm = FileManager()
    }
    
    struct State: Equatable {
        var pet: Pet
        var feedingAnimation: Bool = false
        
        init() {
            // get pet from storage
            let fm = FileManager()
            let petFromStorage = fm.getPetFromStorage()
            // set the state
            self.pet = petFromStorage
            fm.updatePetInStorage(pet: self.pet)
        }
        
    }
    enum Action: Equatable {
        case feedPet
        case endAnimation
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



extension FileManager {
    private func getFileStorageUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("deskPet.json")
    }
    
    func updatePetInStorage(pet: Pet) -> Void {
        let jsonEncoder = JSONEncoder()
        let fileStorageUrl = self.getFileStorageUrl()
        do {
            let json = try jsonEncoder.encode(pet)
            try json.write(to: fileStorageUrl)
        } catch {
            print("Could not upload ideas")
            // TODO: add an error toast/alert of some kind
        }
    }

    func getPetFromStorage() -> Pet {
        let jsonDecoder = JSONDecoder()
        let fileStorageUrl = self.getFileStorageUrl()

        do {
            let json = try Data(contentsOf: fileStorageUrl)
            let decoded = try jsonDecoder.decode(Pet.self, from: json)
            return decoded
        } catch {
            print(error.localizedDescription)
            return Pet()
        }
    }
}
