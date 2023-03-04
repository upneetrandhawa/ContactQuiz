//
//  CollectionViewCell+Extension.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-15.
//

import UIKit

extension UICollectionViewCell {
    func transformToLarge() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    func transformToStandard() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
    
}
