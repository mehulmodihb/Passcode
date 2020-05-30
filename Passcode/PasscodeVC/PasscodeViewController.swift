//
//  PasscodeViewController.swift
//  Passcode
//
//  Created by hb on 08/05/20.
//  Copyright © 2020 hb. All rights reserved.
//

import UIKit
import AudioToolbox

class PasscodeViewController: UIViewController {

    public enum Mode {
        case CREATE
        case VERIFY
        case CHANGE
    }
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var msgLabel: UILabel!
    @IBOutlet private weak var pinView: UIStackView!
    @IBOutlet private weak var numberPadCollectionView: UICollectionView!
    
    static var config:PasscodeConfig = PasscodeConfig() {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.init("pass_config_changed"), object: nil)
        }
    }
    
    private var keyValues = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private var mode:Mode = .CHANGE
    private var currentPincode: String? = ""
    private var pincode: String? = ""
    private var oldPincode: String? = ""
    private var changePinStep = 1
    private var completion: ((_ code: String, _ new_code: String, _ mode: Mode) -> Void)?
   
    class func instance(with mode: Mode) -> PasscodeViewController? {
        let vc = UIStoryboard.init(name: "Passcode", bundle: Bundle.main).instantiateViewController(withIdentifier: "kPasscodeViewController") as? PasscodeViewController
        vc?.mode = mode
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(setupTheme), name: NSNotification.Name.init("pass_config_changed"), object: nil)
    }

    private func initialSetup() {
        self.navigationItem.title = (mode == .VERIFY ? nil : (mode == .CREATE ? NSLocalizedString("Setup PIN", comment: "") : NSLocalizedString("Change PIN", comment: "")))
        setTransparentNavigationBar(.white)
        setupTheme()
        setupMsgLabel()
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ⓧ", style: .plain, target: self, action: #selector(dismissVc))
    }
    
    @objc private func dismissVc() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setTransparentNavigationBar(_ color: UIColor = .white) {
        if let navigationBar = self.navigationController?.navigationBar {
            //Base on the device size navigation image set
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            // Sets shadow (line below the bar) to a blank image
            navigationBar.shadowImage = UIImage()
            // Sets the translucent background color
            navigationBar.backgroundColor = .clear
            // Sets the translucent background color
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                navigationBar.tintColor = .clear
            } else {
                navigationBar.tintColor = .clear
                navigationBar.barTintColor = .clear
            }
            navigationBar.barTintColor = .clear
            // Set translucent. (Default value is already true, so this can be removed if desired.)
            navigationBar.isTranslucent = true
            
            navigationBar.tintColor = color
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : color,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
            ]
        }
    }
    
    @objc private func setupTheme() {
        //logoImageView.image = PasscodeViewController.config.logo
        msgLabel.textColor = PasscodeViewController.config.msgColor
        setUpDigitsDots()
        if PasscodeViewController.config.isRandomKeyEnabled {
            var shuffled = [String]();
            for _ in 0..<keyValues.count
            {
                let rand = Int(arc4random_uniform(UInt32(keyValues.count)))
                shuffled.append(keyValues[rand])
                keyValues.remove(at: rand)
            }
            keyValues = shuffled
        }
        configureCollectionView()
    }
    
    private func setUpDigitsDots() {
        pinView.translatesAutoresizingMaskIntoConstraints = false;
        pinView.removeAllArrangedSubviews()
        for _ in 1...PasscodeViewController.config.noOfDigits {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            view.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            view.backgroundColor = PasscodeViewController.config.digitColor
            view.layer.cornerRadius = 12.0
            view.alpha = 0.2
            pinView.addArrangedSubview(view)
        }
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        numberPadCollectionView.collectionViewLayout = layout
        numberPadCollectionView.register(KeyPadCell.cellNib, forCellWithReuseIdentifier: KeyPadCell.cellIdentifier)
        numberPadCollectionView.delegate = self
        numberPadCollectionView.dataSource = self
        numberPadCollectionView.reloadData()
    }
    
    @objc private func setupMsgLabel() {
        msgLabel.text = ((mode == .VERIFY || mode == .CHANGE) ? PasscodeViewController.config.EnterCurrentPasscodeMessage : PasscodeViewController.config.EnterNewPasscodeMessage)
    }
    
    private func numberTapped(_ number: Int) {
        if let code = pincode, number != 9 {
            if number == 11, code.count > 0 {
                // Backspace tapped
                pincode?.removeLast()
            } else if number != 11, code.count < PasscodeViewController.config.noOfDigits {
                pincode = "\(pincode ?? "")\(number)"
            }
            if let count = pincode?.count, count <= PasscodeViewController.config.noOfDigits, code != pincode {
                updateDots(isBackspace: number == 11)
                if count == PasscodeViewController.config.noOfDigits {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                        self.submitPinCode()
                    })
                }
            }
        } else if number == 9 {
            // Enable fingerprint scan
            showBioMetric()
        }
    }
    
    private func updateDots(isBackspace:Bool) {
        func resetDots(index:Int) {
            let transform = CGAffineTransform.identity
            UIView.animate(withDuration: 0.2) {
                self.pinView.arrangedSubviews[index].transform = transform
            }
        }
        let index = isBackspace ? ((pincode ?? "").count) : ((pincode ?? "").count - 1)
        let transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        let alpha:CGFloat = isBackspace ? 0.2 : 1.0
        UIView.animate(withDuration: 0.2, animations: {
            self.pinView.arrangedSubviews[index].transform = transform
            self.pinView.arrangedSubviews[index].alpha = alpha
        }) { (_) in
            resetDots(index: index)
        }
    }
    
    @objc private func resetAllDots() {
        pinView.arrangedSubviews.forEach { (dot) in
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
                dot.alpha = 0.2
            }, completion: nil)
        }
    }
    
    @objc private func animateDots() {
        var index = 0
        pinView.arrangedSubviews.forEach { (dot) in
            UIView.animate(withDuration: 0.1, delay: 0.07 * Double(index), options: .autoreverse, animations: {
                dot.alpha = 0.2
                dot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { (_) in
                dot.alpha = 1.0
                dot.transform = CGAffineTransform.identity
            })
            index = index+1
        }
        if self.view.isUserInteractionEnabled == false {
            self.perform(#selector(animateDots), with: nil, afterDelay: (0.1 * Double(PasscodeViewController.config.noOfDigits)))
        } else {
            self.perform(#selector(resetAllDots), with: nil, afterDelay: (0.1 * Double(PasscodeViewController.config.noOfDigits)))
            self.perform(#selector(setupMsgLabel), with: nil, afterDelay: (0.1 * Double(PasscodeViewController.config.noOfDigits)))
            pincode = ""
            oldPincode = ""
            currentPincode = ""
            changePinStep = 1
        }
    }
    
    private func submitPinCode() {
        if mode == .CREATE {
            if oldPincode?.count == 0 {
                oldPincode = pincode
                pincode = ""
                resetAllDots()
                msgLabel.text = PasscodeViewController.config.ReEnterPasscodeMessage
                return
            } else if pincode != oldPincode {
                pinView.shake()
                msgLabel.text = PasscodeViewController.config.PasscodeNotMatchMessage
                resetAllDots()
                pincode = ""
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    self.oldPincode = ""
                    self.msgLabel.text = PasscodeViewController.config.EnterNewPasscodeMessage
                })
                return
            } else {
                if mode == .CREATE {
                    // Call Set Pin WS
                    completion?(pincode ?? "", oldPincode ?? "", self.mode)
                }
            }
        } else if mode == .CHANGE {
            if changePinStep == 1 {
                // Call Verify Current Pin WS
                currentPincode = pincode
                changePinStep = 2
                pincode = ""
                oldPincode = ""
                resetAllDots()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (0.2 * Double(PasscodeViewController.config.noOfDigits)), execute: {
                    self.msgLabel.text = PasscodeViewController.config.EnterNewPasscodeMessage
                })
            } else {
                if oldPincode?.count == 0 {
                    oldPincode = pincode
                    pincode = ""
                    resetAllDots()
                    msgLabel.text = PasscodeViewController.config.ReEnterPasscodeMessage
                    return
                } else if pincode != oldPincode {
                    pinView.shake()
                    msgLabel.text = PasscodeViewController.config.PasscodeNotMatchMessage
                    resetAllDots()
                    pincode = ""
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                        self.oldPincode = ""
                        self.msgLabel.text = PasscodeViewController.config.EnterNewPasscodeMessage
                    })
                    return
                } else {
                    // Call Change Pin WS
                    completion?(currentPincode ?? "", pincode ?? "", self.mode)
                }
            }
        } else {
            // Call Verify Pin WS
            completion?(pincode ?? "", oldPincode ?? "", self.mode)
        }
    }
    
    private func showBioMetric() {
        // BioMetric Authentication
        let response = self.canEvaluateAuthenticationWithBiometrics()
        if response.0 == true {
            self.authenticationWithTouchID ({
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    // Call Login with Pin WS
                    self.completion?("BioMetric", "", self.mode)
                })
            }, onFail: { (error) in
                print(error ?? "error")
            })
        } else {
            print(response.1)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func show(in viewController: UIViewController? = nil, animated:Bool = true, onCallback: @escaping ((_ code: String, _ new_code: String, _ mode: Mode) -> Void)) {
        if PasscodeViewController.config.noOfDigits > 8 {
            assertionFailure("PasscodeViewController : no of digit must be between 4 to 8 digits")
        }
        self.completion = onCallback
        if let vc = viewController ?? appDelegate?.window?.rootViewController {
            let navigationVC = UINavigationController(rootViewController: self)
            navigationVC.modalPresentationStyle = .fullScreen
            vc.present(navigationVC, animated: animated, completion: nil)
        }
    }
    
    func startProgressing() {
        self.view.isUserInteractionEnabled = false
        animateDots()
    }
    
    func stopProgress() {
        self.view.isUserInteractionEnabled = true
    }

}

extension PasscodeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyPadCell.cellIdentifier, for: indexPath) as? KeyPadCell else {
            return UICollectionViewCell()
        }
        cell.isUserInteractionEnabled = true
        if indexPath.row == 9 {
            if mode == .VERIFY {
                cell.setContent(title: nil, image: (biometricType == .none ? nil : (biometricType == .faceID ? PasscodeViewController.config.faceIdImg : PasscodeViewController.config.touchIdImg)))
            } else {
                cell.setContent(title: nil, image: nil)
                cell.isUserInteractionEnabled = false
            }
        } else if indexPath.row == 11 {
            cell.setContent(title: nil, image: PasscodeViewController.config.backspaceImg)
        } else {
            if indexPath.row != 10 {
                cell.setContent(title: keyValues[indexPath.row], image: nil)
            } else {
                cell.setContent(title: keyValues.last, image: nil)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 40) / 3
        let height = (collectionView.frame.size.height - 60) / 4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 9, biometricType == .none {
            return
        }
        
        if indexPath.row == 9 {
            numberTapped(indexPath.row)
        } else if indexPath.row == 11 {
            numberTapped(indexPath.row)
        } else {
            numberTapped(Int(keyValues[indexPath.row])!)
        }
        
    }
    
}

extension UIStackView {
    @discardableResult
    func removeAllArrangedSubviews() -> [UIView] {
        return arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }

    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}

extension UIView {
    func shake(ratio:CGFloat?=10) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x:self.center.x - ratio!, y:self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x:self.center.x + ratio!, y:self.center.y))
        self.layer.add(animation, forKey: "position")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
