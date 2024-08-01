//
//  MakeSecureViewController.swift
//  ktas
//
//  Created by m2comm on 2023/07/24.
//  Copyright © 2023 JinGu's iMac. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func makeSecure() {
        DispatchQueue.main.async {


            let field = UITextField(frame: CGRect(x: 0, y: 0, width: SCREEN.WIDTH, height: SCREEN.HEIGHT - 150))

            
            field.isSecureTextEntry = true
            field.isEnabled = false
            self.addSubview(field)
            
            
            
            field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.first?.addSublayer(self.layer)
            
           
        }
    }
}
