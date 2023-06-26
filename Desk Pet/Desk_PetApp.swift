//
//  Desk_PetApp.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/24/23.
//

import SwiftUI
import ComposableArchitecture

struct DeskPetPosition: Equatable {
    var x: Float = 0
    var direction: Int = 0 // 0 = right, 1 = left
}

struct DeskPet: ReducerProtocol {
    struct State: Equatable {
        var hunger = 0 // hunger on a scale of 0 to 5, 0=fat & happy, 5=dead from starvation
    }
    enum Action: Equatable {
        case feedPet
      }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .feedPet:
            if(state.hunger > 0){
                state.hunger = state.hunger - 1
            }
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
        }
    }
}
