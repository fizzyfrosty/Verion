//
//  InAppPurchaseManager.swift
//  Verion
//
//  Created by Simon Chen on 12/29/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class InAppPurchaseManager: NSObject {

    static let sharedInstance: InAppPurchaseManager = {
        let instance = InAppPurchaseManager()
        return instance
    }()
    
    override init() {
        
    }
    
    func addTransactionObserver(){
        RMStore.default().add(self)
    }
    
    func removeTransactionObserver() {
        RMStore.default().remove(self)
    }
    
    // Must fetch products before making purchase
    func fetchProducts(productIds: [String], completion: @escaping (Error?)->()) {
        
        self.fetchProducts(productIds: productIds) { (products, invalidProductIds, error) in
            if error == nil {
                
                // Success, do stuff here
                
                // populate products with array
                
                #if DEBUG
                    print("Successfully fetched products.")
                #endif
            } else {
                // Failed, do anything?
                
                #if DEBUG
                    print("Failed to fetch products.")
                #endif
            }
            
            completion(error)
        }
    }
    
    private func fetchProducts(productIds: [String], completion: @escaping (_ products: [Any]?, _ invalidProductIdentifiers: [Any]?, Error?)->()) {
        
        let productIdsSet = Set.init(productIds)
        
        RMStore.default().requestProducts(productIdsSet, success: { (skProducts, invalidProductIds) in
            // Success
            completion(skProducts, invalidProductIds, nil)
        }, failure: { error in
            // Failed
            completion(nil, nil, error)
        })
    }
    
    func purchaseProduct(productId: String, completion: @escaping (Error?)->()) {
        RMStore.default().addPayment(productId, success: { skPaymentTransaction in
            
            // Success
            completion(nil)
            
        }, failure: { skPaymentTransaction, error in
            
            // Failure
            completion(error)
        })
    }
    
    func restorePurchases(completion: @escaping (_ productIds: [String], Error?)->()) {
        
        var productIds: [String] = []
        
        RMStore.default().restoreTransactions(onSuccess: { transactions in
            // Success
            
            // Retrieve product id from sk transactions
            for transaction in transactions! {
                let skTransaction = transaction as? SKPaymentTransaction
                productIds.append(skTransaction!.payment.productIdentifier)
            }
            
            // Return
            completion(productIds, nil)
            
        }) { (error) in
            // Failed
            completion(productIds, error)
        }
    }
    
}

extension InAppPurchaseManager: RMStoreObserver {
    
    // Product Request
    func storeProductsRequestFinished(_ notification: Notification!) {
        /*
 NSArray *products = notification.rm_products;
 NSArray *invalidProductIdentifiers = notification.rm_invalidProductIdentifiers;
 */
    }
    
    func storeProductsRequestFailed(_ notification: Notification!) {
        // NSError *error = notification.rm_storeError;
    }
    
    // Payment
    func storePaymentTransactionFinished(_ notification: Notification!) {
        /*
        NSString *productIdentifier = notification.rm_productIdentifier;
        SKPaymentTransaction *transaction = notification.rm_transaction;
 */
    }
    
    func storePaymentTransactionFailed(_ notification: Notification!) {
        /*
        NSError *error = notification.rm_storeError;
        NSString *productIdentifier = notification.rm_productIdentifier;
        SKPaymentTransaction *transaction = notification.rm_transaction;*/
    }
    
    // For iOS 8 Only
    func storePaymentTransactionDeferred(_ notification: Notification!) {
        /*
        NSString *productIdentifier = notification.rm_productIdentifier;
        SKPaymentTransaction *transaction = notification.rm_transaction;*/
    }
    
    
    // Restore Purchases
    func storeRestoreTransactionsFinished(_ notification: Notification!) {
        // NSError *error = notification.rm_storeError;
    }
    
    func storeRestoreTransactionsFailed(_ notification: Notification!) {
        /*
        NSArray *transactions = notification.rm_transactions;
        SKPaymentTransaction *trans;*/
    }
    
    
}
