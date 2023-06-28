//
//  ContentView.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/24/23.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @State var petPosition: CGFloat = 0;
    @State var petDirection: Bool =  false; // 0=right, 1=left
    let store: StoreOf<DeskPet>
    
    let speed: CGFloat = 5
    func checkDirectionChange() -> Void{
        let rand = Int.random(in: 0..<12)
        if(rand == 0
           || (!petDirection && petPosition >= 200-speed)
           || (petDirection && petPosition <= -200+speed)
        ){
            petDirection.toggle()
        }
    }
    
    func petPassiveMovement() async{
        let timer = ContinuousClock().timer(interval: .seconds(1))
            for await _ in timer {
                checkDirectionChange()
                petPosition = (petDirection ? -1 : 1) * speed + petPosition
            }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 400, height: 50)
                        .offset(x:0, y:25)
                    Image("Monkey")
                        .resizable()
                        .frame(width: 80, height:80)
                        .aspectRatio(1, contentMode: .fit)
                        // Handles flipping of pet
                        .rotationEffect(.degrees(petDirection ? 0 : 180 ), anchor: .center)
                        .rotation3DEffect(.degrees(petDirection ? 0 : 180), axis: (x: 1, y: 0, z:0))
                        // Pet movement
                        .offset(x: petPosition, y:-5)
                }.task {
                    await petPassiveMovement()
                }
            }
            .frame(width: 400, height:400)
            .aspectRatio(1, contentMode: .fit)
            .toolbar {
                // TODO: This is where the stats will go
                ToolbarActionView(store: self.store)
               
            }
        }
    }
}


struct ToolbarActionView: View {
    let store: StoreOf<DeskPet>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button(action:{
                viewStore.send(.feedPet)
            }){
                Text("🍖  Feed")
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
