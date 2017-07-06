//
//  ViewController.swift
//  CoreMLTest
//
//  Created by zjy on 2017/6/16.
//  Copyright © 2017年 zjy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var tableView : UITableView = {
        var tv = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        tv.delegate = self
        tv.dataSource = self
        tv.tableFooterView = UIView.init(frame: CGRect.zero)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue:UIColor.black]  // Title's text color
        self.title = "CoreML"
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
        // Do any additional setup after loading the view.
    }

    //MARK: UITableViewDataSource / UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let mhpvc = MHPViewController.initFromNib()
            self.navigationController?.pushViewController(mhpvc, animated: true)
        } else if indexPath.row == 1{
            self.navigationController?.pushViewController(GNPViewController(), animated: true)
        } else {
            self.navigationController?.pushViewController(IVViewController(), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid : String = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid as String)
        if cell == nil {
            cell=UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellid)
            cell?.selectionStyle = .none
        }
        if indexPath.row == 0 {
            cell?.textLabel?.text = "MarsHabitatPricer"
        } else if indexPath.row == 1{
            cell?.textLabel?.text = "GoogLeNetPlaces"
        } else {
            cell?.textLabel?.text = "InceptionV3"
        }
        return cell!
    }

}
