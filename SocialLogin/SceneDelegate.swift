//
//  SceneDelegate.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/28/23.
//

import UIKit
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /**
         SceneDelegate 에서 처리하지 않고
         SplashVC 를 생성 후 애플 or 카카도 등 소셜 로그인 체크 하도록 수정 필요
         */
//        checkAppleLogin(windowScene: windowScene)
        checkKakaoLogin(windowScene: windowScene)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    private func checkAppleLogin(windowScene: UIWindowScene) {
        guard let user = UserDefaults.standard.string(forKey: "User") else {
            print("로그인 X")
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: user) { credentialState, error in
            switch credentialState {
            case .revoked, .notFound:
                print("유저가 직접 애플로그인 제거한 경우 로그인화면으로 이동")
            case .authorized:
                DispatchQueue.main.async {
                    print("애플 로그인 활성화")
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = MainViewController()
                    self.window = window
                    window.makeKeyAndVisible()
                }
            default: break
            }
        }
    }
    
    private func checkKakaoLogin(windowScene: UIWindowScene) {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                        //로그인 필요
                        self.moveLoginVC(windowScene: windowScene)
                    } else {
                        //기타 에러
                        print("카카오 로그인 기타 에러")
                        self.moveLoginVC(windowScene: windowScene)
                    }
                } else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    if let id = accessTokenInfo?.id {
                        UserDefaults.standard.set(id, forKey: "User")
                        DispatchQueue.main.async {
                            print("카카오 로그인 활성화")
                            let window = UIWindow(windowScene: windowScene)
                            window.rootViewController = MainViewController()
                            self.window = window
                            window.makeKeyAndVisible()
                        }
                    } else {
                        print("카카오 로그인 필요 33")
                        self.moveLoginVC(windowScene: windowScene)
                    }
                    
                }
            }
        } else {
            //로그인 필요
            print("카카오 로그인 필요 22")
            moveLoginVC(windowScene: windowScene)
        }
    }
    
    private func moveLoginVC(windowScene: UIWindowScene) {
//        DispatchQueue.main.async {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = KakaoViewController()
            self.window = window
            window.makeKeyAndVisible()
//        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

