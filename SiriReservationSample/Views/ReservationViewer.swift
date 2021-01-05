//
//  ReservationViewer.swift
//  SiriReservationSample
//
//  Created by Shunzhe Ma on R 2/12/27.
//

import SwiftUI
import MapKit
import Intents

struct ReservationViewer: View {
    
    @State var itemToShow: Reservation? = nil
    
    var query: Reservation_Query_Request
    
    var body: some View {
        
        Form {
            if let item = self.itemToShow {
                if item.reservation_status == INReservationStatus.confirmed {
                    Text("予約が確定しました。")
                } else if item.reservation_status == INReservationStatus.pending {
                    Text("予約は確定待ちです。")
                } else if item.reservation_status == INReservationStatus.canceled {
                    Text("予約がキャンセルされました。")
                }
                Section {
                    Text(item.restaurantName)
                    let reservationDateStr = DateFormatter.localizedString(from: item.bookedTime, dateStyle: .short, timeStyle: .short)
                    Text(reservationDateStr)
                    Text("\(item.reservation_partySize)")
                }
                if let location = item.restruantLocation.location?.coordinate {
                    Map(coordinateRegion: .constant(.init(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))))
                        .frame(height: 150)
                }
                Text("\(item.restruantLocation.postalAddress?.city ?? "") \(item.restruantLocation.postalAddress?.street ?? "")")
            } else {
                HStack {
                    ProgressView()
                    Text("予約情報をロード中…")
                        .padding(.leading)
                }
                    .onAppear {
                        NetworkHelper.shared.getReservationDetails(self.query) { fetchedItem in
                            DispatchQueue.main.async {
                                self.itemToShow = fetchedItem
                            }
                            SiriHelper.shared.updateRestaurantReservation(fetchedItem) { error in
                                print(error?.localizedDescription)
                            }
                        }
                    }
            }
        }
        
    }
    
}

struct ReservationViewer_Previews: PreviewProvider {
    static var previews: some View {
        ReservationViewer(query: .init(reservationID: ""))
    }
}
