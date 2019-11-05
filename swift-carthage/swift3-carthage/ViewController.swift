import UIKit
import PassKit

import PAYJP

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var responseText: UITextView!
    @IBOutlet weak var buttonArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var button: UIButton
        if #available(iOS 9.0, *) {
            button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        } else {
            button = UIButton(frame: buttonArea.frame)
            let image = UIImage(named: "ApplePayBTN_32pt__black_textLogo_")
            button.setImage(image, for: .normal)
        }
        
        button.addTarget(self, action: #selector(pay), for: UIControl.Event.touchUpInside)
        buttonArea.insertSubview(button, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if checkApplePayAvaliable() {
            checkPaymentNetworksAvaliable(usingNetworks: supportedPaymentNetworks)
        }
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard let amount = currentAmount?.stringValue else { return }
        
        let apiClient = APIClient.shared
        apiClient.createToken(with: payment.token) { (result) in
            switch result {
            case .success(let token):
                let card = token.card
                print("pay amount: \(amount), card: ***\(card.last4Number) token: \(token.identifer)")
                completion(.success)
                // handle token object and send back to your server.
                // https://pay.jp/docs/charge
            case .failure(let error):
                print(error)
                completion(.failure)
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func pay() {
        guard let amount = currentAmount else {
            return
        }
        
        // make an ApplePay request
        let request = PKPaymentRequest()
        request.currencyCode = "JPY"
        request.countryCode = "JP"
        request.merchantIdentifier = appleMerchantID
        
        let item = PKPaymentSummaryItem(label: "PAY.JP TEST ITEM", amount: amount)
        request.paymentSummaryItems = [item]
        request.supportedNetworks = supportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.requiredBillingAddressFields = PKAddressField.postalAddress
        
        if let vc = PKPaymentAuthorizationViewController(paymentRequest: request) {
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            if #available(iOS 10.0, *) {
                return PKPaymentRequest.availableNetworks()
            } else {
                return [.visa, .masterCard, .amex]
            }
        }
    }
    
    private var currentAmount: NSDecimalNumber? {
        get { return NSDecimalNumber(string: amountField.text) }
    }
    
    private func checkApplePayAvaliable() -> Bool {
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            let alertController = UIAlertController(
                title: "エラー",
                message: "このデバイスはApple Payに対応していません",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            buttonArea.isHidden = true
            
            return false
        }
        return true
    }
    
    private func checkPaymentNetworksAvaliable(usingNetworks networks: [PKPaymentNetwork]) {
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks) {
            let alertController = UIAlertController(
                title: "決済方法が登録されていません",
                message: "今すぐ決済方法を登録しますか？",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
                if #available(iOS 8.3, *) {
                    PKPassLibrary().openPaymentSetup()
                }
            }))
            alertController.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}



