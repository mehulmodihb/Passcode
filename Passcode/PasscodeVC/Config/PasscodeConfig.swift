//
//  PasscodeConfig.swift
//  Passcode
//
//  Created by hb on 08/05/20.
//  Copyright © 2020 hb. All rights reserved.
//

import UIKit

class PasscodeConfig: NSObject {
    var logoImg: UIImage?
    var backspaceImg: UIImage? = UIImage(named: "btn_backspace")
    var touchIdImg: UIImage? = UIImage(named: "btn_biometric")
    var faceIdImg: UIImage? = UIImage(named: "btn_faceid")

    var backgroundColor: UIColor = .darkGray
    var msgColor: UIColor = .white
    var keyTintColor: UIColor = .white
    var keyHighlitedTintColor: UIColor = .lightGray
    var keyHighlitedBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.2)

    var digitColor: UIColor = .white

    var noOfDigits: Int = 4
    var isRandomKeyEnabled = false
    
    var EnterCurrentPasscodeMessage = NSLocalizedString("Enter PIN", comment: "")
    var EnterNewPasscodeMessage = NSLocalizedString("Please enter a new PIN", comment: "")
    var ReEnterPasscodeMessage = NSLocalizedString("Confirm your PIN", comment: "")
    var PasscodeNotMatchMessage = NSLocalizedString("Confirm PIN doesn't match", comment: "")
}
