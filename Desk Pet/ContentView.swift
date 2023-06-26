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
                ZStack{
                    Rectangle()
                        .fill(.gray)
                        .frame(width: .infinity, height: 50)
                        .offset(x:0, y:25)
                    Image("Monkey")
                        .resizable()
                        .frame(minWidth: 60, maxWidth: 100, minHeight: 60, maxHeight: 100)
                        .aspectRatio(1, contentMode: .fit)
                        // Handles flipping of pet
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z:0))
                        .offset(x:-200, y:-5)
                }
            }
            .frame(minWidth: 300, maxWidth: 500, minHeight: 300, maxHeight: 500)
            .toolbar {
                // TODO: This is where the stats will go
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
