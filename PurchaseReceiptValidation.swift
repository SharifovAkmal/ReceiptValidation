//
//  PurchaseReceiptValidation.swift
//  CardiaI
//
//  Created by 맥북 on 3/26/24.
//

import Foundation
import Alamofire

extension PurchaseViewController {
    func receiptValidation(url: String) {
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            do {
                let receiptData = try Data(contentsOf: receiptUrl)
                
                let requestContents = [
                    "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
                    //Shared code from appstoreconnect.com
                    "password": "sharedCode"
                ]
                
                AF.request(url, method: .post, parameters: requestContents, encoding: JSONEncoding.default, headers: ["content-type": "application/json"])
                    .validate()
                    .responseData { response in
                        debugPrint(response)
                        switch response.result {
                        case .success(let data):
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                if let json = json {
                                    if let status = json["status"] as? Int,
                                       status == receiptErrorStatus.invalidReceiptForProduction.rawValue {
                                        self.receiptValidation(url: "https://sandbox.itunes.apple.com/verifyReceipt")
                                        return
                                    }
                                    
                                    if let pendingRenewalInfo = json["pending_renewal_info"] as? [[String: Any]] {
                                        if let firstRenewalInfo = pendingRenewalInfo.first {
                                            if let autoRenewStatus = firstRenewalInfo["auto_renew_status"] as? String {
                                                if autoRenewStatus == "1" {
                                                    print("IAP Auto Renewable Status TRUE")
                                                }else if autoRenewStatus == "0" {
                                                    print("IAP Auto Renewable Status FALSE")
                                                }
                                            } else {
                                                print("Not Valid 'auto_renew_status' found in JSON")
                                            }
                                            
                                            if let originalTransactionId = firstRenewalInfo["original_transaction_id"] as? String {
                                                print("Pending renewal orginal transaction id: ", originalTransactionId)
                                            }
                                        }
                                    }
                                    
                                    if let latestReceiptInfo = json["latest_receipt_info"] as? [[String: Any]] {
                                        if let firstInfo = latestReceiptInfo.first {
                                            if let transactionId = firstInfo["transaction_id"] as? String {
                                                print("Latest Reciept Transaction Id: ", transactionId)
                                            }
                                            
                                            if let originalTransactionId = firstInfo["original_transaction_id"] as? String {
                                                print("Latest Reciept Original Transaction Id: ", originalTransactionId)
                                            }
                                        }
                                    }
                                    
                                    if let receipts = json["receipt"] as? [String: Any] {
                                        self.provideFunctions(receipts: receipts)
                                    }
                                }else {
                                    print("Response is not a valid JSON")
                                }
                            } catch {
                                print("Error parsing JSON: \(error)")
                            }
                        case .failure(let error):
                            print("Request failed  with error: \(error)")
                        }
                    }
            }catch {
                print("Error reading receipt data: \(error)")
            }
        }else {
            print("Receipt URL not found")
        }
    }
    
    func provideFunctions(receipts: [String: Any]) {
        let in_apps = receipts["in_app"] as! Array<Dictionary<String, AnyObject>>
        
        var latestExpireDate: Int = 0
        var purchaseDateString: String = ""
        var expiresDateString: String = ""
        
        for in_app in in_apps {
            let receiptExpireDateMs = Int(in_app["expires_date_ms"] as? String ?? "") ?? 0
            let receiptExpireDateS = receiptExpireDateMs / 1000
            if receiptExpireDateS > latestExpireDate {
                latestExpireDate = receiptExpireDateS
                
                purchaseDateString = in_app["purchase_date"] as? String ?? ""
                expiresDateString = in_app["expires_date"] as? String ?? ""
            }
        }
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        //Convert string date -> Date format
        if let expiresDate = dateFormatter.date(from: expiresDateString),
           let purchaseDate = dateFormatter.date(from: purchaseDateString) {
            
            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
            
            let formattedCurrentDate = dateFormatter.string(from: currentDate)
            let formattedExpiresDate = dateFormatter.string(from: expiresDate)
            let formattedPurchaseDate = dateFormatter.string(from: purchaseDate)
            
            if expiresDate < currentDate {
                print("Purchase valid: ", false)
            }else {
                print("Purchase valid: ", true)
            }
            
            print("Latest Subscription Expires Date: ", formattedExpiresDate)
            print("Latest Purchased Date: ", formattedPurchaseDate)
        }else {
            // Handle the case when parsing fails
            print("Failed to parse date strings.")
        }
    }
}
