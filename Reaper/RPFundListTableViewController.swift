//
//  RPFundListTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/2.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet

class RPFundListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let reuseId = "RPFundListTableViewCell"
    
    var currentPage = 1
    var fundArr = [RPFundModel]()
    var searchFundArr = [RPFundModel]()
    var searchString: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金数据库"
        self.tableView.backgroundColor = .rpColor
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.searchBar.delegate = self
        self.searchBar.barTintColor = .rpColor
        self.searchBar.searchBarStyle = .prominent
        
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.loadData(of: self.currentPage)
            self.tableView.mj_footer.endRefreshing()
        })
        
        if currentPage == 1 {
            self.loadData(of: currentPage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData(of page: Int) {
        Alamofire.request("http://106.15.203.173:8080/api/fund/search?keyword=\(searchString ?? "")&order=code&size=10&page=\(page)").responseJSON { response in
            if let json = response.result.value {
                for result in JSON(json)["result"].arrayValue {
                    let fund = RPFundModel(code: result["code"].stringValue,
                                           name: result["name"].stringValue,
                                           annualProfit: result["annualProfit"].doubleValue ,
                                           volatility: result["volatility"].doubleValue ,
                                           shortManager: nil)
                    if self.searchString == nil {
                        self.fundArr.append(fund)
                    } else {
                        self.searchFundArr.append(fund)
                    }
                }
            }
            
            self.currentPage = self.currentPage + 1
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchString == nil ? self.fundArr.count : self.searchFundArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! RPFundListTableViewCell
        
        print(self.searchFundArr.count)
        
        let fundModel = searchString == nil ? self.fundArr[indexPath.row] : self.searchFundArr[indexPath.row]
        cell.codeLabel.text = fundModel.code
        cell.nameLabel.text = fundModel.name
        //
        cell.annualProfitLabel.text = "0.0"
        cell.volatilityLabel.text = "0.0"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let fundModel = searchString == nil ? fundArr[indexPath.row] : searchFundArr[indexPath.row]
        self.performSegue(withIdentifier: "fundDetailSegue", sender: fundModel)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fundDetailSegue" {
            let fund = sender as? RPFundModel
            guard fund != nil else {
                return
            }
            let vc = segue.destination as! RPFundDetailTableViewController
            vc.fundCode = fund!.code
        }
    }

}

extension RPFundListTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
}

extension RPFundListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Did change \(searchText)")
        self.searchString = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchString = nil
        self.searchFundArr.removeAll()
        loadData(of: 1)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchFundArr.removeAll()
        loadData(of: 1)
    }
    
}
