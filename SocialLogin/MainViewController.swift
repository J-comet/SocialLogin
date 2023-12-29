//
//  MainViewController.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/28/23.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    private let authButton = {
        let button = UIButton()
        button.setTitle("생체인증 버튼", for: .normal)
        button.backgroundColor = .link
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        
        view.addSubview(authButton)
        authButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        authButton.addTarget(self, action: #selector(faceIDButtonClicked), for: .touchUpInside)
    }

    @objc func faceIDButtonClicked(_ sender: UIButton) {
        AuthenticaionManager.shared.auth()
    }
}
