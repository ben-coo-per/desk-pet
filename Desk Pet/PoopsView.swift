//
//  PoopsView.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/30/23.
//

import SwiftUI
import ComposableArchitecture

struct PoopsView: View {
    let store: StoreOf<DeskPet>
    
    var body: some View {
        WithViewStore(self.store, observe: {$0.poops}){ poopStore in
            ForEach(poopStore.state, id: \.id){ poop in
                Text("💩").offset(x: poop.position)
            }
        }
    }
}
