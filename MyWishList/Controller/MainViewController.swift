//
//  MainViewController.swift
//  MyWishList
//
//  Created by 유림 on 4/16/24.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    var currentProduct: Product? = nil { // currentProduct가 set되면 UIComponents에 값 지정
        didSet {
            DispatchQueue.main.async { // didSet은 메인스레드에서 실행되는 것을 보장하지 않으므로 main 스레드에서 실행될 것을 보장해야 함.
                // 애니메이션 옵션 설정
                let options: UIView.AnimationOptions = [.transitionCrossDissolve, .allowUserInteraction]
                // 애니메이션 적용
                UIView.transition(
                    with: self.view,
                    duration: 0.3,
                    options: options,
                    animations: {
                        // 애니메이션이 필요한 UI 업데이트 코드 작성
                        self.configure(self.currentProduct)
                    },
                    completion: nil)
            }
        }
    }
    
    // UI Components 연결
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var factoryPriceLabel: UILabel!
    @IBOutlet weak var discountPercentageLabel: UILabel!
    @IBOutlet weak var sellingPriceLabel: UILabel!
    @IBOutlet weak var addToListButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var addOrSkipButtonStackView: UIStackView!
    @IBOutlet weak var myWishListButton: UIButton!
    @IBOutlet weak var myWishListButtonView: UIView!
    
    @IBAction func tappedSkipButton(_ sender: UIButton) {
        fetchNewProduct()
    }
    
    @IBAction func tappedAddButton(_ sender: UIButton) {
        saveData()
    }
    
    @IBAction func tappedMyWishListButton(_ sender: UIButton) {
        let wishListStoryBoard = UIStoryboard(name: "MyWishList", bundle: nil)
        guard let nextVC = wishListStoryBoard
            .instantiateViewController(
                identifier: "MyWishListViewController"
            ) as? MyWishListViewController else { return }
        nextVC.modalPresentationStyle = .automatic
        self.present(nextVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupConstraints()
        fetchNewProduct()
    }
    
//    func updateView() { // 적합하지 않음
//        self.fetchNewProduct() // URL data 가져오는 부분은 다른 스레드에서 비동기적으로 처리되는데
//        self.configure(self.currentProduct) // 데이터를 가져오기도 전에 configure가 실행되기 때문.
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // MARK: - link data to UIComponents
    func configure(_ currentProduct: Product?) { // UIComponent에 데이터 연결
        guard let product = currentProduct else { return }
        print("configure thread: \(Thread.current)")
        // 천자리 콤마 numberFormatter 생성
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        self.titleLabel.text = product.title
        self.descriptionLabel.text = product.description
        self.factoryPriceLabel.text = "$\(numberFormatter.string(from: NSNumber(value: product.factoryPrice)) ?? "")"
        self.discountPercentageLabel.text = "\(product.discountPercentage)%"
        self.sellingPriceLabel.text = "$\(numberFormatter.string(from: NSNumber(value: Int(Float(product.factoryPrice) * (1 - product.discountPercentage * 0.01)))) ?? "")"
        loadProductImage(product.thumbnail)
    }
    
    // 썸네일 이미지 가져오기: global queue에서 실행
    func loadProductImage(_ imageURL: URL) {
        DispatchQueue.global().async { [weak self] in // ARC 순환참조를 막기 위해. 클로저로 self에 접근해야 할 때 weak self 자주 사용.
            guard let data = try? Data(contentsOf: imageURL) else { return } // url을 데이터화
            
            DispatchQueue.main.async {
                self?.thumbnailImage.image = UIImage(data: data) // self?: 약한 참조
                print("이미지 설정!")
            }
        }
    }
    
    
    
    // MARK: - call REST API
    private func fetchNewProduct() {
        print("fetchNewProduct 스레드: ", Thread.current)
        // 1. URLSession 인스턴스 생성
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        // 2. url 생성
        let productID = Int.random(in: 1...100)
        let url = URL(string: "https://dummyjson.com/products/\(productID)")!
        
        // 3. URLSessionDataTask로 비동기적으로 데이터 요청
        let task = session.dataTask(with: url) { data, response, error in
            print("데이터 요청 스레드: ", Thread.current)
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
            } catch let error as NSError {
                print("decoding error: \(error)")
            }
        }
        task.resume()
    }

    
    // MARK: - Core Data
    // 데이터 쓰기 (Create)
    func saveData() {
        guard let context = self.persistentContainer?.viewContext else { return }
        guard let currentProduct = self.currentProduct else { return }
        
        let newProduct = MyProduct(context: context)
        
        newProduct.id = Int32(currentProduct.id)
        newProduct.title = currentProduct.title
        newProduct.price = Int32(Float(currentProduct.factoryPrice) * (1 - currentProduct.discountPercentage * 0.01))
        
        try? context.save()
    }
    
    // MARK: - set UI Components
    func setupConstraints() {
        let width = UIScreen.main.bounds.width
        
        // MARK: my wish list button view
        let buttonHeight = myWishListButton.bounds.height
        let buttonViewHeight = buttonHeight + 40
        NSLayoutConstraint.activate([
            myWishListButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20), // view의 bottom을 safeArea보다 20 아래에 잡기
            myWishListButtonView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            myWishListButtonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            myWishListButtonView.heightAnchor.constraint(equalToConstant: buttonViewHeight)
        ])
        
        // MARK: my wish list button
        NSLayoutConstraint.activate([
            myWishListButton.topAnchor.constraint(equalTo: myWishListButtonView.topAnchor, constant: 10), // y좌표
            myWishListButton.centerXAnchor.constraint(equalTo: myWishListButtonView.centerXAnchor) // x좌표
        ])
        
        //MARK: button stack view
        addOrSkipButtonStackView.distribution = .fillProportionally
        NSLayoutConstraint.activate([
            addOrSkipButtonStackView.widthAnchor.constraint(equalToConstant: width - 30), // 너비
            addOrSkipButtonStackView.heightAnchor.constraint(equalToConstant: (width - 30) / 6), // 높이
            addOrSkipButtonStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), // x좌표
            addOrSkipButtonStackView.bottomAnchor.constraint(equalTo: myWishListButtonView.topAnchor, constant: -20) // y좌표
        ])
        
    }
    
    func configureUI() {
        myWishListButtonView.layer.cornerRadius = 30
        
        
    }
    
}
