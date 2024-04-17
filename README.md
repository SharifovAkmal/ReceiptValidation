# IN-APP PURCHASE RECEIPT VALIDATION

This repository contains Swift code for validating in-app purchase receipts and handling subscription functionality in iOS applications. The code includes an extension of a view controller (`PurchaseViewController`) with functions for receipt validation and providing functionality related to in-app purchases.

## FEATURES

- **Receipt Validation**: Validates the in-app purchase receipt using the App Store receipt and sends it to the server for verification.
- **Subscription Management**: Parses receipt data to determine subscription status, expiration dates, and auto-renewal status.
- **Date Formatting**: Formats purchase and expiration dates for display and checks subscription validity based on the current date.

## USAGE

To use the code in your iOS application:

1. Add the `PurchaseViewController` extension to your project.
2. Call the `receiptValidation` method with the appropriate URL for receipt validation.
3. Implement the `provideFunctions` method to handle receipt data and subscription functionality.

## DEPENDENCIES

- **Alamofire**: Used for making network requests to the server for receipt validation.

## REQUIREMENTS

- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+

## LICENSE

This code is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
