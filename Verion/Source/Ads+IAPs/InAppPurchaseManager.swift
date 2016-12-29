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
    func fetchProducts() {
        self.fetchProducts { (products, invalidProductIds) in
            #if DEBUG
                
            #endif
        }
    }
    
    private func fetchProducts(completion: @escaping (_ products: [SKProduct], _ invalidProductIdentifiers: [String]? )->()) {
        
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
