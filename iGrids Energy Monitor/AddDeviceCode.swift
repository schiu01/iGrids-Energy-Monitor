//
//  AddDeviceCode.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-25.
//

import SwiftUI
import CoreData


func checkDevice()->Bool {
    print("Checking Device Id")
    return true
}
func addDevice()->Bool {
    print("Adding new device")
    return true
}

struct AddDeviceCode: View {


    @Environment(\.managedObjectContext) var moc


    @Binding var deviceHostName:String
    @State var deviceId:String = ""
    @Binding var showBox:Bool
    @State var alternateName:String = ""

    var body: some View {

        VStack {

            Text("\(deviceHostName)").padding()
                .font(.system(size: 15, weight: .bold))
            Divider()
            Text("Enter the code found on your device box")
                .font(.system(size: 15,weight: .bold))
            TextField("", text: $deviceId).padding()
                .font(.system(size: 14))
                .foregroundColor(Color.black)
                .background(Color.white)
                .frame(maxWidth:UIScreen.main.bounds.width * 0.75)
                .cornerRadius(15)
            Text("Name your device").font(.system(size: 15,weight: .bold))
            TextField("", text: $alternateName).padding()
                .font(.system(size: 14))
                .foregroundColor(Color.black)
                .background(Color.white)
                .frame(maxWidth:UIScreen.main.bounds.width * 0.75)
                .cornerRadius(15)
                .onAppear(perform: {if(alternateName == "") { alternateName = deviceHostName}})
            Spacer()
            HStack {
                Button("Add") {
                    print("Adding Device")
                    if(checkDevice()) {

                        // Add Device
                        let emdevices1 = EMDEVICES(context: moc)
                        emdevices1.emDeviceTag = deviceId
                        emdevices1.emDeviceId = UUID().uuidString
                        emdevices1.alternateName = alternateName
                        emdevices1.mdnsName = deviceHostName
                        emdevices1.numProbes = 4
                        emdevices1.lastRefreshDate = Date()
                        do {
                            try moc.save()
                        } catch {
                            print("Error in saving! \(error)")
                        }

                        showBox = false


                    }
                }
                .padding()
                .foregroundColor(Color.white)
                .background(Color.green)
                .cornerRadius(15)
                .font(.system(size: 15))
                Button("Cancel") {
                    showBox = false
                }
                .padding()
                .background(Color.red)
                .cornerRadius(15)
                .foregroundColor(Color.white)
                .font(.system(size: 15))

            }

        }.onAppear(perform: {print("shown")})
    }
}
