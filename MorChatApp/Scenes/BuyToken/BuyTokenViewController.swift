import Foundation
import UIKit
import SnapKit
import SwiftUI

final class BuyTokenViewController: UIViewController {

    private let viewModel = BuyTokenViewModel()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    private var packages: [TokenPackage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradient()
        setupUI()

        viewModel.output = self
        viewModel.fetchTokenPackages()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCoinBalanceChange),
            name: .coinBalanceDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "iap_screen_title".localized
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func restoreTapped() {
        viewModel.restorePurchases()
    }

    @objc private func handleCoinBalanceChange() {
        tableView.reloadData()
    }
}

extension BuyTokenViewController: BuytokenviewModelOutputProtocol {

    func didUpdateLoading(_ isLoading: Bool) {
        tableView.isUserInteractionEnabled = !isLoading
        navigationItem.rightBarButtonItem?.isEnabled = !isLoading
        emptyStateLabel.isHidden = isLoading || !packages.isEmpty

        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func didFetchTokenPackages(_ packages: [TokenPackage]) {
        self.packages = packages
        emptyStateLabel.isHidden = !packages.isEmpty
        tableView.reloadData()
    }

    func didCompletePurchase(message: String) {
        showAlert(title: "iap_success_title".localized, message: message)
    }

    func didFail(message: String) {
        emptyStateLabel.isHidden = !packages.isEmpty
        showAlert(title: "iap_error_title".localized, message: message)
    }
}

extension BuyTokenViewController {

    private func setupUI() {
        title = "iap_screen_title".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "iap_restore_button".localized,
            style: .plain,
            target: self,
            action: #selector(restoreTapped)
        )

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
        }

        tableView.register(BuyTokenCell.self, forCellReuseIdentifier: BuyTokenCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        emptyStateLabel.text = "iap_products_empty".localized
        emptyStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 48 / 255, green: 20 / 255, blue: 90 / 255, alpha: 1).cgColor,
            UIColor(red: 95 / 255, green: 30 / 255, blue: 150 / 255, alpha: 1).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension BuyTokenViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        packages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BuyTokenCell.identifier,
            for: indexPath
        ) as! BuyTokenCell

        cell.configure(with: packages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.purchase(package: packages[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        104
    }
}

#Preview {
    BuyTokenViewController().asPreview()
}
