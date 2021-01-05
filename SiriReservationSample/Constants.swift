//
//  Constants.swift
//  SiriReservationSample
//
//  Created by Shunzhe Ma on R 2/12/27.
//

import Foundation
import CoreLocation
import Contacts

enum ActivityTypes {
    static let viewReservationDetails = "com.example.SiriReservationSample.viewReservationDetails"
}

enum NotificationTypes {
    static let viewReservationDetails = NSNotification.Name("viewReservationDetails")
}

enum DemoInformation {
    static let restruantName = "お弁当店"
    static let demoPartySize = 3
    static var bookTime: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())
    }
    static let demoLocation = CLLocation(latitude: 35.67226, longitude: 139.76581)
    static var demoAddress: CNPostalAddress {
        let postalAddress = CNMutablePostalAddress()
        postalAddress.country = "日本"
        postalAddress.postalCode = "104-0061"
        postalAddress.city = "東京都"
        postalAddress.street = "中央区銀座３丁目５−12"
        return postalAddress
    }
}
