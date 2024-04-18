//
//  MyWishListViewController.swift
//  MyWishList
//
//  Created by 유림 on 4/18/24.
//

import UIKit
import CoreData

class MyWishListViewController: UIViewController {
    
    private var myProductList: [MyProduct] = []
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    @IBOutlet weak var tableView: UITableView! // IBOutlet으로 연결
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProductList()
        tableView.dataSource = self // dataSource 설정
    }
    
    
    func setProductList() {
        guard let context = self.persistentContainer?.viewContext else { return }
        
        let request = MyProduct.fetchRequest()
        
        if let productList = try? context.fetch(request) {
            self.myProductList = productList
        }
        
        
    }
}

extension MyWishListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myProductList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyWishListTableCell", for: indexPath)
        
        let product = myProductList[indexPath.row]
        
        let id = product.id
        let title = product.title
        
        cell.textLabel?.text = "[\(id)] \(title)"
        return cell
        
    }
    
    
}
