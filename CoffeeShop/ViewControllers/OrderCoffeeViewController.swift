//
//  OrderCoffeeViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 24.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderCoffeeViewController: BaseViewController {
    
    @IBOutlet private weak var coffeeIconImageView: UIImageView!
    @IBOutlet private weak var coffeeNameLabel: UILabel!
    @IBOutlet private weak var coffeePriceLabel: UILabel!
    @IBOutlet private weak var orderCountLabel: UILabel!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var totalPrice: UILabel!
    @IBOutlet private weak var addToCartButton: UIButton!
    
    private let bag = DisposeBag()
    
    var coffee: Coffee!
//    var totalOrder: Int = 0 {
//        didSet {
//            if viewIfLoaded != nil {
//                orderCountLabel.text = "\(totalOrder)"
//                totalPrice.text = CurrencyFormatter.turkishLirasFormatter.string(from: Float(totalOrder) * coffee.price)
//            }
//        }
//    }
    
    var totalOrder: BehaviorRelay<Int> = .init(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
        
        let sharedTotalOrder = totalOrder.share()
        
        sharedTotalOrder
            .map({"\($0)"})
            .bind(to: orderCountLabel.rx.text)
            .disposed(by: bag)
        
        sharedTotalOrder
            .map({CurrencyFormatter.turkishLirasFormatter.string(from: Float($0) * self.coffee.price)})
            .bind(to: totalPrice.rx.text)
            .disposed(by: bag)
    }
    
    private func populateUI() {
        guard let coffee = coffee else { return }
        
        coffeeNameLabel.text = coffee.name
        coffeeIconImageView.image = UIImage(named: coffee.icon)
        coffeePriceLabel.text = CurrencyFormatter.turkishLirasFormatter.string(from: coffee.price)
//        totalOrder = 0
    }
    
    @IBAction private func addButtonPressed() {
        totalOrder.accept(totalOrder.value + 1)
    }
    
    @IBAction private func removeButtonPressed() {
        guard totalOrder.value > 0 else { return }
        
        totalOrder.accept(totalOrder.value - 1)
    }
    
    @IBAction private func addToCartButtonPressed() {
        guard let coffee = coffee else { return }
        
        ShoppingCart.shared.addCoffee(coffee, withCount: totalOrder.value)
        
        navigationController?.popViewController(animated: true)
    }
}
