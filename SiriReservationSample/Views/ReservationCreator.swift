//
//  ReservationCreator.swift
//  SiriReservationSample
//
//  Created by Shunzhe Ma on R 2/12/27.
//

import SwiftUI
import CoreLocation
import Contacts
import MapKit

struct ReservationCreator: View {
    
    @State var restaurantName: String = DemoInformation.restruantName
    @State var bookedTime: Date = DemoInformation.bookTime ?? Date()
    @State var personName: String = UIDevice.current.name
    @State var partySize: Int = DemoInformation.demoPartySize
    @State var reservationLocation: CLLocation = DemoInformation.demoLocation
    @State var reservationAddress: CNPostalAddress = DemoInformation.demoAddress
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Form {
            Section {
                Text(restaurantName)
                Text(DateFormatter.localizedString(from: bookedTime, dateStyle: .short, timeStyle: .short))
                Text(personName)
            }
            Section {
                Map(coordinateRegion: .constant(.init(center: reservationLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))))
                    .frame(height: 150)
                Text("\(reservationAddress.city) \(reservationAddress.street)")
            }
            Button(action: {
                let item = Reservation(restaurantName: restaurantName,
                                       bookedTime: bookedTime,
                                       personName: personName,
                                       reservation_partySize: partySize,
                                       restruantLocation: CLPlacemark(location: reservationLocation,
                                                                      name: restaurantName,
                                                                      postalAddress: reservationAddress),
                                       reservation_status: .confirmed)
                /* このデモアプリでは、ランダムなUUIDを生成し、それをローカルストレージへ保存しています。 */
                UserDefaults.standard.set(item.reservationID, forKey: "reservationID")
                NetworkHelper.shared.createReservation(item) { created in
                    if created {
                        SiriHelper.shared.updateRestaurantReservation(item) { error in
                            if error == nil {
                                DispatchQueue.main.async {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            }) {
                Text("予約する")
            }
        }
        
    }
    
}
