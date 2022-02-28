//
//  ShowDeviceReading.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-27.
//

import SwiftUI
import CoreData

struct ShowDeviceReading: View {
    @State var device : FetchedResults<EMDEVICES>.Element
    @State var overallStatus:String = ""
    @State var dataResult:Dictionary<String,NSArray>?
    @State var watts:[String] = ["0.00","0.00","0.00","0.00"]
    @State var active = false
    @State var circleColors:[Color] = [Color.gray, Color.gray, Color.gray, Color.gray]
    @State var jsonString: String = ""
    @State var get_data_activity_flag:Bool = false
    @State var status_msg: String = ""
    @State var dataloaded = false
    @State var igridsDeviceAddr = ""
    @State var updatedDate:Date = Date(timeIntervalSince1970: 0)
    @State var connectionId:[String] = ["","","",""]
    @State var seenFirst = true
    


    
    let refreshTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    let dataUpdateTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    let retrieveData:iGridsRetrieveData = iGridsRetrieveData()
    let screensize:CGRect = UIScreen.main.bounds

    func updateVariables() {
        if(active == false) { return }
        jsonString = retrieveData.jsonString
        dataResult = convertToDictionary(text: jsonString)
        print("Data Result is: ")
        if(dataResult != nil) {
         
            for index in 0...3 {
                watts[index] = dataResult!["data"]![index+1] as! String
                if(watts[index] == "0.00") {
                    circleColors[index] = Color.gray
                } else {
                    circleColors[index] = Color.green
                }

            }
            let timeInteger = Double(dataResult!["data"]![0] as! String) ?? 0.00
            updatedDate = Date(timeIntervalSince1970: timeInteger)
            overallStatus = "\(updatedDate.getFormattedDate(format: "dd-MMM-yyyy HH:mm:ss"))"
        } else {
            overallStatus = retrieveData.status_msg
        }
        
    }
    func setInActive() {
        active = false
        seenFirst = true
    }
    func setActive() {
        active = true
    }
    func getWatts()->[String] {
        return watts
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
        if(updatedDate == Date(timeIntervalSince1970: 0) ) {
            overallStatus = "Retrieving Data..."
            
        } else {
            seenFirst = false
        }
        retrieveData.getData(host: host, in_query: in_query)
        jsonString = retrieveData.jsonString
        dataResult = convertToDictionary(text: jsonString)
        //overallStatus = ""
        
        
    }

    @State private var showPopup:[Bool] = [false,false,false,false]
    func showPopUp(index:Int) {
        print("------ showing popup -----")
        showPopup[index] = !showPopup[index]
        
    
    }
    @State var circleAngle:Double = 0

    var body: some View {
        let alternateName = device.alternateName ?? "-"
        let mdnsName = device.mdnsName ?? "-"
        let igridsDeviceAddr = "\(mdnsName).local"

        ZStack{
                VStack {
                Text("Last Update")
                    .font(.system(size: 13))
                    .frame(width: screensize.width, height: 14, alignment: .center)
                Text("\(overallStatus)")
                    .font(.system(size: 13))
                    .frame(width: screensize.width, height: 14, alignment: .center)
                    .multilineTextAlignment(.center)
                    .onReceive(dataUpdateTimer) {
                        time in
                            if(igridsDeviceAddr != "") {
                                getData(host: igridsDeviceAddr, in_query: "mode=1")
                            }
                    }
                    .onReceive(refreshTimer) { time in
                        updateVariables()
                    }


                Divider().background(Color.yellow)
                ForEach((0...1), id:\.self) { row in

                    HStack
                    {
                    ForEach((0...1),id: \.self) { index in
                        let i:Int =  (row * 2) + index
                        let v:Int = i + 1
                            Text("\(watts[i])")
                                .padding()
                                .frame(width: ((screensize.width/2) * 0.9), height: (screensize.height/4))
                                .background(Circle().strokeBorder(circleColors[i], lineWidth: 3))
                                .background(Text("\(v)").font(.system(size: 100)).opacity(0.15))
                                .foregroundColor(Color.white)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    showPopUp(index: i)
                                }
                                .popover(isPresented: $showPopup[i]) {
                                    PopUpView(show: $showPopup[i], currentEnergyDraw: $watts[i],
                                              ConnectionNumber: "\(alternateName)-\(v)",
                                              LastUpdated: $overallStatus,
                                              device: device
                                    )}
//                                .animation(.easeOut, value: 3)
//                                        .transition(.move(edge: .bottom))
//                                        .cornerRadius(15)
//                                        .ignoresSafeArea()
                        

                        if(index != 1) {
                            Divider().background(Color.yellow)
                            }
                        
                        }


                    }
                    Divider().background(Color.yellow)

                }
                Text("\(alternateName)")
                    .font(.system(size: 16 ))
                .onDisappear(perform: setInActive)
                .onAppear(perform: setActive)
                
            }
            
            if(seenFirst) {
                          Circle()
                              .stroke(Color(.systemGray5), lineWidth: 14)
                              .frame(width: 100, height: 100)
                              .overlay(Text("Loading...").font(.system(size: 16)))
               
                          Circle()
                              .trim(from: 0, to: 0.2)
                              .stroke(Color.green, lineWidth: 7)
                              .frame(width: 100, height: 100)
                              .rotationEffect(Angle(degrees: circleAngle))
                              .onAppear(perform: {
                                  withAnimation(Animation.linear(duration: 2).repeatForever()) {
                                      //if(circleAngle == 360) { circleAngle = 0 } else { circleAngle = 0}
                                      circleAngle = 360 * 2
                                  }
                              })
            }

        }
    }


}

