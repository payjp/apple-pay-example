import UIKit
import PAYJP

// TODO: SET YOUR Apple Merchant ID
let appleMerchantID = "merchant.jp.pay.example2"
let PAYJPPublicKey = "pk_test_0383a1b8f91e8a6e3ea0e2a9"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PAYJPSDK.publicKey = PAYJPPublicKey
        
        return true
    }
}
