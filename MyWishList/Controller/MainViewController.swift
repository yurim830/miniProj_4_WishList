//
//  MainViewController.swift
//  MyWishList
//
//  Created by 유림 on 4/16/24.
//

import UIKit

class MainViewController: UIViewController {
    
    // UI Components 연결
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var factoryPriceLabel: UILabel!
    @IBOutlet weak var discountPercentageLabel: UILabel!
    @IBOutlet weak var sellingPriceLabel: UILabel!
    @IBOutlet weak var wonLabel: UILabel!
    @IBOutlet weak var addToListButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var myWishListButton: UIButton!
    
    
    @IBAction func tappedSkipButton(_ sender: UIButton) {
        setUIComponents()
    }
    
    var currentProduct: Product? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchNewProduct()
        self.setUIComponents()
        print("hello! \(self.currentProduct?.title)")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func setUIComponents() { // UIComponent에 데이터 연결
        guard let factoryPrice = self.currentProduct?.factoryPrice else { return }
        guard let discountPercentage = self.currentProduct?.discountPercentage else { return }
        let sellingPrice = Int(Float(factoryPrice) * (1 - discountPercentage * 0.01))
        
        self.titleLabel.text = self.currentProduct?.title
        self.descriptionLabel.text = self.currentProduct?.description
        self.factoryPriceLabel.text = "\(factoryPrice)$"
        self.discountPercentageLabel.text = "\(discountPercentage)%"
        self.sellingPriceLabel.text = "\(sellingPrice)"
        loadProductImage()
    }
    
    
    func loadProductImage() { // 썸네일 이미지 가져오기
        guard let imageURL = self.currentProduct?.thumbnail else { return }
        
        guard let data = try? Data(contentsOf: imageURL) else { return }
        
        self.thumbnailImage.image = UIImage(data: data)
        print("이미지 설정!")
        
    }
    
    
    
    // MARK: - call REST API
    func fetchNewProduct() {
        // 1. URLSession 인스턴스 생성
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        // 2. url 생성
        let productID = Int.random(in: 1...100)
        let url = URL(string: "https://dummyjson.com/products/\(productID)")!
        
        // 3. URLSessionDataTask로 비동기적으로 데이터 요청
        let task = session.dataTask(with: url) { data, response, error in
            // 3-1. 성공한 응답 걸러내기
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("error: \(error)")
                return
            }
            
            // 3-2. 데이터 옵셔널 해제
            guard let data = data else { return }
            
            // 3-3. 디코딩
            do {
                let decoder = JSONDecoder()
                let product = try decoder.decode(Product.self, from: data)
                self.currentProduct = product
                print(product)
                print(product.title)
            } catch let error as NSError {
                print("error: \(error)")
            }
        }
        task.resume()
    }
    
}
