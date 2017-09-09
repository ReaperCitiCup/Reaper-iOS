//
//  RPFundRateChoiceTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/4.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

protocol RPFundRateChoiceDelegate {
    func didSelectRate(with rateChoiceModel: RPFundRateChoiceModel)
}

struct RPFundRateChoiceModel {
    var description: String
    var tag: Int
}

class RPFundRateChoiceTableViewController: UITableViewController {
    
    private let choiceModels = [RPFundRateChoiceModel(description: "成立来", tag: 0),
                                RPFundRateChoiceModel(description: "1个月", tag: 1),
                                RPFundRateChoiceModel(description: "3个月", tag: 3),
                                RPFundRateChoiceModel(description: "6个月", tag: 6),
                                RPFundRateChoiceModel(description: "1年", tag: 12),
                                RPFundRateChoiceModel(description: "3年", tag: 36)]
    
    var delegate: RPFundRateChoiceDelegate?
    var nowPeriod: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RPFundRateChoiceTableViewCell", for: indexPath)

        cell.textLabel?.text = choiceModels[indexPath.row].description
        
        if choiceModels[indexPath.row].tag == nowPeriod! {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectRate(with: choiceModels[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
}
