//
//  RPBlueButton.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/12.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPBlueButton: UIButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        self.backgroundColor = .rpColor
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 12.0)
    }

}
