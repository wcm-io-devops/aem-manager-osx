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

class StatusBarItem {
    
    internal let statusBarItem:NSStatusItem!
    internal let instance: AEMInstance!
    
    init(target: ViewController!, instance:AEMInstance!){
        self.instance = instance;
        statusBarItem = NSStatusBar.system.statusItem(withLength: -1)
        statusBarItem.target = target
        let icon = NSImage(named: NSImage.Name(rawValue: String(instance.icon.last!)))
        statusBarItem.image = icon
        
        
        let menu : NSMenu = NSMenu()
        menu.autoenablesItems = false
        
        let startInstanceMenuItem = InstanceMenuItem(t: "Start Instance", a: #selector(ViewController.startInstance2(_:)), k: "",instance: instance)
        startInstanceMenuItem.target = target
        menu.addItem(startInstanceMenuItem)
        
        let stopInstanceMenuItem = InstanceMenuItem(t: "Stop Instance", a: #selector(ViewController.stopInstance2(_:)), k: "",instance: instance)
        stopInstanceMenuItem.target = target
        menu.addItem(stopInstanceMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let openAuthorMenuItem = InstanceMenuItem(t: "Open Author/Publish", a: #selector(ViewController.openAuthor2(_:)), k: "",instance: instance)
        openAuthorMenuItem.target = target
        menu.addItem(openAuthorMenuItem)
        
        let openCRX = InstanceMenuItem(t: "Open CRX", a: #selector(ViewController.openCRX2(_:)), k: "",instance: instance)
        openCRX.target = target
        menu.addItem(openCRX)
        
        let openCRXDE = InstanceMenuItem(t: "Open CRXDE Lite", a: #selector(ViewController.openCRXDE2(_:)), k: "",instance: instance)
        openCRXDE.target = target
        menu.addItem(openCRXDE)
        
        let openFelixConsole = InstanceMenuItem(t: "Open Felix Console", a: #selector(ViewController.openFelixConsole2(_:)), k: "",instance: instance)
        openFelixConsole.target = target
        menu.addItem(openFelixConsole)
        
        menu.addItem(NSMenuItem.separator())
        
        let openInstanceFolder = InstanceMenuItem(t: "Open in \"Finder\"", a: #selector(ViewController.openInstanceFolder2(_:)), k: "",instance: instance)
        openInstanceFolder.target = target
        menu.addItem(openInstanceFolder)
        
        menu.addItem(NSMenuItem.separator())
        
        let eLog = InstanceMenuItem(t: "Error Log", a: #selector(ViewController.openErrorLog2(_:)), k: "",instance: instance)
        eLog.target = target
        menu.addItem(eLog)
        
        let rLog = InstanceMenuItem(t: "Request Log", a: #selector(ViewController.openRequestLog2(_:)), k: "",instance: instance)
        rLog.target = target
        menu.addItem(rLog)
        
        statusBarItem.menu = menu
        
     
        
    }
    
    // remove this item from the system's status menubar
    func removeFromStatusBar(){
        NSStatusBar.system.removeStatusItem(self.statusBarItem)
    }
    
}
