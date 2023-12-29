//
//  MainViewController.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/28/23.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }

    @IBAction func faceIDButtonClicked(_ sender: UIButton) {
        AuthenticaionManager.shared.auth()
    }
}
