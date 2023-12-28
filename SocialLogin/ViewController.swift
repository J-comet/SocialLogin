//
//  ViewController.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/28/23.
//

import UIKit
import AuthenticationServices

/**
 소셜 로그인 ( 페북/네이버/카카오/구글 ), 애플 로그인 구현 필수 - 리젝사유 해당
 자체적으로 구현되어 있는 로그인 SDK 가 있다면 애플 로그인 필수 아님
 ( ex. 인스타그램 - 페이스북 회사꺼라 애플 로그인 구현 필수 아님)
 자체 로그인만 구성이 되어 있다면, 애플 로그인 구현이 필수 아님
 
 개발자계정있어야 테스트 가능
 
 1. Target -> Signing & Capablity -> Capablity 에서 Sign in with Apple 추가하기
 2. apple 로그인 버튼 클래스 연결
 
 참고 URL
 https://developer.apple.com/documentation/sign_in_with_apple/fetch_apple_s_public_key_for_verifying_token_signature
 https://developer.apple.com/documentation/sign_in_with_apple/request_an_authorization_to_the_sign_in_with_apple_server
 https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens#3262048
 
 // Revoke tokens - 사용자가 직접 애플로그인을 제거했을 때 회사서버에서도 제거 필요
 https://developer.apple.com/documentation/sign_in_with_apple/revoke_tokens
 */
class ViewController: UIViewController {

    // iOS 13 이상
    @IBOutlet var appleLoginButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonClicked), for: .touchUpInside)
    }

    @objc func appleLoginButtonClicked() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    // 애플로그인 성공한 경우 -> 메인페이지로 이동 등..
    // 최초 시도: 계속 버튼 UI , Email, fullName 제공
    // 두번째 시도: 로그인 할래요? UI , Email, fullName nil 값으로 옴.
    // 중요!! : 사용자 정보를 계속 제공해주지 않는다. 최초에만 제공됨
    // 최초에 제공되는 정보를 UserDefaults or 서버에 저장하는 방법 / 하지만 서버에 오류가있거나 저장이 실패했을 경우는 어떻게? -> 토큰에서 확인!!!
    // 토큰에 정보를 제공해주기 때문에 토큰에서 Email / FullName 가져와서 전달해주기
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("애플 로그인 성공")
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print(appleIDCredential)
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let token = appleIDCredential.identityToken
            
            guard let token = appleIDCredential.identityToken,
                  let tokenToString = String(data: token, encoding: .utf8) else {
                return print("토큰 에러")
            }
            
            // UserDefaults 에 저장 필요 추후 자동로그인기능이 필요하기 때문에
            print(userIdentifier)
            print(fullName ?? "NoName")
            print(email ?? "NoEmail")
            print(tokenToString)
            
            if email?.isEmpty ?? true {
                let result = decode(jwtToken: tokenToString)["email"] as? String ?? ""
                print(result)
            }
            
            // 이메일, 토큰, 이름 -> UserDefaults & API 서버에 데이터 전달
            // 서버에 Request 후 Response 를 받을 때 다음 화면으로 전환
            UserDefaults.standard.set(tokenToString, forKey: "token")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(MainViewController(), animated: true)
            }
            
        case let passwordCredential as ASPasswordCredential:
            // 키체인 연동
            print(passwordCredential)
            let userName = passwordCredential.user
            let password = passwordCredential.password
            
            print(userName, password)
        default: break
        }
    }
    
    // 애플로그인 실패한 경우
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("애플 로그인 실패")
        print(error.localizedDescription)
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    
    // 레이아웃 꽉차게
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

private func decode(jwtToken jwt: String) -> [String: Any] {
    
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }

        return payload
    }
    
    let segments = jwt.components(separatedBy: ".")
    return decodeJWTPart(segments[1]) ?? [:]
}
