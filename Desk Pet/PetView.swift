//
//  PetView.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/29/23.
//

import SwiftUI
import ComposableArchitecture

struct PetView: View {
    let store: StoreOf<DeskPet>
    @State var showPetStatePopover: Bool = false;
    
    
    let SPEED: CGFloat = 5
    @State var petPosition = CGFloat.random(in: -120...120);
    @State var petDirection =  Bool.random(); // false=right, true=left
    
    func checkDirectionChange() -> Void{
        let CANVAS_EDGE_DISTANCE = (CANVAS_WIDTH-100) / 2
        
        // If the pet is at the edge of the screen, turn around
        let atLeftEdge = petDirection && petPosition <= -CANVAS_EDGE_DISTANCE + SPEED
        let atRightEdge = !petDirection && petPosition >= CANVAS_EDGE_DISTANCE - SPEED
        
        // Otherwise,
        // there's a 6.67% chance the pet changes direction on any move
        let rand = Int.random(in: 0..<15)
        
        if(rand == 0 || atRightEdge || atLeftEdge){
            petDirection.toggle()
        }
    }
    
    func checkPetState(viewStore: ViewStoreOf<DeskPet>) {
        let numNewPoops = getNumberOfNewPoops(timeLastFed: viewStore.pet.timeLastFed, existingPoops: viewStore.poops)
        if(numNewPoops > 0){
            for _ in 0..<numNewPoops{
                viewStore.send(.addPoop(petPosition))
            }
        }
    }
    
    func petPassiveMovement(viewStore: ViewStoreOf<DeskPet>) async{
        let timer = ContinuousClock().timer(interval: .milliseconds(1000/GAME_SPEED))
            for await _ in timer {
                checkPetState(viewStore: viewStore)
                checkDirectionChange()
                petPosition = (petDirection ? -1 : 1) * SPEED + petPosition
            }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}){ viewStore in
            if(viewStore.pet.isAlive){
                    Group {
                        Image("Monkey")
                            .resizable()
                            .frame(width: 80, height:80)
                            .padding(.horizontal)
                            .aspectRatio(1, contentMode: .fit)
                        // Handles flipping of pet
                            .rotationEffect(.degrees(petDirection ? 0 : 180 ), anchor: .center)
                            .rotation3DEffect(.degrees(petDirection ? 0 : 180), axis: (x: 1, y: 0, z:0))
                        // Pet movement
                            .offset(x: petPosition, y:-5)
                        
                        PetStateHoverView(store: self.store, petPosition: $petPosition)
                            .opacity(showPetStatePopover ? 0.9 : 0)
                    }.onHover{cursor in
                        withAnimation(.easeInOut){
                            showPetStatePopover = cursor
                        }
                    }.task {
                        await petPassiveMovement(viewStore: viewStore)
                    }
                }
                AnimationsView(store: self.store, petPosition: $petPosition)
        }
    }
}

struct PetStateHoverView: View {
    let store: StoreOf<DeskPet>
    @Binding var petPosition: CGFloat
    
    
    var body: some View {
        WithViewStore(self.store, observe: {$0.pet}){viewStore in
            HStack{
                Text("🍖 Hunger: \(getHungerState(timeLastFed:viewStore.timeLastFed))/5")
                    .padding(.all)
                    .background(.thinMaterial,
                                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .offset(x: petPosition, y: -70)
            }
        }
    }
}

struct AnimationsView: View {
    let store: StoreOf<DeskPet>
    @Binding var petPosition: CGFloat
    
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}){ viewStore in
            Text("🍖")
            .offset(x: petPosition, y: viewStore.feedingAnimation ? -20 : -80)
            .scaleEffect(viewStore.feedingAnimation ? 1 : 1.5)
            .opacity(viewStore.feedingAnimation ? 1 : 0)
            .onChange(of: viewStore.feedingAnimation) { _ in
                // after 1 second, remove the animation
                if(viewStore.feedingAnimation) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewStore.send(.endAnimation)
                    }
                }
            }
        }
    }
}
