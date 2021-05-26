//
//  LoginViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    private let throttleInterval = 0.1
    
    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    @IBOutlet private weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let emailValid = emailTextfield
            .rx
            .text
            .orEmpty
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
            .map({_ in true})
            .debug("valid email", trimOutput: true)
            .share(replay: 1)
            
        let passwordValid = passwordTextfield
            .rx
            .text
            .orEmpty
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
            .map {_ in true } // 1
            .debug("passwordValid", trimOutput: true)
            .share(replay: 1)
        
        let everythingValid = Observable
            .combineLatest(emailValid, passwordValid) { $0 && $1 } // 1
            .debug("everythingValid", trimOutput: true)
            .share(replay: 1)
        
        everythingValid
            .bind(to: logInButton.rx.isEnabled)
            .disposed(by: bag)
    }
    
    @IBAction private func logInButtonPressed() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = mainStoryboard.instantiateInitialViewController()!
        
        UIApplication.changeRoot(with: initialViewController)
    }
    
    private func validateEmail(with email: String) -> Bool {
      let emailPattern = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}"
      let predicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)

      return predicate.evaluate(with: email)
    }
}
