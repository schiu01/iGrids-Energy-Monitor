//
//  RemoveDevice.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-26.
//

import SwiftUI

struct RemoveDevice: View {
    @State var hostname:String
    @Binding var showBox:Bool
    var body: some View {
        NavigationView {
            VStack {
                Text("Remove Device \(hostname)?").padding()
                    .font(.system(size: 15))
                Spacer()
                Divider()
                HStack {
                    Button("Remove") {
                        showBox = false
                    }
                    Button("Cancel") {
                        showBox = false
                    }

                }

            }
            

        }
    }
}

