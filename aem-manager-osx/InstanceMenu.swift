//
//  InstanceMenu.swift
//  aem-manager-osx
//
//  Created by mceruti on 27.11.18.
//  Copyright © 2018 Peter Mannel-Wiedemann.
//  Fixes and additional Tweaks by Matteo Ceruti.
//  All rights reserved.
//

import Foundation
import Cocoa

class InstanceMenu : NSMenu {
    
    let statusMenuItem:NSMenuItem!
    let instance:AEMInstance!
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(target: ViewController!, instance:AEMInstance!){
        
        let statusText = InstanceMenu.getStatusText(instance:instance)
        
        statusMenuItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled=false
        
        self.instance = instance
        
        super.init(title: "invisible")
        
        autoenablesItems = false
        
        addItem(statusMenuItem)
        addItem(NSMenuItem.separator())
        
        let startInstanceMenuItem = InstanceMenuItem(t: "Start Instance", a: #selector(ViewController.startInstance2(_:)), k: "",instance: instance)
        startInstanceMenuItem.target = target
        addItem(startInstanceMenuItem)
        
        let stopInstanceMenuItem = InstanceMenuItem(t: "Stop Instance", a: #selector(ViewController.stopInstance2(_:)), k: "",instance: instance)
        stopInstanceMenuItem.target = target
        addItem(stopInstanceMenuItem)
        
        addItem(NSMenuItem.separator())
        
        let openAuthorMenuItem = InstanceMenuItem(t: "Open Author/Publish", a: #selector(ViewController.openAuthor2(_:)), k: "",instance: instance)
        openAuthorMenuItem.target = target
        addItem(openAuthorMenuItem)
        
        let openCRX = InstanceMenuItem(t: "Open CRX", a: #selector(ViewController.openCRX2(_:)), k: "",instance: instance)
        openCRX.target = target
        addItem(openCRX)
        
        let openCRXDE = InstanceMenuItem(t: "Open CRXDE Lite", a: #selector(ViewController.openCRXDE2(_:)), k: "",instance: instance)
        openCRXDE.target = target
        addItem(openCRXDE)
        
        let openFelixConsole = InstanceMenuItem(t: "Open Felix Console", a: #selector(ViewController.openFelixConsole2(_:)), k: "",instance: instance)
        openFelixConsole.target = target
        addItem(openFelixConsole)
        
        addItem(NSMenuItem.separator())
        
        let openInstanceFolder = InstanceMenuItem(t: "Open in \"Finder\"", a: #selector(ViewController.openInstanceFolder2(_:)), k: "",instance: instance)
        openInstanceFolder.target = target
        addItem(openInstanceFolder)
        
        addItem(NSMenuItem.separator())
        
        let eLog = InstanceMenuItem(t: "Error Log", a: #selector(ViewController.openErrorLog2(_:)), k: "",instance: instance)
        eLog.target = target
        addItem(eLog)
        
        let rLog = InstanceMenuItem(t: "Request Log", a: #selector(ViewController.openRequestLog2(_:)), k: "",instance: instance)
        rLog.target = target
        addItem(rLog)
        
    }
    
    func updateStatus(){
        statusMenuItem.title = getStatusText()
    }
    
    func getStatusText() -> String {
        return InstanceMenu.getStatusText(instance: self.instance)
    }
    
    static func getStatusText(instance:AEMInstance!) -> String {
        return "\(instance.name) (\(instance.status.rawValue))"
    }
}


class InstanceMenuItem : NSMenuItem {
    var ins: AEMInstance
    init(t: String, a:Selector, k: String,instance:AEMInstance) {
        ins = instance
        super.init(title: t, action: a, keyEquivalent: k)
        
        
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
