//
//  iGridsCoreData.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-25.
//

import Foundation
import CoreData

class DataController:ObservableObject {
    let container = NSPersistentContainer(name: "energyMonitorModel")
    init() {
        container.loadPersistentStores{ description, error in
                                        if let error = error {
                                            print("Core Data Failed \(error.localizedDescription)")
                                            }
                                    }
    }
}
