import UIKit
import PAYJP

// TODO: SET YOUR Apple Merchant ID
let appleMerchantID = "merchant.jp.pay"
let PAYJPPublicKey = "pk_test_d5b6d618c26b898d5ed4253c"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PAYJPSDK.publicKey = PAYJPPublicKey
        
        return true
    }
}
