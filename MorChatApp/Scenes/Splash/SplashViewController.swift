//
//  SplashViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {

    private let bgImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gradient")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "splashLogo")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 48
        iv.clipsToBounds = true
        // Tint color no longer needed if it's a full-color app icon
        return iv
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "splash_subtitle".localized
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let gradientLayer = CAGradientLayer()

    // Coordinator burayı set eder
    var onFinish: (() -> Void)?

    private let viewModel: SplashViewModel

    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.output = self
        layout()
        
        viewModel.onFinish = { [weak self] in
            print("✅ vc finished")
            self?.onFinish?()
            
        }
        
        viewModel.start()
        
        // setupGradient() is disabled because we are using bgImageView instead
        setupUI()

        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addParticles()

        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: []) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
        }
                
    }

    private func setupGradient() {

        gradientLayer.colors = [
            UIColor(red: 0.45, green: 0.0, blue: 0.65, alpha: 1).cgColor,
            UIColor(red: 0.95, green: 0.1, blue: 0.55, alpha: 1).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupUI() {
        
        view.addSubview(bgImageView)
        // Make sure it goes behind everything else
        view.sendSubviewToBack(bgImageView)

        logoImageView.image = UIImage(named: "splashLogo")
        logoImageView.contentMode = .scaleAspectFit
        
        view.addSubview(logoImageView)


        view.addSubview(subtitleLabel)
    }


    private func setupConstraints() {
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // Covers the entire screen
        }

        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(220)
        }


        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func addParticles() {

        let emitter = CAEmitterLayer()

        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 2)
        emitter.backgroundColor = UIColor.clear.cgColor

        
        // SMALL PARTICLE
        let smallCell = CAEmitterCell()
        smallCell.birthRate = 4
        smallCell.lifetime = 10
        smallCell.velocity = 30
        smallCell.scale = 0.05
        smallCell.scaleRange = 0.02
        smallCell.emissionRange = .pi
        smallCell.contents = UIImage(named: "sparklerSmall")?.cgImage

        // MEDIUM PARTICLE
        let mediumCell = CAEmitterCell()
        mediumCell.birthRate = 3
        mediumCell.lifetime = 10
        mediumCell.velocity = 40
        mediumCell.scale = 0.08
        mediumCell.scaleRange = 0.03
        mediumCell.emissionRange = .pi
        mediumCell.contents = UIImage(named: "sparklerMedium")?.cgImage

        // GLOW PARTICLE
        let glowCell = CAEmitterCell()
        glowCell.birthRate = 2
        glowCell.lifetime = 12
        glowCell.velocity = 20
        glowCell.scale = 0.12
        glowCell.scaleRange = 0.04
        glowCell.emissionRange = .pi
        glowCell.contents = UIImage(named: "star")?.cgImage

        emitter.emitterCells = [smallCell, mediumCell, glowCell]

        view.layer.addSublayer(emitter)
        
    }

    
    
}


extension SplashViewController: SplashViewModeloutputprotocol {
    
    func didFinish() {
        
        
    }
    
    func goTabbar() {
        self.onFinish?()
        
        
    }
    
}

extension SplashViewController {
    
    func layout() {
        
        view.backgroundColor = .purple
        print("splash...")
        
        
    }
    
}
