//
//  ContentView.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/24/23.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<DeskPet>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                PetView(store: self.store)
            }
            .frame(width: CANVAS_WIDTH, height: CANVAS_HEIGHT)
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .indigo]), startPoint: .topLeading, endPoint: .bottom)
            )
            .aspectRatio(1, contentMode: .fit)
            .toolbar {
                ToolbarActionView(store: self.store)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: DeskPet.State()) {
            DeskPet()
          })
    }
}
