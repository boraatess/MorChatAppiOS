//
//  SupportViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI
import MessageUI

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
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileHeader.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        profileHeader.configure(with: "menu_help".localized, image: "")

        tableView.register(FAQHeaderView.self, forHeaderFooterViewReuseIdentifier: FAQHeaderView.identifier)
        tableView.register(FAQTableViewCell.self,
                           forCellReuseIdentifier: FAQTableViewCell.identifier)
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let label = UILabel()
        label.frame = CGRect(x: 16, y: 10, width: 300, height: 30)
        label.textColor = .purple
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "faq_title".localized
        titleView.addSubview(label)
        tableView.tableHeaderView = titleView
        
        setupContactFooterView()
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupContactFooterView() {
        // Table footer width uses main view's bounds since table is grouped
        let frameWidth = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: frameWidth, height: 160))
        
        let titleLabel = UILabel()
        titleLabel.text = "faq_contact".localized
        titleLabel.textColor = .purple
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 30
        
        let iconImageView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconImageView.tintColor = .systemPurple
        
        let emailTitleLabel = UILabel()
        emailTitleLabel.text = "E-Posta"
        emailTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let emailLabel = UILabel()
        emailLabel.text = "destek@morchat.com"
        emailLabel.textColor = .gray
        emailLabel.font = .systemFont(ofSize: 16)
        
        footerView.addSubview(titleLabel)
        footerView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(emailTitleLabel)
        containerView.addSubview(emailLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(90)
        }
        
        iconContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        emailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.top).offset(6)
            make.left.equalTo(iconContainer.snp.right).offset(16)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTitleLabel.snp.bottom).offset(4)
            make.left.equalTo(emailTitleLabel)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contactTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        tableView.tableFooterView = footerView
    }
    
    @objc private func contactTapped() {
        let email = "destek@morchat.com"
        if MFMailComposeViewController.canSendMail() {
            let mailContext = MFMailComposeViewController()
            mailContext.mailComposeDelegate = self
            mailContext.setToRecipients([email])
            mailContext.setSubject("MorChat Destek / İletişim")
            present(mailContext, animated: true)
        } else if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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

extension SupportViewController: UITableViewDelegate, UITableViewDataSource, FAQHeaderViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return faqItems[section].isExpanded ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FAQTableViewCell.identifier,
            for: indexPath
        ) as? FAQTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: faqItems[indexPath.section].answer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FAQHeaderView.identifier) as? FAQHeaderView else { return nil }
        let item = faqItems[section]
        header.configure(title: item.question, section: section, isExpanded: item.isExpanded)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func headerTapped(section: Int) {
        let isExpanded = !faqItems[section].isExpanded
        faqItems[section].isExpanded = isExpanded
        
        // Okun dönüş animasyonunu ve köşe yuvarlatmalarını header üzerinde canlı güncelle
        if let header = tableView.headerView(forSection: section) as? FAQHeaderView {
            header.configure(title: faqItems[section].question, section: section, isExpanded: isExpanded)
        }
        
        // Tablo satırını ekleyerek/sildiğimizde pürüzsüz animasyon alacağız
        let indexPath = IndexPath(row: 0, section: section)
        
        tableView.performBatchUpdates({
            if isExpanded {
                tableView.insertRows(at: [indexPath], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }, completion: nil)
    }
}


extension SupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

#Preview {
    SupportViewController().asPreview()
}
