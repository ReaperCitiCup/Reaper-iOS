//
//  RPBlueButton.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/12.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPBlueButton: UIButton {

    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        self.backgroundColor = .rpColor
        self.setTitleColor(.white, for: .normal)
    }

}
