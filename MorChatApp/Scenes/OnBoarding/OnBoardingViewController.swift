//
//  OnBoardingViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation
import UIKit
import SnapKit

class OnBoardingViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let actionButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    
    var onboardingItems: [OnboardingItem] = []
    
    let viewModel = OnboardingViewModel()
    
    private var currentPage = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.output = self
        viewModel.fetchItems()
        setupBackground()
        setupUI()
        setupPages()
    }

    private func setupBackground() {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1).cgColor,
            UIColor(red: 94/255, green: 43/255, blue: 151/255, alpha: 1).cgColor
        ]
        g.frame = view.bounds
        view.layer.insertSublayer(g, at: 0)
    }

    private func setupUI() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        pageControl.numberOfPages = onboardingItems.count
        pageControl.currentPage = 0

        actionButton.setTitle("onboarding_continue".localized, for: .normal)
        actionButton.backgroundColor = .white
        actionButton.setTitleColor(.systemPurple, for: .normal)
        actionButton.layer.cornerRadius = 14

        skipButton.setTitle("onboarding_skip".localized, for: .normal)
        skipButton.setTitleColor(.white, for: .normal)

        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(actionButton)
        view.addSubview(skipButton)

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top).offset(-20)
        }

        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(actionButton.snp.top).offset(-16)
        }

        actionButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(56)
        }

        skipButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.left.equalToSuperview().offset(20)
        }
    }

    @objc private func actionButtonTapped() {
        if currentPage < onboardingItems.count - 1 {
            goToPage(currentPage + 1)
        } else {
            finishOnboarding()
        }
        
    }

    @objc private func skipTapped() {
        finishOnboarding()
    }

    private func goToPage(_ page: Int) {
        let xOffset = CGFloat(page) * view.frame.width
        scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }

    private func finishOnboarding() {
        let loginVC = LoginViewController()
        let nav = BaseNavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)

        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }

    private func updateCurrentPage() {
        currentPage = Int(round(scrollView.contentOffset.x / view.frame.width))
        pageControl.currentPage = currentPage
        actionButton.setTitle(
            currentPage == onboardingItems.count - 1 ? "onboarding_start".localized : "onboarding_continue".localized,
            for: .normal
        )
    }

    
    private func setupPages() {
        var previous: UIView?
        
        onboardingItems.forEach { item in
            let page = OnboardingPageView(item: item)
            scrollView.addSubview(page)
            
            page.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(view)
                if let prev = previous {
                    $0.left.equalTo(prev.snp.right)
                } else {
                    $0.left.equalToSuperview()
                }
            }
            previous = page
        }
        
        previous?.snp.makeConstraints {
            $0.right.equalToSuperview()
        }
        
    }

    
    
}

extension OnBoardingViewController: OnboardingViewModelOutputProtocol {
    
    func configureItems(with items: [OnboardingItem]) {
        self.onboardingItems = items
        
    }
    
}


extension OnBoardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.frame.width))
        pageControl.currentPage = page
        actionButton.setTitle(page == onboardingItems.count - 1 ? "onboarding_start".localized : "onboarding_continue".localized, for: .normal)
    }
    
    
    
}
