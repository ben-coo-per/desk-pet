//
//  PetStateCalculation.swift
//  Desk Pet
//
//  Created by Ben Cooper on 6/28/23.
//

import Foundation

extension Date {
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

public func getHungerState(timeLastFed: Date) -> Int {
    let hoursSinceLastFed = timeLastFed.seconds(from: Date()) * GAME_SPEED / 3600  // Returns a negative number
    return 5 + hoursSinceLastFed/PET_HUNGER_TIME
}

func getNumberOfNewPoops(timeLastFed: Date, existingPoops: [Poop]) -> Int {
    // get the number of hours since timeLastFed
    let hoursSinceLastFed = abs(timeLastFed.seconds(from: Date()) * GAME_SPEED / 3600 )

    // multiply that by the NUM_POOPS_PER_HR to get expected num of poops
    let numExpectedPoops: Int = hoursSinceLastFed * NUM_POOPS_PER_HR
    
    
    // count the number of poops created since timeLastFed
    let existingPoopsSinceLastFeeding = existingPoops.filter({ $0.createdAt > timeLastFed})
    
    // return the number of extra poops needed to reach expected number of poops
    return numExpectedPoops - existingPoopsSinceLastFeeding.count
}

public func checkPetIsAlive(timeLastFed: Date) -> Bool {
    let lastEaten = getHungerState(timeLastFed: timeLastFed)
    return lastEaten >= 0
}
