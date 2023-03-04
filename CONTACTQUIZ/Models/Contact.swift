//
//  Contact.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import Foundation

public struct Contact : Codable {
    var identifier: String
    var fullName: String
    var phoneNumbersArray: [PhoneNumber]
    var isDeleted = false
    
    public struct PhoneNumber : Codable {
        var label: String
        var phoneNumber: String
    }
}
