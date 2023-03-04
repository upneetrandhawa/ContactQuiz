//
//  ContactsCollectionViewCell.swift
//  PHONEQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-17.
//

import UIKit

class ContactsCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactNumbersCollectionView: UICollectionView!
    
    var contact = Contact(identifier: "", fullName: "", phoneNumbersArray: [])
    
    let contactsNumberCollectionCellId = "contactsNumberCell"
    
    func setupViews(_contact: Contact){
        //print("\(#fileID) : \(#function): ")
        contact = _contact
        contactNumbersCollectionView.delegate = self
        contactNumbersCollectionView.dataSource = self
        
        //contactNumbersCollectionView.register(ContactsNumberCollectionViewCell.self, forCellWithReuseIdentifier: contactsNumberCollectionCellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        contact.phoneNumbersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contactsNumberCollectionCellId, for: indexPath) as! ContactsNumberCollectionViewCell
        cell.contactNumberLabel.text = contact.phoneNumbersArray[indexPath.item].phoneNumber
        cell.contactNumberTypeLabel.text = contact.phoneNumbersArray[indexPath.item].label
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: contactNumbersCollectionView.frame.width, height: 25.0)
    }
    
    override func prepareForReuse() {
        //print("\(#fileID) : \(#function)")
        
        self.contactNumbersCollectionView.reloadData()
    }
    
    
}
