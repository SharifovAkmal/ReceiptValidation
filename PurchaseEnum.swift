import Foundation

enum receiptErrorStatus: Int {
    case invalidJson = 21000
    case invalidReceiptDataProperty = 21002
    case authenticationError = 21003
    case commonSecretKeyMisMatch = 21004
    case receiptServerNotWorking = 21005
    case invalidReceiptForProduction = 21007
    case invalidReceiptForSandbox = 21008
    case unknownError = 21010
}
