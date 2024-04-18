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
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var tableView: UITableView! // IBOutlet으로 연결
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProductList()
        configureUI()
        tableView.dataSource = self // dataSource 설정
    }
    
    
    func setProductList() {
        guard let context = self.persistentContainer?.viewContext else { return }
        
        let request = MyProduct.fetchRequest()
        
        if let productList = try? context.fetch(request) {
            self.myProductList = productList
            print("id", productList.first?.id)
            print("title: \(productList.first?.title)")
        }
    }
    
    func configureUI() {
        // MARK: Title
        titleButton.layer.cornerRadius = 0
        titleButton.layer.borderWidth = 1
        titleButton.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func tableViewAction() {
        // 선택 x
        tableView.allowsSelection = false
        
        
    }
    
    
}

extension MyWishListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myProductList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyWishListTableCell", for: indexPath)
        
        let product = myProductList[indexPath.row]
        
        
        print(123123, product.id, product.title, product.price)
        
        let id = product.id
        let title = product.title!
        let price = product.price
        
        cell.textLabel?.text = "[\(id)] \(title) - $\(price)"
        return cell
    }
    
    // 스와이프하여 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        myProductList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
}
