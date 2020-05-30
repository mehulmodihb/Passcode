//
//  ViewController.swift
//  Passcode
//
//  Created by hb on 08/05/20.
//  Copyright © 2020 hb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var option: UISegmentedControl!
    @IBOutlet weak var randomKeySwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showPasscodeScreen() {
        PasscodeViewController.config.isRandomKeyEnabled = randomKeySwitch.isOn
        PasscodeViewController.config.noOfDigits = 6
        if let vc = PasscodeViewController.instance(with: option.selectedSegmentIndex == 0 ? .CREATE : (option.selectedSegmentIndex == 1 ? .VERIFY : .CHANGE)) {
            vc.show { (passcode, newPasscode, mode) in
                print(passcode, newPasscode, mode)
                if passcode.lowercased() == "biometric" {
                    vc.dismiss(animated: true, completion: nil)
                }  else {
                    vc.startProgressing()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                        vc.stopProgress()
                        vc.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
