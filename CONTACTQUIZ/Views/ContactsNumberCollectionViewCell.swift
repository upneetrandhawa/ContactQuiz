//
//  ContactsNumberCollectionViewCell.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-17.
//

import UIKit

class ContactsNumberCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var contactNumberTypeLabel: UILabel!
    
    override func prepareForReuse() {
        //print("\(#fileID) : \(#function)")
        super.prepareForReuse()
        
        self.contactNumberLabel.text = ""
        self.contactNumberTypeLabel.text = ""
    }
}
