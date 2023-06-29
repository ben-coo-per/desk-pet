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
}

public func getHungerState(timeLastFed: Date) -> Int {
    let hoursSinceLastFed = timeLastFed.hours(from: Date())  // Returns a negative number
    return 5 + hoursSinceLastFed/PET_HUNGER_TIME
}

public func checkPetIsAlive(timeLastFed: Date) -> Bool {
    let lastEaten = getHungerState(timeLastFed: timeLastFed)
    return lastEaten >= 0
}
