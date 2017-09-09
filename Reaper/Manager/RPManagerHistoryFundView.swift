//
//  RPManagerHistoryFundView.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/8.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPManagerHistoryFundView: UIView {
    
    fileprivate let cellId = "RPManagerHistoryFundTableViewCell"
    
    @IBOutlet weak var fundTableView: UITableView!
    var fundHistoryModels: [RPManagerHistoryFundModel] = [] {
        didSet {
            fundTableView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    // Performs the initial setup.
    private func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        
        // Auto-layout stuff.
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        
        // Show the view.
        addSubview(view)
        
        fundTableView.delegate = self
        fundTableView.dataSource = self
        fundTableView.separatorStyle = .none
        fundTableView.isScrollEnabled = false
        fundTableView.register(UINib.init(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }

}

extension RPManagerHistoryFundView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fundHistoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RPManagerHistoryFundTableViewCell
        
        cell.configureCell(with: fundHistoryModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
    
}
