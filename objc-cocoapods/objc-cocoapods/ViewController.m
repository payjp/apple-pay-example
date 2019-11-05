//
//  ViewController.m
//  objc-cocoapods
//
//  Created by k@binc.jp on 10/20/16.
//  Copyright © 2016 PAY.JP. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@import PassKit;
@import PAYJP;

@interface ViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *amountField;
@property (nonatomic, weak) IBOutlet UITextView *responseText;
@property (nonatomic, weak) IBOutlet UIView *buttonArea;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
    [button addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonArea insertSubview:button atIndex:0];
}

- (void)pay {
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    request.currencyCode = @"JPY";
    request.countryCode = @"JP";
    request.merchantIdentifier = ApplePayMerchantID;
    
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.amountField.text];
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"PAY.JP TEST ITEM" amount:amount];
    request.paymentSummaryItems = @[item];
    request.supportedNetworks = [PKPaymentRequest availableNetworks];
    request.merchantCapabilities = PKMerchantCapability3DS;
    request.requiredBillingAddressFields = PKAddressFieldPostalAddress;
    
    PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
    PAYAPIClient *apiClient = PAYAPIClient.sharedClient;
    [apiClient createTokenWith:payment.token completionHandler:^(PAYToken *token, NSError *error) {
        if (!token) {
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        
        NSLog(@"%@", token);
        completion(PKPaymentAuthorizationStatusSuccess);
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"call delegate paymentAuthorizationViewControllerDidFinish:");
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
