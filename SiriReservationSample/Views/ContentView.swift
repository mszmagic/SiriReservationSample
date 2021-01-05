//
//  ContentView.swift
//  SiriReservationSample
//
//  Created by Shunzhe Ma on R 2/12/27.
//

import SwiftUI
import Intents

struct ContentView: View {
    
    @State var viewingReservationID: Reservation_Query_Request? = nil
    
    @AppStorage("reservationID") var existingReservationID = ""
    
    /*
     NotificationCenter メッセージを受信して予約情報を表示する
     */
    let show_reservation_notification = NotificationCenter.default.publisher(for: NotificationTypes.viewReservationDetails)
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: ReservationCreator()) {
                        Text("レストランの予約をする")
                    }
                }
                /* このデモアプリでは、最新の予約情報のみを表示します。 */
                let hasReservations = (existingReservationID != "")
                Text(hasReservations ? existingReservationID : "予約なし")
                    .padding()
                    .onReceive(show_reservation_notification, perform: { notificationObject in
                        if let userActivity = notificationObject.object as? NSUserActivity,
                           let intentObject = userActivity.interaction?.intent as? INGetReservationDetailsIntent,
                           let reservationName = intentObject.reservationItemReferences?.first,
                           let reservationID = reservationName.vocabularyIdentifier {
                            DispatchQueue.main.async {
                                self.viewingReservationID = .init(reservationID: reservationID)
                            }
                        }
                    })
                    .sheet(item: $viewingReservationID) { id in
                        ReservationViewer(query: id)
                    }
                    .onTapGesture {
                        if hasReservations {
                            self.viewingReservationID = .init(reservationID: existingReservationID)
                        }
                    }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
            
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
