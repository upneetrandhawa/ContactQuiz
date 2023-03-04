//
//  NonEligibleContactsViewController.swift
//  PHONEQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import Foundation
import UIKit

class NonEligibleContactsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var noOfItemsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    var allContactsDict = [String:Contact]()//Store all Contacts. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    var eligibleContactsDict = [String:Contact]()//Store only elibile contacts, i.e. both name and number should not be null. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    var nonEligibleContactsDict = [String:Contact]()//Store only non-elibile contacts, i.e. etiher name or number is null.key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    
    var sortedEligibleContactsArray = [Contact]()//sorted the sortedEligibleContacts array alphabetically based on Contact Names
    var FilteredSortedEligibleContactsArray = [Contact]()//sortedEligibleContactsArray filtered with search items
    var isSortedArrayReady = false
    
    var user: User? = nil
    
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        
        sortDictToArray(reloadCollectionView: false)
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.layer.borderWidth = 10.0
        collectionView.layer.borderColor = UIColor.systemBackground.cgColor
        
        searchBar.layer.cornerRadius = 15
        searchBar.searchTextField.layer.cornerRadius = 15
        searchBar.layer.borderWidth = 0.0
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor
        noOfItemsLabel.text = String(eligibleContactsDict.count)
        
        //addMenuToMoreButton()
        moreButton.isHidden = true
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            collectionView.layer.borderColor = UIColor.systemBackground.cgColor
            searchBar.layer.borderColor = UIColor.systemBackground.cgColor
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.FilteredSortedEligibleContactsArray.count
    }
    
    let spaceBetweenElements = 10
    let heightOfElements = 20
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactsCell", for: indexPath) as! ContactsCollectionViewCell
        
        cell.contactNameLabel.text = self.FilteredSortedEligibleContactsArray[indexPath.item].fullName
        
        cell.setupViews(_contact: FilteredSortedEligibleContactsArray[indexPath.item])
        
        cell.layer.cornerRadius = 15
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: Double(collectionView.frame.width) * 0.95, height: 80.0 + Double(FilteredSortedEligibleContactsArray[indexPath.item].phoneNumbersArray.count - 1) * 30.0 )
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print("\(#fileID) : \(#function):")
        searchBar.resignFirstResponder()
    }
    
    var previousScrollViewContentOffset = CGPoint()
    var scrollingUpStartingPointScrollViewContentOffset = CGPoint()
    var scrollingUpStartingPointScrollViewContentOffsetReset = true
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(#fileID) : \(#function):", scrollView.contentOffset.y)
        
        if Int(scrollView.contentOffset.y) < 0 {
            return
        }
        
        let defaultHeight = 50
        
        if previousScrollViewContentOffset.y > scrollView.contentOffset.y {//going up
            if scrollingUpStartingPointScrollViewContentOffsetReset {//check if the point where the going up scroll began has been reset
                scrollingUpStartingPointScrollViewContentOffset = scrollView.contentOffset
                scrollingUpStartingPointScrollViewContentOffsetReset = false
            }
            else {
                let diff:Int = Int(scrollingUpStartingPointScrollViewContentOffset.y) - Int(scrollView.contentOffset.y)//we have scrolling up
                print("\(#fileID) : \(#function): going Up for ", diff)
                let newHeight = (diff > 50) ? 50 : diff
                print("\(#fileID) : \(#function): newHeight", newHeight)
                searchBarHeightConstraint.constant = CGFloat(newHeight)
            }
        }
        else {//going down
            print("\(#fileID) : \(#function): going Down")
            scrollingUpStartingPointScrollViewContentOffset = CGPoint()
            scrollingUpStartingPointScrollViewContentOffsetReset = true
            
            let diff:Int = defaultHeight - Int(scrollView.contentOffset.y)
            let newHeight = (diff > 0) ? diff : 0
            print("\(#fileID) : \(#function): newHeight", newHeight)
            searchBarHeightConstraint.constant = CGFloat(newHeight)
        }
        
        previousScrollViewContentOffset = scrollView.contentOffset
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("\(#fileID) : \(#function): text = ", searchText)
        
        if searchText.isEmpty {
            FilteredSortedEligibleContactsArray = sortedEligibleContactsArray
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        
        else {
            //FilteredSortedEligibleContactsArray = sortedEligibleContactsArray.filter { $0.fullName.lowercased().contains(searchText.lowercased())}
            FilteredSortedEligibleContactsArray = sortedEligibleContactsArray.filter {
                if $0.fullName.lowercased().contains(searchText.lowercased()){
                    return true
                }
                for phoneNumberObject in $0.phoneNumbersArray {
                    
                    var phoneNumber = phoneNumberObject.phoneNumber
                    //search phone number without any filters
                    if phoneNumber.contains(searchText.lowercased()){
                        return true
                    }
                    
                    //search phone number with filter
                    phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
                    phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                    phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
                    phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
                    phoneNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
                    
                    if phoneNumber.contains(searchText.lowercased()){
                        return true
                    }
                }
                return false
            }
            collectionView.reloadData()
        }
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        
        print("\(#fileID) : \(#function): ")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "homeView") as! HomeViewController
        destinationVC.modalPresentationStyle = .fullScreen
        
        self.present(destinationVC, animated: true)
    }
    
    func addMenuToMoreButton(){
        print("\(#fileID) : \(#function): ")
        
        moreButton.isHidden = false
        
        let allContactsAction = UIAction(title: String(allContactsDict.count) + " contacts",
                                       image: UIImage(systemName: "person.3")?.withTintColor(.systemIndigo,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): allContactsAction pressed")
                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let destinationVC = storyboard.instantiateViewController(withIdentifier: "allContactsView") as! AllContactsViewController
                                        destinationVC.user = self.user
                                        destinationVC.allContactsDict = self.allContactsDict
                                        destinationVC.eligibleContactsDict = self.eligibleContactsDict
                                        destinationVC.nonEligibleContactsDict = self.nonEligibleContactsDict
                                        
                                        self.present(destinationVC, animated: true)
                                        
                                        
            
        })
        
        
        let nonEligibileContactsAction = UIAction(title: String(nonEligibleContactsDict.count) + " non-eligible contacts",
                                       image: UIImage(systemName: "person.3")?.withTintColor(.systemIndigo,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): nonEligibileContactsAction pressed")
                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let destinationVC = storyboard.instantiateViewController(withIdentifier: "nonEligibleContactsView") as! NonEligibleContactsViewController
                                        destinationVC.user = self.user
                                        destinationVC.allContactsDict = self.allContactsDict
                                        destinationVC.eligibleContactsDict = self.eligibleContactsDict
                                        destinationVC.nonEligibleContactsDict = self.nonEligibleContactsDict
                                        
                                        self.present(destinationVC, animated: true)
                                        
                                        
            
        })
        
        let elements: [UIAction] = [allContactsAction, nonEligibileContactsAction]
        
        let menu:UIMenu = UIMenu(title: "See all", children: elements)
        
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = menu
        
    }
    
    func sortDictToArray(reloadCollectionView: Bool){
        print("\(#fileID) : \(#function): ")
        DispatchQueue.global(qos: .userInitiated).async {
            print("\(#fileID) : \(#function): background queue started")
            
            self.FilteredSortedEligibleContactsArray = self.eligibleContactsDict.values.sorted { (first, second) -> Bool in
                return first.fullName < second.fullName
            }
            
            self.sortedEligibleContactsArray = self.FilteredSortedEligibleContactsArray
            
            self.isSortedArrayReady = true
            
            print("\(#fileID) : \(#function): background queue done")
            
            
        }
    }
}
