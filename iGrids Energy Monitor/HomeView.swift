//
//  HomeView.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-22.
//

import SwiftUI
import Network



struct HomeView: View {
    @FetchRequest(sortDescriptors:[]) var emdevices : FetchedResults<EMDEVICES>
    @FetchRequest(sortDescriptors:[]) var emprobes : FetchedResults<EMPROBES>

//    @State var host:[String] = []
//    @State var myhost:String = "Loading..."
//    @State var deviceName:String = "Energy Monitor 01"
//    @State var connectionId:[String] = ["","","",""]
    
//    func mdnsBrowse1() {
//        let descriptor = nw_browse_descriptor_create_bonjour_service("_igridsem", "local")
//        let parameters = nw_parameters_create()
//
//        let browser = nw_browser_create(descriptor, parameters)
//        nw_browser_set_queue(browser, DispatchQueue.main)
//        nw_browser_set_browse_results_changed_handler(browser, <#T##handler: nw_browser_browse_results_changed_handler_t?##nw_browser_browse_results_changed_handler_t?##(nw_browse_result_t, nw_browse_result_t, Bool) -> Void#>)
//    }

//func mdnsBrowse() {
//
//    for index in 0...3 {
//        connectionId[index] = "\(deviceName) - \(index+1)"
//    }
//
//        active = true
//        let parameter = NWParameters.init()
//        parameter.allowFastOpen = true
//        parameter.acceptLocalOnly = true
//        parameter.allowLocalEndpointReuse = true
//        parameter.includePeerToPeer = true
//
//        overallStatus = "Searching for devices..."
//
//        let browser = NWBrowser(for: .bonjour(type: "_igridsem._tcp.", domain: "local."), using: parameter)
//
//        browser.stateUpdateHandler = {
//            newState in
//            switch newState {
//            case .failed(let error):
//                print("NW Browser: now error state: \(error)")
//                browser.cancel()
//            case .ready:
//                print("NW Browser: new bonjour discovery: ready")
//            case .setup:
//                print("NW BrowseR: in setup state")
//            default:
//                break
//            }
//        }
//        browser.browseResultsChangedHandler = {result, changed in
//            result.forEach { device in
//                print("1")
////                host.append( device.endpoint.debugDescription)
//                myhost = device.endpoint.debugDescription
//                print("myhost: \(myhost)")
//                print(device.endpoint)
//                print(device.metadata)
//                overallStatus="Device found... connecting.."
//
//                let conn = NWConnection(to: device.endpoint, using: .tcp)
//
//
//                conn.stateUpdateHandler = { state in
//                    switch state {
//                    case .ready:
//                        if let innerEndpoint = conn.currentPath?.remoteEndpoint,
//                           case .hostPort(let host, let port) = innerEndpoint {
//                            igridsDeviceAddr = String(host.debugDescription[..<(host.debugDescription.firstIndex(of: "%") ?? host.debugDescription.endIndex)])
//                            print("Connected \(host) \(port)")
//                            print("Host is: \(igridsDeviceAddr)")
//                            print(conn.endpoint.debugDescription)
//                            conn.cancel()
//                            print("Starting Query: \(igridsDeviceAddr)")
//
//                            getData(host: igridsDeviceAddr, in_query: "mode=1")
//
//                        }
//                    default:
//                        break
//                     }
//                }
//                conn.start(queue: .global())
//            }
//        }
//        browser.start(queue: DispatchQueue.main)
//
//    }
//
    
    var body: some View {
        if(emdevices.count == 0) {
            Text("No devices registered.\nUse \"Manage Devices\" to add new device")
                .padding()
                .font(.system(size: 17))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50, alignment: .center)
                .multilineTextAlignment(.center)
        } else {
            TabView {
                ForEach(emdevices) {
                    device in
                        ShowDeviceReading(device: device)
                        .ignoresSafeArea()
                        
                }
            
                
            }.tabViewStyle(.page)

        }
    }

}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
