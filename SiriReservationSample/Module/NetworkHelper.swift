//
//  NetworkHelper.swift
//  SiriReservationSample
//
//  Created by Shunzhe Ma on R 2/12/27.
//

import Foundation
import UIKit
import Contacts
import CoreLocation

class NetworkHelper {
    
    static let shared = NetworkHelper()
    
    /*
     ネットワークが、クエリオブジェクトにより予約情報の取得をサーバーにリクエストすることについて説明します。
     */
    func getReservationDetails(_ query: Reservation_Query_Request, completion: @escaping (Reservation) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let bookTime = DemoInformation.bookTime else { return }
            completion(.init(reservationID: query.reservationID,
                             restaurantName: DemoInformation.restruantName,
                             bookedTime: bookTime,
                             personName: UIDevice.current.name,
                             reservation_partySize: DemoInformation.demoPartySize,
                             restruantLocation: .init(location: DemoInformation.demoLocation,
                                                      name: DemoInformation.restruantName,
                                                      postalAddress: DemoInformation.demoAddress),
                             reservation_status: .confirmed))
        }
    }
    
    func createReservation(_ item: Reservation, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
}
