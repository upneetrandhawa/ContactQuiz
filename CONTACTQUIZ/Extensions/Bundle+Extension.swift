//
//  Bundle+Extension.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-15.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: Apple.CFBundleDisplayNameKey) as? String
    }
}
