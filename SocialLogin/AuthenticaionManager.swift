//
//  AuthenticaionManager.swift
//  SocialLogin
//
//  Created by 장혜성 on 12/29/23.
//

import Foundation
import LocalAuthentication  // FaceID, TouchID

/**
 - 권한 요쳥
 - FaceID가 없다면?
    - 다른 인증방법을 권장 혹은 FaceID 등록 권유 (아이폰 잠금을 아예 사용하지 않거나, 비밀번호만 등록한 사람)
    - FaceID 를 설정하려면 아이폰 암호가 먼저 설정되어야 함. 그래서 아이폰 암호만 없는 경우는 없음
 
 - FaceID 변경되었다면?
    - domainStateData (안경, 마스크 착용 후 등록한 FaceID 는 domainStateData 가 변경되지 않고 사람이 변경되었을 때만 변경됨)
 
 - FaceID 계속 실패할 때? FallBack 에 대한 처리가 필요. 다른 인증 방법으로 처리하기
 
 - FaceID 결과는 메인쓰레드 보장 X
    - DispatchQueue.main.async 구문 필요
 
 - 한 화면에서는 FaceID 인증을 성공하면, 해당화면에 대해서는 항상 success 로 되기 때문에 성공 후 다른 페이지로 이동 시켜줘야됨.
    - SwiftUI 에서는? body 가 재 렌더링 될 수 있기 때문에 UI 가 다시 그려지고 FaceID 도 다시 인증해야 함..
 
 - 실제 서비스에 어떻게 구현되어 있는지 테스트
 - LSLP 생체 인증 연동
 */

final class AuthenticaionManager {
    static let shared = AuthenticaionManager()
    private init() { }
    
    var selectedPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics  // 생체인증 , 페이스아이디, 터치
    //    var selectedPolicy: LAPolicy = .deviceOwnerAuthentication  // 비밀번호, 생체인증 , 페이스아이디, 터치 => 권장
    
    func auth() {
        let context = LAContext()
        context.localizedCancelTitle = "FaceID 인증 취소@@@"
        context.localizedFallbackTitle = "비밀번호로 대신 인증하기"    // 계속 페이스 인증 실패했을 때 뜨는 문구
        
        context.evaluatePolicy(selectedPolicy, localizedReason: "페이스 아이디 인증이 필요합니다!!!") { result, error in
            
            if let error {
                let code = error._code
                let laError = LAError(LAError.Code(rawValue: code)!)
                print(laError)
            } else {
                if result {
                    // CompletionHandler 를 통해 다른 화면으로 넘겨주도록 로직 추가 필요
                    print("성공")
                    print(result)
                } else {
                    print("실패")
                }
            }
        }
    }
    
    // FaceID 를 사용할 수 있는 상태인지 체크
    func checkPolicy() -> Bool {
        let context = LAContext()
        let policy: LAPolicy = selectedPolicy
        return context.canEvaluatePolicy(policy, error: nil)
    }
    
    // FaceID 변경시
    func isFaceIDChanged() -> Bool {
        let context = LAContext()
        context.canEvaluatePolicy(selectedPolicy, error: nil)
        let state = context.evaluatedPolicyDomainState  // 생체인증 정보
        
        // 생체인증 정보 (DomainState) 를 UserDefaults 에 저장해두기
        // 기존에 저장된 DomainState 와 새롭게 변경된 DomainState 를 비교
        print(state)
        
        // 저장된 정보와 비교 후 return 값 로직 추가
        return false
    }
}

