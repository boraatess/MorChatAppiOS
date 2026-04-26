//
//  BlockedUsersVC.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit


class BlockedUsersVC: UIViewController {
    
    private let profileHeader = ProfileHeaderView()
    private let tableView = UITableView(frame: .zero, style: .grouped)

    private let viewModel: BlockedUserViewModelProtocol
    private var blockedUsers: [BlockedUserUIModel] = []
    
    init(viewModel: BlockedUserViewModelProtocol = BlockedUserViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let vm = viewModel as? BlockedUserViewModel {
            vm.output = self
        }
        viewModel.fetchBlockedUsers()
    }
    
    
}

extension BlockedUsersVC: BlockedUsersOutputProtocol {
    func didLoadBlockedUsers(_ users: [BlockedUserUIModel]) {
        self.blockedUsers = users
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func didUnblockSuccessfully(at index: Int) {
        self.blockedUsers.remove(at: index)
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

extension BlockedUsersVC: ProfileHeaderViewDelegate {
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension BlockedUsersVC {
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(profileHeader)
        profileHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        profileHeader.delegate = self
        profileHeader.configure(with: "Engellenen Kullanıcılar", image: "")

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileHeader.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "blockedCell")
        
        
        
    }
    
    
}

extension BlockedUsersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedCell", for: indexPath)
        let user = blockedUsers[indexPath.row]
        cell.textLabel?.text = user.name
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.unblockUser(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Engeli Kaldır"
    }
}


#Preview {
    BlockedUsersVC().asPreview()
    
    
}
