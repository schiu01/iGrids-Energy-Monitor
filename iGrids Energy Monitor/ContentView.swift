//
//  ContentView.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-22.
//

import SwiftUI
import CoreData
struct ContentView: View {
    
    var body: some View {
                GeometryReader { g in
                    TabView {
                        HomeView().tabItem {
                            Text("Home")
                            .font(Font.custom("fa-solid-900", size: 20))
                            .foregroundColor(Color.white)
                            Image(systemName: "house.fill")
                            
                        }
                        .frame(width: g.size.width, height: g.size.height-70,alignment: .topLeading)
                        .font(Font.title.bold())
                        .statusBar(hidden: false)
                        .preferredColorScheme(.dark)
                        
                        ManageDevices().tabItem {
                            Text("Manage Devices")
                            .font(Font.custom("fa-solid-900", size: 20))
                            .foregroundColor(Color.white)
                            Image(systemName: "plus.square.fill")
                            
                        }
                        .frame(width: g.size.width, height: g.size.height-70,alignment: .topLeading)
                        .font(Font.title.bold())
                        .statusBar(hidden: false)
                        .preferredColorScheme(.dark)
                    
                    }
                }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
