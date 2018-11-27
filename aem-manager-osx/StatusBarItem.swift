//
//  StatusBarItem.swift
//  aem-manager-osx
//
//  Created by mceruti on 26.11.18.
//  Copyright © 2015-18 Peter Mannel-Wiedemann.
//  Additional Fixes and Tweaks by Matteo Ceruti
//  All rights reserved.
//

import Foundation
import Cocoa

// The aem instance's Status Bar Item
class StatusBarItem {
    
    internal let statusBarItem:NSStatusItem!
    internal let instance: AEMInstance!
    internal let menu: InstanceMenu!
    
    init(target: ViewController!, instance:AEMInstance!){
        self.instance = instance;
        statusBarItem = NSStatusBar.system.statusItem(withLength: -1)
        statusBarItem.target = target
        let icon = NSImage(named: NSImage.Name(rawValue: String(instance.icon.last!)))
        statusBarItem.image = icon
        menu = InstanceMenu(target:target, instance: instance)
        statusBarItem.menu = self.menu
    }
    
    // remove this item from the system's status menubar
    func removeFromStatusBar(){
        NSStatusBar.system.removeStatusItem(self.statusBarItem)
    }
    
    func updateStatus(){
        menu.updateStatus()
    }
    
    
    
}
