//
//  RPManagerHistoryFundTableViewCell.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/8.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPManagerHistoryFundTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var returnValLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(with model: RPManagerHistoryFundModel) {
        nameLabel.text = model.name
        scaleLabel.text = String(format: "%.2f", model.scale)
        returnValLabel.text = String(format: "%.2f%%", model.returnVal)
    }
    
}
