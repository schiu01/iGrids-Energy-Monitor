//
//  AddNewDevice.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-25.
//

import SwiftUI
import Network
import CoreData

struct AddNewDevice: View {
    @State private var modeDiscover:Bool = false
    @State private var overallStatus:String = ""
    @State private var energyMonitorDevices:[NWEndpoint] = []
    @FetchRequest(sortDescriptors: []) var emdevices: FetchedResults<EMDEVICES>
    @Environment(\.managedObjectContext) var moc


    func checkHost(hostname:String)->Bool {
        var returnResult = false
        print("Total Devices: \(emdevices.count)")
        for device in (emdevices) {
            
            print("Fetched: \(device.mdnsName)")
            if(device.mdnsName == hostname){
                returnResult = true
            }
        }
        return returnResult
    }
    func mdnsBrowse() {
            let parameter = NWParameters.init()
            parameter.allowFastOpen = true
            parameter.acceptLocalOnly = true
            parameter.allowLocalEndpointReuse = true
            parameter.includePeerToPeer = true
            
            overallStatus = "Searching for devices..."
            
            let browser = NWBrowser(for: .bonjour(type: "_igridsem._tcp.", domain: "local."), using: parameter)
            
            browser.stateUpdateHandler = {
                newState in
                switch newState {
                case .failed(let error):
                    print("NW Browser: now error state: \(error)")
                    browser.cancel()
                case .ready:
                    print("NW Browser: new bonjour discovery: ready")
                case .setup:
                    print("NW BrowseR: in setup state")
                default:
                    break
                }
            }
            browser.browseResultsChangedHandler = {result, changed in
                modeDiscover = true
                overallStatus="Device found... connecting.."
                energyMonitorDevices.removeAll()

                result.forEach { device in
                    energyMonitorDevices.append(device.endpoint)
                }
                modeDiscover=false
            }
            browser.start(queue: DispatchQueue.main)
        
        
        }
    @State var showAddCodeView:Bool = false
    @State var showRemoveDeviceView:Bool = false
    @State var hostname:String = ""
    var body: some View {
        var exists:Bool = false

        NavigationView {
        VStack {
            if(modeDiscover) {
                Text("Discovering Devices...")
            } else {
                if(energyMonitorDevices.count == 0) {
                    Text("No Devices Found!")
                    Divider()
                    Button("Rescan...") {
                        mdnsBrowse()
                    }.padding().cornerRadius(15).background(Color.blue).foregroundColor(Color.white)
                        
                } else {
                    List(energyMonitorDevices, id: \.self) { device in
                        let array = device.debugDescription.components(separatedBy: ".")
                        
                        HStack {
                            Text("\(array[0])").font(.system(size: 16))
                            Button {
                                print("Tapped")
                                print("Host is: \(array[0])")
                                hostname = array[0]
                            
                                
                                if(checkHost(hostname: array[0])) {
                                    exists = true
                                    showRemoveDeviceView = true
                                } else {
                                    showAddCodeView = true
                                }
                            } label: {
                                if(checkHost(hostname: array[0])) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.red)

                                } else {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color.green)
                                    }
                                }
                            .tag(array[0])
                            
                        }
                    }
                    .navigationTitle("Devices Found")
                    .refreshable {
                        mdnsBrowse()
                    }
                }
            }
        }
        }
        .onAppear(perform: mdnsBrowse)
        .popover(isPresented: $showAddCodeView) {
            if(!exists) {
                AddDeviceCode(deviceHostName: "\(hostname)",showBox: $showAddCodeView)
            } else {
                RemoveDevice(hostname: "\(hostname)", showBox: $showAddCodeView)
            }
        }
        .alert(isPresented: $showRemoveDeviceView) {
            Alert(
                title: Text("Remove Device?"), message: Text("\(hostname)"),
                primaryButton: .destructive(Text("Delete")) {
                    print("Delete \(hostname)")
                    for d in (emdevices) {
                        if(d.mdnsName == hostname) {
                            moc.delete(d)
                        }
                    }
                    try? moc.save()
                    

                },
                secondaryButton: .cancel()
                
            )
            
        }
        

 
    }
}

struct AddNewDevice_Previews: PreviewProvider {
    static var previews: some View {
        AddNewDevice()
    }
}
