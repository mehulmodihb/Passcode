# Passcode Screen

A Swift implementation of passcode lock for iOS with TouchID and FaceID authentication.

![Verify Passcode Screen](https://i.ibb.co/3vF4ZpX/Simulator-Screen-Shot-i-Phone-11-Pro-Max-2020-05-14-at-12-33-16.png)

## Getting Started

Passcode Screen requires Swift 5.0 and Xcode 11.

Library has main 3 features  as follow:
 - Create PIN 
 - Verify PIN     
     - Verify PIN with Digits
     - Biometric Verification (Touch ID / Face ID) 
 - Change PIN

### Manual Installing

A simple manual installation with drag and drop directory option will enabled your app with Passcode Lock.

Copy ``` Passcode ``` directory to your project

## Usage

Wherever you want to open Passcode Screen. Just copy past below code to your ViewController. 

### 1. Show Passcode Screen over rootviewcontroller :
    if let vc = PasscodeViewController.instance(with: .VERIFY) {
        vc.show { (passcode, newPasscode, mode) in
            print(passcode, newPasscode, mode)
            if passcode.lowercased() == "biometric" {
                vc.dismiss(animated: true, completion: nil)
            }  else {
                vc.startProgressing()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                vc.stopProgress()
            }
        }
    }    

### 2. Show Passcode Screen over current viewController :
    if let vc = PasscodeViewController.instance(with: .VERIFY) {
        vc.show(in: self) { (passcode, newPasscode, mode) in
            print(passcode, newPasscode, mode)
            if passcode.lowercased() == "biometric" {
                vc.dismiss(animated: true, completion: nil)
            }  else {
                vc.startProgressing()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                vc.stopProgress()
            }
        }
    }    

### 3. Start Animating Dots :
    vc.startProgressing()

### 4. Stop Animating Dots :
    vc.stopProgress()

## Theming

In PasscodeConfig class you can modify following options for changing the theme colors and icons

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
    

## Customization

You can easily customize the following options for the library

 - Set no. of digits
     - ``` PasscodeViewController.config.noOfDigits = 6 ```
- Set enable/disable random key numbers
    - ```PasscodeViewController.config.isRandomKeyEnabled = randomKeySwitch.isOn```
- Change label messages
    - ```PasscodeViewController.config.EnterCurrentPasscodeMessage =  "Enter PIN"```
    - ```PasscodeViewController.config.EnterNewPasscodeMessage =  "Please enter a new PIN"```
    - ```PasscodeViewController.config.ReEnterPasscodeMessage =  "Confirm your PIN"```
    - ```PasscodeViewController.config.PasscodeNotMatchMessage =  "Confirm PIN doesn't match"```


# License

```
Copyright 2020

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

```
