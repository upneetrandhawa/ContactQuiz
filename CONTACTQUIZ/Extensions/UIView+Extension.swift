//
//  UIView+Extension.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-15.
//

import Foundation
import UIKit

extension UIView {
    
    func addShadow(shadowColor: CGColor, shadowOpacity: Float, shadowOffset: CGSize, shadowRadius: CGFloat){
        
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}
