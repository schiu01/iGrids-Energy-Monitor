//
//  HomeView.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-22.
//

import SwiftUI
import Network
struct HomeView: View {
    @State var host:[String] = []
    @State var myhost:String = "Loading..."
    @State var jsonString: String = ""
    @State var get_data_activity_flag:Bool = false
    @State var status_msg: String = ""
    @State var dataloaded = false
    @State var igridsDeviceAddr = ""
    @State var boxes:[String] = ["0.00","0.00","0.00","0.00"]
    @State var watts:[String] = ["0.00","0.00","0.00","0.00"]
    @State var overallStatus:String = ""
    @State var deviceName:String = "Energy Monitor 01"
    @State var updatedDate:Date = Date()
    let retrieveData:iGridsRetrieveData = iGridsRetrieveData()
    @State var dataResult:Dictionary<String,NSArray>?
    let screensize:CGRect = UIScreen.main.bounds
    let refreshTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    let dataUpdateTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var active = false
    
//    func mdnsBrowse1() {
//        let descriptor = nw_browse_descriptor_create_bonjour_service("_igridsem", "local")
//        let parameters = nw_parameters_create()
//
//        let browser = nw_browser_create(descriptor, parameters)
//        nw_browser_set_queue(browser, DispatchQueue.main)
//        nw_browser_set_browse_results_changed_handler(browser, <#T##handler: nw_browser_browse_results_changed_handler_t?##nw_browser_browse_results_changed_handler_t?##(nw_browse_result_t, nw_browse_result_t, Bool) -> Void#>)
//    }
    func setInActive() {
        active = false
    }
    func convertToDictionary(text: String) -> Dictionary<String,NSArray>? {
        
        if let data = text.data(using: .utf8) {
            do {
                //return try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]]
                print("jsonifying...")
                return try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, NSArray>
            } catch {
                print("Error in json")
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func getData(host: String = "", in_query : String = "") -> Void
    {
        if(active == false) { return }
        overallStatus = "Retrieving Data"
        retrieveData.getData(host: host, in_query: in_query)
        jsonString = retrieveData.jsonString
        dataResult = convertToDictionary(text: jsonString)
        //overallStatus = ""
    }
    func updateVariables() {
        if(active == false) { return }
        jsonString = retrieveData.jsonString
        dataResult = convertToDictionary(text: jsonString)
        print("Data Result is: ")
        if(dataResult != nil) {
         
            for index in 0...3 {
                watts[index] = dataResult!["data"]![index+1] as! String

            }
            let timeInteger = Double(dataResult!["data"]![0] as! String) ?? 0.00
            updatedDate = Date(timeIntervalSince1970: timeInteger)
            overallStatus = "Last updated\r\n \(updatedDate.getFormattedDate(format: "dd-MMM-yyyy HH:mm:ss"))"
        } else {
            overallStatus = retrieveData.status_msg
        }
        
    }
func mdnsBrowse() {
        active = true
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
            result.forEach { device in
                print("1")
//                host.append( device.endpoint.debugDescription)
                myhost = device.endpoint.debugDescription
                print("myhost: \(myhost)")
                print(device.endpoint)
                print(device.metadata)
                overallStatus="Device found... connecting.."
                
                let conn = NWConnection(to: device.endpoint, using: .tcp)
                
                
                conn.stateUpdateHandler = { state in
                    switch state {
                    case .ready:
                        if let innerEndpoint = conn.currentPath?.remoteEndpoint,
                           case .hostPort(let host, let port) = innerEndpoint {
                            igridsDeviceAddr = String(host.debugDescription[..<(host.debugDescription.firstIndex(of: "%") ?? host.debugDescription.endIndex)])
                            print("Connected \(host) \(port)")
                            print("Host is: \(igridsDeviceAddr)")
                            print(conn.endpoint.debugDescription)
                            conn.cancel()
                            print("Starting Query: \(igridsDeviceAddr)")
                            
                            getData(host: igridsDeviceAddr, in_query: "mode=1")
                            
                        }
                    default:
                        break
                     }
                }
                conn.start(queue: .global())
            }
        }
        browser.start(queue: DispatchQueue.main)

    }
    var body: some View {

        VStack {
            Text("\(overallStatus)")
               .frame(width: (screensize.width * 0.9), height: 40)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
            Divider()
            HStack {
                Text(
                    "\(watts[0])"
                    )
                    .padding()
                    .frame(width: ((screensize.width/2) * 0.9), height: (screensize.height/4))
                    .onReceive(refreshTimer) { time in
                        updateVariables()
                    }
                    .onReceive(dataUpdateTimer) {
                        time in
                            if(igridsDeviceAddr != "") {
                                getData(host: igridsDeviceAddr, in_query: "mode=1")
                            }
                    }
                    .background(Circle().strokeBorder(Color.green, lineWidth: 3))
                    .foregroundColor(Color.gray)
                    .font(.system(size: 20))
                    Divider().background(Color.yellow)
                Text(
                    "\(watts[1])"
                    )
                    .padding()
                    .frame(width: ((screensize.width/2) * 0.9), height: (screensize.height/4))
                    .onAppear(perform: mdnsBrowse)
                    .onReceive(refreshTimer) { time in
                        updateVariables()
                    }
                    .background(Circle().strokeBorder(Color.green, lineWidth: 3))
                    .foregroundColor(Color.gray)
                    .font(.system(size: 20))

            }
            Divider().background(Color.yellow)
        HStack {
            Text(
                "\(watts[2])"
                )
                .padding()
                .frame(width: ((screensize.width/2) * 0.9), height: (screensize.height/4))
                .onAppear(perform: mdnsBrowse)
                .onReceive(refreshTimer) { time in
                    updateVariables()
                }
                .background(Circle().strokeBorder(Color.green, lineWidth: 3))
                .foregroundColor(Color.gray)
                .font(.system(size: 20))
            Divider().background(Color.yellow)
            Text(
                "\(watts[3])"
                )
                .padding()
                .frame(width: ((screensize.width/2) * 0.9), height: (screensize.height/4))
                .onAppear(perform: mdnsBrowse)
                .onReceive(refreshTimer) { time in
                    updateVariables()
                }
                .background(Circle().strokeBorder(Color.green, lineWidth: 3))
                .foregroundColor(Color.gray)
                .font(.system(size: 20))
        }
            Divider().background(Color.yellow)
            Text("\(deviceName)")
                .frame(width: UIScreen.main.bounds.width, height: 25, alignment: .top)
                .font(.system(size: 15))
        .onAppear(perform: mdnsBrowse)
        .onDisappear(perform: setInActive)
        }
    
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
