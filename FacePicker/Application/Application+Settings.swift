//
//  Application+Settings.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation

//@IBOutlet weak var validateClientSwitch: UISwitch!
//@IBOutlet weak var requireDOBSwitch: UISwitch!
//@IBOutlet weak var requireAddressSwitch: UISwitch!
//@IBOutlet weak var requirePhoneSwitch: UISwitch!
//@IBOutlet weak var requireEmailSwitch: UISwitch!
//@IBOutlet weak var requireSignatureSwitch: UISwitch!
//@IBOutlet weak var editOldSessionSwitch: UISwitch!
//@IBOutlet weak var selectionIncrementLabel: UILabel!
//@IBOutlet weak var selectionIncrementSlider: UISlider!
//@IBOutlet weak var dateForNewSessionsSwitch: UISwitch!

extension Application {
    class Settings {
        private static let listAllClientsKey = "listAllClientsKey"
        private static let validateClientKey = "validateClientKey"
        private static let validateDOBKey = "validateDOBKey"
        private static let validateAddressKey = "validateAddressKey"
        private static let validatePhoneKey = "validatePhoneKey"
        private static let validateEmailKey = "validateEmailKey"
        private static let validateSignatureKey = "validateSignatureKey"
        private static let editOldSessionsAllowedKey = "editOldSessionsAllowedKey"
        private static let unitSelectionIncrementKey = "unitSelectionIncrementKey"
        private static let promptDateForNewSessionKey = "promptDateForNewSessionKey"
        private static var test:Bool?
        
        private static func logSettingChanged(key: String, value: String) {
            var setting = key
            if let lower = key.range(of: "Key")?.lowerBound {
                setting = String(key[..<lower])
            }
            Application.logInfo("Setting \(setting) changed to \(value)")
        }
        
        public static var listAllClients:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: listAllClientsKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: listAllClientsKey)
            }
        }
        
        public static var validateClient:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: validateClientKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: validateClientKey)
            }
        }
        
        public static var validateDOB:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: validateDOBKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: validateDOBKey)
            }
        }
        
        public static var validateAddress:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: validateAddressKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: validateAddressKey)
            }
        }
        
        public static var validatePhone:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: validatePhoneKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: validatePhoneKey)
            }
        }
        
        public static var validateEmail:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: validateEmailKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: validateEmailKey)
            }
        }
        
        public static var validateSignature:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: validateSignatureKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: validateSignatureKey)
            }
        }
        
        public static var editOldSessionsAllowed:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: editOldSessionsAllowedKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: editOldSessionsAllowedKey)
            }
        }
        
        public static var unitSelectionIncrement:Float {
            get {
                guard let value = UserDefaults.standard.object(forKey: unitSelectionIncrementKey) as? Float else {
                    return 0.5 // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: unitSelectionIncrementKey)
            }
        }
        
        public static var promptDateForNewSession:Bool {
            get {
                guard let value = UserDefaults.standard.object(forKey: promptDateForNewSessionKey) as? Bool else {
                    return true // default setting
                }
                return value
            }
            set {
                UserDefaults.standard.set(newValue, forKey: promptDateForNewSessionKey)
            }
        }
    }
}
