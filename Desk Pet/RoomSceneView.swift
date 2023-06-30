//
//  RoomSceneView.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/29/23.
//

import SwiftUI
import ComposableArchitecture



struct RoomSceneView: View {
    let store: StoreOf<DeskPet>
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}){ viewStore in
            ZStack{
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.gray, Color(red: 0.45, green: 0.5, blue: 0.56)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: CANVAS_WIDTH, height: 50)
                    .offset(x:0, y:25)
                GravesView(store: self.store)
                PetView(store: self.store)
                PoopsView(store: self.store)
            }
        }
    }
}
