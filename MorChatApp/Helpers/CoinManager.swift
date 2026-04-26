import Foundation
import StoreKit
import GoogleMobileAds

class CoinManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = CoinManager()
    
    private var rewardedAd: RewardedAd?
    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313" // Test ID
    
    // IAP
    private var products: [SKProduct] = []
    private let coinProductIDs: Set<String> = ["com.morchat.coins.100", "com.morchat.coins.500", "com.morchat.coins.1000"]
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
        loadRewardedAd()
    }
    
    // MARK: - Google Rewarded Ads
    
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("❌ Rewarded ad failed to load: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            print("✅ Rewarded ad loaded.")
        }
    }
    
    func showRewardedAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if let ad = rewardedAd {
            ad.present(from: viewController) {
                let reward = ad.adReward
                print("💎 User earned reward: \(reward.amount) \(reward.type)")
                
                // Add coins to user account
                FirestoreService.shared.addCoins(amount: Int(truncating: reward.amount)) { error in
                    if let error = error {
                        print("❌ Error adding coins after ad: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        } else {
            print("⚠️ Ad wasn't ready")
            loadRewardedAd()
            completion(false)
        }
    }
    
    // MARK: - In-App Purchases (IAP)
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: coinProductIDs)
        request.delegate = self
        request.start()
    }
    
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func buyProduct(productId: String) {
        if let product = products.first(where: { $0.productIdentifier == productId }) {
            buyProduct(product: product)
        } else {
            print("⚠️ Product not found: \(productId). Fetching again...")
            fetchProducts()
        }
    }
    
    // SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for product in response.products {
            print("🛒 Found product: \(product.localizedTitle) \(product.price)")
        }
    }
    
    // SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("✅ Purchase completed: \(transaction.payment.productIdentifier)")
        
        let amount = getCoinAmount(for: transaction.payment.productIdentifier)
        FirestoreService.shared.addCoins(amount: amount) { error in
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            print("❌ Purchase failed: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func getCoinAmount(for productID: String) -> Int {
        switch productID {
        case "com.morchat.coins.100": return 100
        case "com.morchat.coins.500": return 500
        case "com.morchat.coins.1000": return 1000
        default: return 0
        }
    }
}
