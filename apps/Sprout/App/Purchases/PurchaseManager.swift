import Foundation
import Observation
import StoreKit
import SproutKit

/// Wraps StoreKit 2 for the single one-time unlock IAP.
/// Configure the matching product in App Store Connect with this identifier.
@MainActor
@Observable
final class PurchaseManager {
    static let unlockProductID = "com.sprout.unlock"

    private(set) var product: Product?
    private(set) var isPurchased: Bool = false
    private(set) var lastError: String?

    private let entitlement: EntitlementStore
    private var updatesTask: Task<Void, Never>?

    init(entitlement: EntitlementStore) {
        self.entitlement = entitlement
        self.isPurchased = entitlement.current() == .paid
        updatesTask = Task { await listenForUpdates() }
    }

    deinit { updatesTask?.cancel() }

    func load() async {
        do {
            let products = try await Product.products(for: [Self.unlockProductID])
            self.product = products.first
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    grantPaid()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func restore() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == Self.unlockProductID {
                grantPaid()
                return
            }
        }
    }

    private func grantPaid() {
        entitlement.set(.paid)
        isPurchased = true
    }

    private func listenForUpdates() async {
        for await update in Transaction.updates {
            if case .verified(let tx) = update, tx.productID == Self.unlockProductID {
                grantPaid()
                await tx.finish()
            }
        }
    }
}
