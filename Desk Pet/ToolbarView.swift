//
//  Toolbar.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/29/23.
//

import SwiftUI
import ComposableArchitecture


struct ToolbarActionView: View {
    let store: StoreOf<DeskPet>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button(action:{
                viewStore.send(.feedPet, animation: .interactiveSpring(response: 0.8, dampingFraction: 0.8))
            }){
                Text("🍖  Feed")
            }.disabled(viewStore.feedingAnimation || getHungerState(timeLastFed: viewStore.pet.timeLastFed) == 5)
        }
    }
}
