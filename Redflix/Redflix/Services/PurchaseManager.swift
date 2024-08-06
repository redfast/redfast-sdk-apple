//
//  PurchaseManager.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 18.06.2024.
//

import Foundation
import StoreKit

protocol PurchaseManagerProtocol {
    func loadProductsIfNeeded() async throws
    func purchase(_ productId: String) async throws
}

enum ProductSKU: String, CaseIterable {
    case diamond
    case platinum
    case annualSubscription
    
    var productId: String {
        switch self {
        case .diamond:
            return "com.redfast.redflix.diamond"
        case .platinum:
            return "com.redfast.redflix.platinum"
        case .annualSubscription:
            return "13VOZNVQ"
        }
    }
}

final class PurchaseManager: PurchaseManagerProtocol {
    private let productIds = ProductSKU.allCases.map {
        $0.productId
    }
    private var products: [Product] = []
    private var productsLoaded = false
    
    private var purchasedProductIDs: Set<String> = []
    private var updates: Task<Void, Never>? = nil
    
    init() {
        self.updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }

    func loadProductsIfNeeded() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    func purchase(_ sku: String) async throws {
        let productId = ProductSKU(rawValue: sku)?.productId ?? sku
        guard let product = products.first(where: { $0.id == productId }) else {
            print("Can't find product with id: \(productId)")
            return
        }
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            print("Successful purhcase")
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            print("Successful unverified purhcase: \(error.localizedDescription)")
            break
        case .pending:
            print("Pending purchase")
            break
        case .userCancelled:
            print("Canceled purchase")
            break
        @unknown default:
            break
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
    
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
               continue
            }
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
            // Notify your entitlement service about update if needed
        }
    }
}
