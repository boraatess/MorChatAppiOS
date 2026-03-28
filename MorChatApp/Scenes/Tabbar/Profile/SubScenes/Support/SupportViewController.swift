//
//  SupportViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

struct FAQItem {
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

final class SupportViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private var faqItems: [FAQItem] = []
    
    private let profileHeader = ProfileHeaderView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileHeader.delegate = self
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        title = "menu_help".localized
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(profileHeader)
        profileHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileHeader.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        profileHeader.configure(with: "menu_help".localized, image: "")

        
        tableView.register(FAQTableViewCell.self,
                           forCellReuseIdentifier: FAQTableViewCell.identifier)
        tableView.register(ContactTableViewCell.self,
                           forCellReuseIdentifier: ContactTableViewCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureData() {
        faqItems = [
            FAQItem(question: "faq_q1".localized,
                    answer: "faq_a1".localized),
            
            FAQItem(question: "faq_q2".localized,
                    answer: "faq_a2".localized),
            
            FAQItem(question: "faq_q3".localized,
                    answer: "faq_a3".localized),
            
            FAQItem(question: "faq_q4".localized,
                    answer: "faq_a4".localized),
            
            FAQItem(question: "faq_q5".localized,
                    answer: "faq_a5".localized),
            
            FAQItem(question: "faq_q6".localized,
                    answer: "faq_a6".localized)
        ]

    }
}

extension SupportViewController: ProfileHeaderViewDelegate {
    
    func didTapBack() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension SupportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? faqItems.count : 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FAQTableViewCell.identifier,
                for: indexPath
            ) as! FAQTableViewCell
            
            cell.configure(with: faqItems[indexPath.row])
            return cell
        } else {
            return tableView.dequeueReusableCell(
                withIdentifier: ContactTableViewCell.identifier,
                for: indexPath
            )
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 0 else { return }
        
        faqItems[indexPath.row].isExpanded.toggle()
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.frame = CGRect(x: 16, y: 0, width: 300, height: 10)
        label.textColor = .purple
        label.font = .boldSystemFont(ofSize: 14)
        
        if section == 0 {
            label.text = "faq_title".localized
        }
        else {
            label.text = "faq_contact".localized
        }

        
        view.addSubview(label)
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
}
