//
//  UIViewController+LocalAuthentication.swift
//  BCryptV3
//
//  Created by hb1 on 08/10/18.
//  Copyright © 2018 hb1. All rights reserved.
//

import UIKit
import LocalAuthentication

extension PasscodeViewController {
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        get {
            let context = LAContext()
            var error: NSError?
            
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                print(error?.localizedDescription ?? "")
                return .none
            }
            
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                @unknown default:
                    return .none
                }
            } else {
                return  .touchID
            }
        }
    }
    
    func canEvaluateAuthenticationWithBiometrics() -> (Bool, String) {
        var authError: NSError?
        let canAuthenticate = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
        let msg = authError != nil ? self.evaluateAuthenticationPolicyMessageForLA(errorCode: authError!.code) : ""
        return (canAuthenticate, msg)
    }
    
    func authenticationWithTouchID(_ onSuccess:(()->())?, onFail:((String?)->())?) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = NSLocalizedString("Use Passcode", comment: "")
        
        var authError: NSError?
        let reasonString = NSLocalizedString("Authentication needed to access your account.", comment: "")
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    onSuccess?()
                    //TODO: User authenticated successfully, take appropriate action
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    onFail?(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    //print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            onFail?(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
            //print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = NSLocalizedString("Authentication could not start because the device does not support biometric authentication.", comment: "")
                
            case LAError.biometryLockout.rawValue:
                message = NSLocalizedString("Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times.", comment: "")
                
            case LAError.biometryNotEnrolled.rawValue:
                message = NSLocalizedString("Authentication could not start because the user has not enrolled in biometric authentication.", comment: "")
                
            default:
                message = NSLocalizedString("Did not find error code on LAError object", comment: "")
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = NSLocalizedString("Too many failed attempts.", comment: "")
                
            case LAError.touchIDNotAvailable.rawValue:
                message = NSLocalizedString("TouchID is not available on the device", comment: "")
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = NSLocalizedString("TouchID is not enrolled on the device", comment: "")
                
            default:
                message = NSLocalizedString("Did not find error code", comment: "")
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = NSLocalizedString("The user failed to provide valid credentials", comment: "")
            
        case LAError.appCancel.rawValue:
            message = NSLocalizedString("Authentication was cancelled by application", comment: "")
            
        case LAError.invalidContext.rawValue:
            message = NSLocalizedString("The context is invalid", comment: "")
            
        case LAError.notInteractive.rawValue:
            message = NSLocalizedString("Not interactive", comment: "")
            
        case LAError.passcodeNotSet.rawValue:
            message = NSLocalizedString("Passcode is not set on the device", comment: "")
            
        case LAError.systemCancel.rawValue:
            message = NSLocalizedString("Authentication was cancelled by the system", comment: "")
            
        case LAError.userCancel.rawValue:
            message = NSLocalizedString("The user did cancel", comment: "")
            
        case LAError.userFallback.rawValue:
            message = NSLocalizedString("The user choose to use the fallback", comment: "")
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}
