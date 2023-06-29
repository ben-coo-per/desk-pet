//
//  GravesView.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/29/23.
//

import SwiftUI
import ComposableArchitecture

struct GravesView: View {
    let store: StoreOf<DeskPet>
    
    var body: some View {
        WithViewStore(self.store, observe: {$0.graves}){ gravesStore in
            ForEach(gravesStore.state, id: \.id){ grave in
                Image("Gravestone")
                    .resizable()
                    .frame(width: 80, height:80)
                    .padding(.horizontal)
                    .aspectRatio(1, contentMode: .fit)
                    .offset(x: grave.site, y:-5)
            }
        }
    }
}
