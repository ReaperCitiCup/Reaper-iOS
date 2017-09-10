//
//  RPFundDetailModel.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

struct RPFundDetailModel {
    
    var code: String
    var name: String
    var type: [String]
    var establishmentDate: String
    var scope: Double
    var unitNetValue: Double
    var cumulativeNetValue: Double
    var dailyRate: Double
    var assessNetValue: Double
    var rate: [String:Double]?
    var manager: [RPManagerShortModel]?
    var company: RPCompanyShortModel?
    
}
