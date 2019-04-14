//
//  AlertController+AddActions.swift
//  GPS Tooklit
//
//  Created by Sylvan Martin on 4/13/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    /// Adds multiple actions to a view controller
    func addActions(_ actions: UIAlertAction ...) {
        for action in actions {
            self.addAction(action)
        }
    }
    
}
