//
//  File.swift
//  BasicMapAndRoutes
//
//  Created by Марк Пушкарь on 03.07.2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alertAddAdress(title: String, placeHolder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertControler = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in
            let tfText = alertControler.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
            
            print("action")
            
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { _ in
            
            
        }
        
        alertControler.addTextField { tf in
            tf.placeholder = placeHolder
        }
        
        alertControler.addAction(alertOk)
        alertControler.addAction(alertCancel)
        
        present(alertControler, animated: true, completion: nil)
        
    }
    
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(alertOK)
        present(alertController, animated: true, completion: nil)
        
    }
}
