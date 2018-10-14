//
//  Application.swift
//  FacePicker
//
//  Created by matthew on 9/26/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Application {
    private static var _errorLog: OSLog?
    private static var errorLog:OSLog {
        get {
            if _errorLog == nil {
                if let bundleId = Bundle.main.bundleIdentifier {
                    _errorLog = OSLog(subsystem: bundleId, category: "error")
                } else {
                    _errorLog = OSLog.default
                }
            }
            return _errorLog!
        }
    }
    
    private static var _infoLog: OSLog?
    private static var infoLog:OSLog {
        get {
            if _infoLog == nil {
                if let bundleId = Bundle.main.bundleIdentifier {
                    _infoLog = OSLog(subsystem: bundleId, category: "info")
                } else {
                    _infoLog = OSLog.default
                }
            }
            return _infoLog!
        }
    }
        
    private static var alert:UIAlertController = {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let titleAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        alert.setValue(NSMutableAttributedString(string: "Error", attributes: titleAttributes), forKey: "attributedTitle")
        
        return alert
    }()
    
    private static func setAlertError(error: String) {
        let messageAttributes = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)
        ]
        alert.setValue(NSAttributedString(string: error, attributes: messageAttributes), forKey: "attributedMessage")
    }
    
    static func presentErrorAlert(_ error: String) { // }, inViewController viewController: UIViewController? = nil) {
        setAlertError(error: error)
        var controller = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = controller as? UINavigationController {
            controller = navigationController.viewControllers.first
        }
        else if let tabBarController = controller as? UITabBarController {
            controller = tabBarController.selectedViewController
        }
        else if let splitViewController = controller as? UISplitViewController {
            if let detailNavController = splitViewController.viewControllers.last as? UINavigationController {
                controller = detailNavController.topViewController
            }
            else  {
                controller = splitViewController.viewControllers.last
            }
        }
        if controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }
        controller?.present(alert, animated: true, completion: nil)
    }
    
    static func onError(_ error: String, inFile file: String = #file, inFunction function: String = #function) {
        // log
        let file = String(file.split(separator: "/").last ?? "")
        os_log("[%{public}@ %{public}@]: %{public}@", log: errorLog, type: OSLogType.error, file, function, error)
        
        // present alert
        presentErrorAlert(error)
    }
    
    static func logInfo(_ info: String, includeFileAndFunction: Bool = false, inFile file: String = #file, inFunction function: String = #function) {
        // log
        if includeFileAndFunction {
            let file = String(file.split(separator: "/").last ?? "")
            os_log("[%{public}@ %{public}@]: %{public}@", log: infoLog, type: OSLogType.error, file, function, info)
        } else {
            os_log("%{public}@", log: infoLog, type: OSLogType.info, info)
        }
    }
}
