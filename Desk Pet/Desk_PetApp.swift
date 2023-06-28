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

struct AppState: ReducerProtocol {
    struct State: Equatable {
        var pet = DeskPet.State()
    }
    
    enum Action: Equatable {
        case pet(DeskPet.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.pet, action: /Action.pet) {
            DeskPet()
        }
        
        Reduce { state, action in
            switch action {
            case .pet:
                return .none
            }
        }
    }
}

@main
struct Desk_PetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState.State()) {
                AppState()
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
