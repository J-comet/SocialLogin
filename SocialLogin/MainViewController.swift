//
//  MainViewController.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/28/23.
//

import UIKit
import SnapKit

/**
 Xcode 15 변화된 점
  - 자동완성
  - 성능
  - 아카이브 (출시)
  - Github 방법
  - Asset Catalog 기능 추가
    ex) imageView.image = UIImage(name: "apple") -> imageView.image = .apple
  - String Catalog 추가 이전에 사용하던 로컬라이징 방식은 레거시로 변경
    기존에 레거시를 간편하게 마이그레이션 가능 Edit -> Convert -> To String Catalog
 */

/**
  Build Configureation : Debug Release / ex) 유료버전
 */

/**
 앱스토어에서 리젝당했을 때 크래시파일을 전달 받은 경우 해당 파일을 분석하는 방법
 AppStore Reject App CrashLog .txt File
 .txt -> .crash
 Device and Simulator > View Console Log > Open Xcode Project
 */

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
