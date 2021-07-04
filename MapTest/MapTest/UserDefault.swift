//
//  UserDefault.swift
//  MapTest
//
//  Created by Alexander Malygin on 04.02.2021.
//

import UIKit
import Foundation

final class UserDefault {
    
    private enum Keys: String {
        case userName
        case userPassword
    }
    
    static var userName: String? {
        get{
            return UserDefaults.standard.string(forKey: Keys.userName.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = Keys.userName.rawValue
            if let name = newValue {
                print("value: \(name) was added to key \(key)")
                defaults.setValue(name, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var userPassword: String? {
        get{
            return UserDefaults.standard.string(forKey: Keys.userPassword.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = Keys.userPassword.rawValue
            if let password = newValue {
                print("value: \(password) was added to key \(key)")
                defaults.setValue(password, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
}
