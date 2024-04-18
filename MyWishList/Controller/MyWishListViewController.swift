//
//  MyWishListViewController.swift
//  MyWishList
//
//  Created by 유림 on 4/18/24.
//

import UIKit

class MyWishListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! // IBOutlet으로 연결
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self // dataSource 설정
    }
    
}

extension MyWishListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
