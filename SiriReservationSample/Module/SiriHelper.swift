//
//  SiriHelper.swift
//  SiriReservationSample
//
//  Created by Shunzhe Ma on R 2/12/27.
//

import Foundation
import Intents

struct Reservation {
    var reservationID: String = UUID().uuidString
    var restaurantName: String
    var bookedTime: Date
    var personName: String
    var reservation_partySize: Int
    var restruantLocation: CLPlacemark
    /*
     アプリがSiriを使って予約状況を更新できるようにするためには、サーバーは顧客に最新の予約情報を提供する必要があります。
     */
    var reservation_status: INReservationStatus
}

/*
 予約の問い合わせを行うリクエストです。
 例えば、予約の表示や修正をするための予約ID、トークンを含むことができます。
 */
struct Reservation_Query_Request: Identifiable {
    var id = UUID().uuidString
    var reservationID: String
}

class SiriHelper: NSObject {
    
    static let shared = SiriHelper()
    
    /**
     ユーザーが予約を閲覧する時（予約明細が画面に表示される時）は毎回、この機能を呼び出すべきです
     - 適切な`status`パラメーターと共にこの機能を呼び出すべきです。例えば、予約が確認のため保留状態にある時は`.pending`を使ってください。確認された場合は`.confirmed`を、キャンセルされた場合は`.cancelled`を呼び出してください。
     */
    func updateRestaurantReservation(_ item: Reservation, completionHandler: ((Error?) -> Void)? = nil) {
        let reservation_item = INSpeakableString(vocabularyIdentifier: item.reservationID, spokenPhrase: "\(item.restaurantName)の予約 \(item.reservationID)", pronunciationHint: nil)
        let reservation_actions = [getViewReservationDetailsAction(item)]
        let reservation = INRestaurantReservation(itemReference: reservation_item,
                                                  reservationNumber: item.reservationID,
                                                  bookingTime: Date(),
                                                  reservationStatus: item.reservation_status,
                                                  reservationHolderName: item.personName,
                                                  actions: reservation_actions,
                                                  url: generateReservationURL(item),
                                                  reservationDuration: getReservationPromoteDateRange(item),
                                                  partySize: item.reservation_partySize,
                                                  restaurantLocation: item.restruantLocation)
        let intent = INGetReservationDetailsIntent(reservationContainerReference: reservation_item, reservationItemReferences: nil)
        let response = INGetReservationDetailsIntentResponse(code: .success, userActivity: nil)
        response.reservations = [reservation]
        let interaction = INInteraction(intent: intent, response: response)
        interaction.donate(completion: completionHandler)
    }
    
    /*
     ユーザーが予約の詳細を閲覧できるようにする
     */
    private func getViewReservationDetailsAction(_ item: Reservation) -> INReservationAction {
        let viewDetailsAction = NSUserActivity(activityType: ActivityTypes.viewReservationDetails)
        let reservationDateStr = DateFormatter.localizedString(from: item.bookedTime, dateStyle: .short, timeStyle: .short)
        viewDetailsAction.title = "\(item.restaurantName)における\(reservationDateStr)での予約状況の詳細を表示します"
        viewDetailsAction.userInfo = ["reservationID" : item.reservationID]
        viewDetailsAction.requiredUserInfoKeys = ["reservationID"]
        viewDetailsAction.webpageURL = generateReservationURL(item)
        return .init(type: .checkIn,
                     validDuration: getReservationPromoteDateRange(item),
                     userActivity: viewDetailsAction)
    }
    
    /*
     ユーザーが予約の詳細を閲覧できるURLリンクを取得する
     */
    private func generateReservationURL(_ item: Reservation) -> URL? {
        return URL(string: "https://example.com/reservations/view?id=\(item.reservationID)")
    }
    
    private func getReservationPromoteDateRange(_ item: Reservation) -> INDateComponentsRange {
        let calendar = Calendar.autoupdatingCurrent
        // 予約時間の2時間後まで、予約の詳細を閲覧するようユーザーに宣伝しましょう
        let promoteDate_end = calendar.date(byAdding: .hour, value: 2, to: item.bookedTime) ?? item.bookedTime
        let promoteDate_end_components = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: promoteDate_end)
        let promoteDate_start = item.bookedTime
        let promoteDate_start_components = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: promoteDate_start)
        //
        return .init(start: promoteDate_start_components, end: promoteDate_end_components)
    }
    
}
