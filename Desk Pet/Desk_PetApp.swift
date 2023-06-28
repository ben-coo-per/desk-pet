//
//  Desk_PetApp.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/24/23.
//

import SwiftUI
import ComposableArchitecture

struct DeskPet: ReducerProtocol {
    struct State: Equatable {
        var timeLastEaten: Date? // last meal is a timestamp
    }
    enum Action: Equatable {
        case feedPet
      }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .feedPet:
            state.timeLastEaten = Date()
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
