//
//  BuyTokenViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 21.02.2026.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

class BuyTokenViewController: UIViewController {
    
    private let viewModel = BuyTokenViewModel()
    
    private let tableView = UITableView()
    private var packages: [TokenPackage] = []

    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradient()
        viewModel.output = self
        viewModel.fetchTokenPackages()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Buy Token"
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    
}


extension BuyTokenViewController: BuytokenviewModelOutputProtocol {
    
    func didFetchTokenPackages(_ packages: [TokenPackage]) {
        self.packages = packages
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
    }
    
}

extension BuyTokenViewController {
        
    private func setupUI() {
        title = "Buy Token"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(BuyTokenCell.self, forCellReuseIdentifier: BuyTokenCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 48/255, green: 20/255, blue: 90/255, alpha: 1).cgColor,
            UIColor(red: 95/255, green: 30/255, blue: 150/255, alpha: 1).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
}

extension BuyTokenViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        packages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: BuyTokenCell.identifier,
                                                 for: indexPath) as! BuyTokenCell
        
        cell.configure(with: packages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let package = packages[indexPath.row]
        print("🛒 Buying package: \(package.title)")
        CoinManager.shared.buyProduct(productId: package.productId)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

#Preview {
    BuyTokenViewController().asPreview()
    
}
