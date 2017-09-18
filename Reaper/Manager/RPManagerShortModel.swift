//
//  RPManagerShortModel.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

struct RPManagerShortModel {
    
    let code: String
    let name: String
    let startDate: String?
    let endDate: String?
    let days: Int?
    let returns: Double?
    
    init(code: String, name: String) {
        self.code = code
        self.name = name
        self.startDate = nil
        self.endDate = nil
        self.days = nil
        self.returns = nil
    }
    
    init(code: String, name: String, startDate: String, endDate: String, days: Int, returns: Double) {
        self.code = code
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.days = days
        self.returns = returns
    }
    
}
