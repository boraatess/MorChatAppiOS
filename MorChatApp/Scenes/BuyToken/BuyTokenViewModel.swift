import Foundation

struct TokenPackage {
    let title: String
    let price: String
    let discountText: String?
    let productId: String
    let coinAmount: Int
}

protocol BuytokenviewModelInputProtocol: AnyObject {
    func fetchTokenPackages()
    func purchase(package: TokenPackage)
    func restorePurchases()
}

protocol BuytokenviewModelOutputProtocol: AnyObject {
    func didUpdateLoading(_ isLoading: Bool)
    func didFetchTokenPackages(_ packages: [TokenPackage])
    func didCompletePurchase(message: String)
    func didFail(message: String)
}

final class BuyTokenViewModel: BuytokenviewModelInputProtocol {

    weak var output: BuytokenviewModelOutputProtocol?

    func fetchTokenPackages() {
        output?.didUpdateLoading(true)

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let products = try await CoinManager.shared.fetchProducts()
                let packages = products.map {
                    TokenPackage(
                        title: $0.title,
                        price: $0.displayPrice,
                        discountText: $0.badgeText,
                        productId: $0.productId,
                        coinAmount: $0.coinAmount
                    )
                }
                self.output?.didFetchTokenPackages(packages)
            } catch {
                self.output?.didFail(message: error.localizedDescription)
            }

            self.output?.didUpdateLoading(false)
        }
    }

    func purchase(package: TokenPackage) {
        output?.didUpdateLoading(true)

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let result = try await CoinManager.shared.purchase(productId: package.productId)
                switch result {
                case .success(let purchasedProduct):
                    let message = String(
                        format: "iap_purchase_success_message".localized,
                        purchasedProduct.coinAmount
                    )
                    self.output?.didCompletePurchase(message: message)
                case .pending:
                    self.output?.didCompletePurchase(message: "iap_purchase_pending_message".localized)
                case .cancelled:
                    break
                }
            } catch {
                self.output?.didFail(message: error.localizedDescription)
            }

            self.output?.didUpdateLoading(false)
        }
    }

    func restorePurchases() {
        output?.didUpdateLoading(true)

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await CoinManager.shared.restorePurchases()
                self.output?.didCompletePurchase(message: "iap_restore_success_message".localized)
            } catch {
                self.output?.didFail(message: error.localizedDescription)
            }

            self.output?.didUpdateLoading(false)
        }
    }
}
