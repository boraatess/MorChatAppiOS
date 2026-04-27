import Foundation
import StoreKit
import GoogleMobileAds
import UIKit
import FirebaseAuth

extension Notification.Name {
    static let coinBalanceDidChange = Notification.Name("coinBalanceDidChange")
}

struct CoinProduct {
    let productId: String
    let coinAmount: Int
    let title: String
    let displayPrice: String
    let badgeText: String?
}

enum CoinPurchaseResult {
    case success(CoinProduct)
    case pending
    case cancelled
}

enum CoinManagerError: LocalizedError {
    case paymentsUnavailable
    case productUnavailable
    case unknownProduct
    case verificationFailed
    case userNotLoggedIn

    var errorDescription: String? {
        switch self {
        case .paymentsUnavailable:
            return "iap_error_payments_unavailable".localized
        case .productUnavailable:
            return "iap_error_product_unavailable".localized
        case .unknownProduct:
            return "iap_error_unknown_product".localized
        case .verificationFailed:
            return "iap_error_verification_failed".localized
        case .userNotLoggedIn:
            return "iap_error_login_required".localized
        }
    }
}

@MainActor
final class CoinManager {

    static let shared = CoinManager()

    private struct ProductDefinition {
        let productId: String
        let coinAmount: Int
        let badgeText: String?

        var title: String {
            String(format: "iap_token_amount".localized, coinAmount)
        }
    }

    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    private let productDefinitions: [ProductDefinition] = [
        ProductDefinition(productId: "com.morchat.coins.1", coinAmount: 1, badgeText: nil),
        ProductDefinition(productId: "com.morchat.coins.5", coinAmount: 5, badgeText: nil),
        ProductDefinition(productId: "com.morchat.coins.10", coinAmount: 10, badgeText: "iap_badge_popular".localized),
        ProductDefinition(productId: "com.morchat.coins.20", coinAmount: 20, badgeText: "iap_badge_popular".localized),
        ProductDefinition(productId: "com.morchat.coins.100", coinAmount: 100, badgeText: "iap_badge_popular".localized)
    ]

    private var rewardedAd: RewardedAd?
    private var productsByID: [String: Product] = [:]
    private var transactionUpdatesTask: Task<Void, Never>?

    private init() {}

    func start() {
        guard transactionUpdatesTask == nil else { return }

        loadRewardedAd()

        transactionUpdatesTask = Task { [weak self] in
            guard let self else { return }
            await self.observeTransactionUpdates()
        }

        Task { [weak self] in
            guard let self else { return }
            _ = try? await self.fetchProducts()
            await self.processUnfinishedTransactions()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    // MARK: - Google Rewarded Ads

    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            if let error {
                print("Rewarded ad failed to load: \(error.localizedDescription)")
                return
            }

            self?.rewardedAd = ad
        }
    }

    func showRewardedAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let ad = rewardedAd else {
            loadRewardedAd()
            completion(false)
            return
        }

        ad.present(from: viewController) {
            let reward = ad.adReward
            FirestoreService.shared.addCoins(amount: Int(truncating: reward.amount)) { error in
                DispatchQueue.main.async {
                    self.loadRewardedAd()

                    if let error {
                        print("Error adding coins after ad: \(error.localizedDescription)")
                        completion(false)
                        return
                    }

                    NotificationCenter.default.post(name: .coinBalanceDidChange, object: nil)
                    completion(true)
                }
            }
        }
    }

    // MARK: - StoreKit

    func fetchProducts() async throws -> [CoinProduct] {
        let ids = productDefinitions.map(\.productId)
        let storeProducts = try await Product.products(for: ids)

        productsByID = Dictionary(uniqueKeysWithValues: storeProducts.map { ($0.id, $0) })

        return productDefinitions.compactMap { definition in
            guard let product = productsByID[definition.productId] else { return nil }
            return CoinProduct(
                productId: definition.productId,
                coinAmount: definition.coinAmount,
                title: definition.title.isEmpty ? product.displayName : definition.title,
                displayPrice: product.displayPrice,
                badgeText: definition.badgeText
            )
        }
    }

    func purchase(productId: String) async throws -> CoinPurchaseResult {
        guard AuthenticatedUserState.hasCurrentUser else {
            throw CoinManagerError.userNotLoggedIn
        }

        guard AppStore.canMakePayments else {
            throw CoinManagerError.paymentsUnavailable
        }

        let product = try await productForPurchase(productId: productId)
        let purchaseResult = try await product.purchase()

        switch purchaseResult {
        case .success(let verificationResult):
            let transaction = try verifiedTransaction(from: verificationResult)
            let purchasedProduct = try await grantCoins(for: transaction)
            await transaction.finish()
            return .success(purchasedProduct)
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            throw CoinManagerError.productUnavailable
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await processUnfinishedTransactions()
    }

    private func productForPurchase(productId: String) async throws -> Product {
        if let product = productsByID[productId] {
            return product
        }

        _ = try await fetchProducts()

        guard let product = productsByID[productId] else {
            throw CoinManagerError.productUnavailable
        }

        return product
    }

    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            guard !Task.isCancelled else { return }

            do {
                let transaction = try verifiedTransaction(from: result)
                _ = try await grantCoins(for: transaction)
                await transaction.finish()
            } catch {
                print("Transaction update handling failed: \(error.localizedDescription)")
            }
        }
    }

    private func processUnfinishedTransactions() async {
        for await result in Transaction.unfinished {
            do {
                let transaction = try verifiedTransaction(from: result)
                _ = try await grantCoins(for: transaction)
                await transaction.finish()
            } catch {
                print("Unfinished transaction handling failed: \(error.localizedDescription)")
            }
        }
    }

    private func grantCoins(for transaction: Transaction) async throws -> CoinProduct {
        guard let definition = productDefinitions.first(where: { $0.productId == transaction.productID }) else {
            throw CoinManagerError.unknownProduct
        }

        let wasGranted = try await withCheckedThrowingContinuation { continuation in
            FirestoreService.shared.applyCoinPurchase(
                transactionId: String(transaction.id),
                productId: definition.productId,
                amount: definition.coinAmount
            ) { result in
                continuation.resume(with: result)
            }
        }

        let product = productsByID[definition.productId]
        let coinProduct = CoinProduct(
            productId: definition.productId,
            coinAmount: definition.coinAmount,
            title: definition.title,
            displayPrice: product?.displayPrice ?? "",
            badgeText: definition.badgeText
        )

        if wasGranted {
            NotificationCenter.default.post(name: .coinBalanceDidChange, object: nil)
        }

        return coinProduct
    }

    private func verifiedTransaction<T>(from result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signedType):
            return signedType
        case .unverified:
            throw CoinManagerError.verificationFailed
        }
    }
}

private enum AuthenticatedUserState {
    static var hasCurrentUser: Bool {
        Auth.auth().currentUser != nil
    }
}
