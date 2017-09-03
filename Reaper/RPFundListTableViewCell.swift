//
//  RPFundListTableViewCell.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/2.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPFundListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var annualProfitLabel: UILabel!
    @IBOutlet weak var volatilityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = .rpColor
        self.roundView.layer.cornerRadius = 4.0
        self.roundView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
