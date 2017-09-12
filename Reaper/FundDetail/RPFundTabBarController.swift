//
//  RPFundTabBarController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class RPFundTabBarController: UITabBarController {
    
    var fundCode: String = "" {
        didSet {
            SVProgressHUD.show()

            let managerVC = self.viewControllers![1] as! RPManagerTableViewController
            managerVC.fundCode = self.fundCode
            
            let analysisVC = self.viewControllers![3] as! RPAnalysisTableViewController
            analysisVC.fundCode = self.fundCode
            
            Alamofire.request("\(BASE_URL)/fund/\(fundCode)").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json)

                    print("Fund Detail \(result)")
                    
                    var managerArray = [RPManagerShortModel]()
                    for dict in result["manager"].arrayValue {
                        managerArray.append(RPManagerShortModel(code: dict["code"].stringValue,
                                                                name: dict["name"].stringValue))
                    }
                    
                    let companyShortModel = RPCompanyShortModel(code: result["company"]["code"].stringValue,
                                                                name: result["company"]["name"].stringValue)
                    
                    var rateDict: [String: Double] = [:]
                    for (key, value) in result["rate"].dictionaryValue {
                        rateDict[key] = value.doubleValue
                    }
                    
                    let fundDetailModel = RPFundDetailModel(code: result["code"].stringValue,
                                                             name: result["name"].stringValue,
                                                             type: result["type"].arrayValue.map({$0.stringValue}),
                                                             establishmentDate: result["establishmentDate"].stringValue,
                                                             scope: result["scope"].doubleValue,
                                                             unitNetValue: result["unitNetValue"].doubleValue,
                                                             cumulativeNetValue: result["cumulativeNetValue"].doubleValue,
                                                             dailyRate: result["dailyRate"].doubleValue,
                                                             assessNetValue: result["assessNetValue"].doubleValue,
                                                             assessIncrease: result["assessIncrease"].doubleValue,
                                                             assessDailyRate: result["assessDailyRate"].doubleValue,
                                                             rate: rateDict,
                                                             manager: managerArray,
                                                             company: companyShortModel)
                    
                    let detailVC = self.viewControllers![0] as! RPFundDetailTableViewController
                    detailVC.fundDetailModel = fundDetailModel
                    
                    let companyVC = self.viewControllers![2] as! RPCompanyTableViewController
                    companyVC.companyModel = companyShortModel

                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationItem.backBarButtonItem = backItem
        
        self.tabBar.tintColor = .rpColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SVProgressHUD.dismiss()
    }

}
