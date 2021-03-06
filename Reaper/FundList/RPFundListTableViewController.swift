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
import SVProgressHUD

class RPFundListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let reuseId = "RPFundListTableViewCell"
    
    private var currentPage = 1
    var fundArr = [RPFundModel]()
    fileprivate var searchFundArr = [RPFundModel]()
    fileprivate var searchString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金数据库"
        self.tableView.backgroundColor = .rpColor
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.view.backgroundColor = .rpColor
        
        self.searchBar.delegate = self
        self.searchBar.barTintColor = .rpColor
        self.searchBar.backgroundImage = UIImage()
        
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.loadData(of: self.currentPage)
            self.tableView.mj_footer.endRefreshing()
        })
        
        if currentPage == 1 {
            loadData(of: currentPage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData(of page: Int) {
        SVProgressHUD.show()

        let url: URLConvertible = "\(kBaseUrl)/fund/search"
        let para = ["keyword": searchString ?? "",
                    "order": "code",
                    "size": 10,
                    "page": page] as [String: Any]
        Alamofire.request(url, parameters: para).responseJSON { response in
            if let json = response.result.value {
                for result in JSON(json)["result"].arrayValue {
                    let fund = RPFundModel(code: result["code"].stringValue,
                                           name: result["name"].stringValue,
                                           annualProfit: result["annualProfit"].doubleValue ,
                                           volatility: result["volatility"].doubleValue ,
                                           shortManager: nil)
                    if self.searchBar.isFirstResponder {
                        self.searchFundArr.append(fund)
                    } else {
                        self.fundArr.append(fund)
                    }
                }
            }

            SVProgressHUD.dismiss()

            self.currentPage = page + 1
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBar.isFirstResponder ? searchFundArr.count : fundArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! RPFundListTableViewCell
        
        guard indexPath.row < (searchBar.isFirstResponder ? searchFundArr.count : fundArr.count) else {
            return cell
        }
        
        let fundModel = searchBar.isFirstResponder ? searchFundArr[indexPath.row] : fundArr[indexPath.row]
        cell.codeLabel.text = fundModel.code
        cell.nameLabel.text = fundModel.name
        //
        cell.annualProfitLabel.text = String.init(format: "%.2f%%", fundModel.annualProfit ?? 0.0)
        cell.volatilityLabel.text = String.init(format: "%.2f%%", fundModel.volatility ?? 0.0)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92.0
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fundDetailSegue" {
            if let cell = sender as? RPFundListTableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                let fundModel = searchBar.isFirstResponder ? searchFundArr[indexPath.row] : fundArr[indexPath.row]
                let vc = segue.destination as! RPFundTabBarController
                vc.fundCode = fundModel.code
            }
        }
    }

}

extension RPFundListTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "暂无基金", attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        return NSAttributedString(string: "点击重试", attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.loadData(of: 1)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}

extension RPFundListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchString = nil
        searchFundArr.removeAll()
        loadData(of: 1)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFundArr.removeAll()
        loadData(of: 1)
    }
    
}
