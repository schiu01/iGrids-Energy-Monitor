//
//  PopUpView.swift
//  iGrids Energy Monitor
//
//  Created by Steven Chiu on 2022-02-24.
//

import SwiftUI
struct PopUpView: View {
    @Binding var show:Bool
    @Binding var currentEnergyDraw:String
    @State var ConnectionNumber:String
    @Binding var LastUpdated:String
    @State var device : FetchedResults<EMDEVICES>.Element
    @State var thresholdViewFlag:Bool = false
   
    
    var body: some View {
        if(show) {
                    ScrollView {
                     
                             VStack {
                                 HStack {
                                     Button() {
                                         show = false
                                     } label: {
                                         Image(systemName: "multiply.circle.fill")

                                     }

                                 }
                                 VStack {
                                     Text("\(ConnectionNumber)")
                                         .padding()
                                         .frame(width: UIScreen.main.bounds.width, height: 50, alignment: .center)
                                         .font(.system(size: 17))
                                         .background(Color.green)

                                     Spacer()
                                     Text("Last Update")
                                         .font(.system(size: 16,weight: .bold))
                                     Text("\(LastUpdated)")
                                         .font(.system(size: 14))
                                     Divider()
                                 }
                                 VStack {
                                     Text("Current Power Draw (Watts)")
                                         .font(.system(size: 16,weight: .bold))
                                     Text("\(currentEnergyDraw)")
                                         .font(.system(size: 14))
                                     Divider()
                                     
                                     Text("Threshold Set (Watts)")
                                         .font(.system(size: 16,weight: .bold))
                                     
                                     Text("\(currentEnergyDraw)")
                                         .font(.system(size: 14))
                                     HStack {
                                         Button() {
                                             print("Setting Threshold")
                                         } label: {
                                             Text("Set/Update Threshold").font(.system(size: 15))
                                         }
                                     }
                                     Divider()
                                 }
                                 VStack {
                                     Text("Custom name for connector")
                                         .font(.system(size: 16,weight: .bold))
                                     Text("\(ConnectionNumber)")
                                         .font(.system(size: 14))
                                     HStack {
                                         Button() {
                                             print("Setting Threshold")
                                         } label: {
                                             Text("Set/Update custom name").font(.system(size: 15))
                                         }
                                     }

                                     Divider()
                                 }
                                 VStack {
                                     Text("Energy consumption history")
                                         .font(.system(size: 16,weight: .bold))
                                     Divider()
                                 }

                                 
                                 
                             }
                    }
                    //.onTapGesture(perform: {show = false})
                    //.ignoresSafeArea()
                

        }
    }
}

