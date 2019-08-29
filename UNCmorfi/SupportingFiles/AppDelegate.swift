//
//  AppDelegate.swift
//  UNCmorfi
//
//  Created by George Alegre on 4/3/17.
//
//  LICENSE is at the root of this project's repository.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        //Setup notifications
//        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]){
//            granted, error in
//        }
        
        //Setup background periodic time
        //UIApplication.shared.setMinimumBackgroundFetchInterval(5 * 60)
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        URLSessionBackground.finishHandlers[identifier] = completionHandler
        //URLSessionBackground.finishHandler = completionHandler
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //TODO for now testing
        NSLog("Background fetch ...")
        if let reservationLogin = ReservationLogin.load(code: "0475F51147F75D8"){
            UNCComedor.api.getReservation(with: reservationLogin, doInBackground: true){
                result in
                let (resultText, redoLogin) = self.reservationResult(result)
                if resultText != nil {
                    self.fireNotification(body: resultText!)
                }
                DispatchQueue.main.async {
                    completionHandler(redoLogin ? .noData : .newData)
                }
            }
        } else {
            NSLog("completion call b)")
            completionHandler(.noData)
        }
        
        
    }
    
    private func fireNotification(body:String){
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = "Reservan2"
            content.body = body
            content.sound = UNNotificationSound.default()
            
            //notification trigger can be based on time, calendar or location
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval:1.0, repeats: false)
            
            //create request to display
            let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
            
            //add request to notification center
            UNUserNotificationCenter.current().add(request) { (error) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
        }
    }
    
    private func reservationResult(_ result:Result<ReservationStatus>) -> (String?,Bool){
        let resultText:String?
        var redoLogin = false
        switch result {
        case let .success(reservationStatus):
            switch reservationStatus.reservationResult {
            case .reserved?:
                resultText = "balance.reservation.reserved.label".localized()
            case .redoLogin?, .invalid?:
                resultText = "balance.reservation.redoLogin.label".localized()
                redoLogin = true
            case .unavailable?, .soldout?, .empty?, nil:
                //resultText = "balance.reservation.unavailable.label".localized()
                resultText = nil
            }
        case .failure(_):
            resultText = "balance.reservation.error.label".localized()
        }
        return (resultText, redoLogin)
    }

}
