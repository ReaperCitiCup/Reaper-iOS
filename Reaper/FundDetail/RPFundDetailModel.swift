//
//  RPFundDetailModel.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

struct RPFundDetailModel {
    
    let code: String
    let name: String
    let type: [String]
    let establishmentDate: String
    let scope: Double
    let unitNetValue: Double
    let cumulativeNetValue: Double
    let dailyRate: Double
    let assessNetValue: Double
    let assessIncrease: Double
    let assessDailyRate: Double
    let rate: [String:Double]?
    let manager: [RPManagerShortModel]?
    let company: RPCompanyShortModel?
    
}
