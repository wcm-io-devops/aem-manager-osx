//
//  BundleStatus.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 02.12.15.
//  Copyright © 2015 Peter Mannel-Wiedemann. All rights reserved.
//

import Foundation

enum BundleStatus:String {
    case starting_Stopping="Starting/Stopping"
    case running="Running"
    case unknown="Unknown"
    case disabled="Disabled"
    case notActive="Not active"
    
}
