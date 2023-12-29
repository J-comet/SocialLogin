//
//  KakaoViewController.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/28/23.
//

import UIKit
import KakaoSDKUser
import SnapKit

final class KakaoViewController: UIViewController {
    
    private let kakaoLoginButton = {
        let button = UIButton()
        button.setTitle("카카오 로그인", for: .normal)
        button.backgroundColor = .systemYellow
        return button
    }()
    
    private let kakaoLogoutButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.backgroundColor = .link
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(kakaoLoginButton)
        view.addSubview(kakaoLogoutButton)
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        kakaoLogoutButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoLoginButton.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonClicked), for: .touchUpInside)
        kakaoLogoutButton.addTarget(self, action: #selector(kakaoLogoutButtonClicked), for: .touchUpInside)
    }
    
    @objc func kakaoLoginButtonClicked() {
        // 카카오톡 실행 가능 여부 체크
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                
                if let error {
                    print("카카오로그인 실패 ", error.localizedDescription)
                } else {
                    print("카카오로그인 성공 ")
                    
                    let idToken = oauthToken?.idToken ?? ""
                    let accessToken = oauthToken?.accessToken ?? ""
                    
                    print(idToken)
                    print(accessToken)
                    
                    self.kakaoGetUserInfo()
                }
            }
        } else {
            print("카카오로그인 불가능 상태")
        }
    }
    
    @objc func kakaoLogoutButtonClicked() {
        kakaoUnlink()
//        kakaoLogout()
    }
    
    // 회원탈퇴시??
    private func kakaoUnlink() {
        // 연결 끊기 요청 성공 시 로그아웃 처리가 함께 이뤄져 토큰이 삭제됩니다.
        UserApi.shared.unlink { error in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
        
    }
    
    // 카카오 로그아웃
    private func kakaoLogout() {
        // 사용자 액세스 토큰과 리프레시 토큰을 모두 만료시켜, 더 이상 해당 사용자 정보로 카카오 API를 호출할 수 없도록 합니다.
        UserApi.shared.logout { error in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
    
    private func kakaoRequestAgreement() {
        UserApi.shared.me() { (user, error) in
            if let error = error {
                print(error)
            }
            else {
                if let user = user {
                    var scopes = [String]()
                    // 필요한 권한
                    if (user.kakaoAccount?.profileNeedsAgreement == true) { scopes.append("profile") }
                    if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
                    if (user.kakaoAccount?.birthdayNeedsAgreement == true) { scopes.append("birthday") }
                    if (user.kakaoAccount?.birthyearNeedsAgreement == true) { scopes.append("birthyear") }
                    if (user.kakaoAccount?.genderNeedsAgreement == true) { scopes.append("gender") }
                    if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) { scopes.append("phone_number") }
                    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) { scopes.append("age_range") }
                    if (user.kakaoAccount?.ciNeedsAgreement == true) { scopes.append("account_ci") }
                    
                    if scopes.count > 0 {
                        print("사용자에게 추가 동의를 받아야 합니다.")
                        
                        // OpenID Connect 사용 시
                        // scope 목록에 "openid" 문자열을 추가하고 요청해야 함
                        // 해당 문자열을 포함하지 않은 경우, ID 토큰이 재발급되지 않음
                        // scopes.append("openid")
                        
                        //scope 목록을 전달하여 카카오 로그인 요청
                        UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (_, error) in
                            if let error = error {
                                print(error)
                            } else {
                                UserApi.shared.me() { (user, error) in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        print("me() success.")
                                        guard let userInfo = user?.kakaoAccount else {
                                            print("유저정보 불러오기 실패 / user = nil")
                                            return
                                        }
                                        
                                        let name = userInfo.name
                                        let email = userInfo.email
                                        let gender = userInfo.gender
                                        let profile = userInfo.profile?.profileImageUrl
                                        let birthYear = userInfo.birthyear
                                        let birthDay = userInfo.birthday
                                        
                                        print("이름 = \(name)\n이메일 = \(email)\n성별 = \(gender)\n프로필 = \(profile)\n생일 = \(birthYear).\(birthDay)")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        print("사용자의 추가 동의가 필요하지 않습니다.")
                    }
                }
            }
        }
    }
    
    // 유저정보 불러오기
    private func kakaoGetUserInfo() {
        UserApi.shared.me { user, error in
            if let error {
                print("유저정보 불러오기 실패 ", error.localizedDescription)
            } else {
                guard let userInfo = user?.kakaoAccount else {
                    print("유저정보 불러오기 실패 / user = nil")
                    return
                }
                
                let name = userInfo.name
                let email = userInfo.email
                let gender = userInfo.gender
                let profile = userInfo.profile?.profileImageUrl
                let birthYear = userInfo.birthyear
                let birthDay = userInfo.birthday
                
                if email == nil {
                    self.kakaoRequestAgreement()
                    return
                }
                
                print("이름 = \(name)\n이메일 = \(email)\n성별 = \(gender)\n프로필 = \(profile)\n생일 = \(birthYear).\(birthDay)")
            }
        }
    }
}
