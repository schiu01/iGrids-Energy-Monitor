//
//  iGrids_Energy_MonitorApp.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-22.
//

import SwiftUI

@main

struct iGrids_Energy_MonitorApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
