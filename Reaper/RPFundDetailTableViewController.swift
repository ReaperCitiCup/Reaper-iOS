//
//  RPFundDetailTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPFundDetailTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金详情"
        self.tableView.backgroundColor = .rpColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        let label = UILabel(frame: CGRect(x: 13, y: 6, width: SCREEN_WIDTH - 19, height: 48))
        label.font = UIFont(name: "PingFangSC-Semibold", size: 28.0)
        label.text = "华夏基金"
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }

}
