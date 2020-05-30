//
//  KeyPadCell.swift
//  Passcode
//
//  Created by hb on 08/05/20.
//  Copyright © 2020 hb. All rights reserved.
//

import UIKit

class KeyPadCell: UICollectionViewCell {

    static let cellIdentifier = "kKeyPadCell"
    static let cellNib = UINib.init(nibName: "KeyPadCell", bundle: Bundle.main)
    
    @IBOutlet weak var keyBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        keyBtn.tintColor = PasscodeViewController.config.keyTintColor
        keyBtn.layer.cornerRadius = (min(keyBtn.frame.size.width, keyBtn.frame.size.height) / 2.0)
        keyBtn.clipsToBounds = true
    }
        
    override var isHighlighted: Bool {
        didSet {
            keyBtn.backgroundColor = isHighlighted ? PasscodeViewController.config.keyHighlitedBackgroundColor : nil
            keyBtn.tintColor = isHighlighted ? PasscodeViewController.config.keyHighlitedTintColor : PasscodeViewController.config.keyTintColor
        }
    }
    
    func setContent(title: String?, image: UIImage?) {
        keyBtn.setTitle(title, for: .normal)
        keyBtn.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

}
