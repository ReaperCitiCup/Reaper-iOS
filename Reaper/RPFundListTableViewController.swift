//
//  RPFundListTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/2.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import MJRefresh

class RPFundListTableViewController: UITableViewController {
    
    let reuseId = "RPFundListTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金数据库"
        self.tableView.backgroundColor = .rpColor
        
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            print("!!")
            self.tableView.mj_footer.endRefreshing()
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "fundDetailSegue", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
