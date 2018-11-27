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


typealias AEMInstanceSupplier =  ()->(AEMInstance?)

class InstanceMenu : NSMenu {
    
    var statusMenuItem:NSMenuItem?
    let instance:()->(AEMInstance?)
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(target: InstanceMenuDelegate!, instance: @escaping AEMInstanceSupplier , statusBarItem:Bool=false, isContextMenu:Bool=false){
        
        if(statusBarItem) {
            statusMenuItem = NSMenuItem(title: instance()!.name, action: nil, keyEquivalent: "")
            statusMenuItem!.isEnabled = false
        }
        
        self.instance = instance
        
        super.init(title: "Instances")
        
        if !isContextMenu && !statusBarItem {
            addItem(NewInstanceMenuItem(t: "New", a: {target.newInstance()}, k: "N",{nil}))
        }
        
        if statusBarItem {
            addItem(statusMenuItem!)
        }
        else {
            addItem(InstanceMenuItem(t: "Delete", a: {target.deleteInstance(instance)}, k: "D",instance))
        }
        
        addItem(InstanceMenuItem(t: "Edit", a: {target.editInstance(instance)}, k: "E",instance))
        
        
        autoenablesItems = true
        
        
        addItem(NSMenuItem.separator())
        
        let startInstanceMenuItem = InstanceMenuItem(t: "Start Instance", a: {target.startInstance(instance)}, k: "",instance)
        
        addItem(startInstanceMenuItem)

        let stopInstanceMenuItem = InstanceMenuItem(t: "Stop Instance", a: {target.stopInstance(instance)}, k: "",instance)
        addItem(stopInstanceMenuItem)
        
        addItem(NSMenuItem.separator())
        
        let openAuthorMenuItem = InstanceMenuItem(t: "Open Author/Publish", a: {target.openAuthor(instance)}, k: "",instance)
        addItem(openAuthorMenuItem)
        
        let openCRX = InstanceMenuItem(t: "Open CRX", a: {target.openCRX(instance)}, k: "",instance)
        addItem(openCRX)
        
        let openCRXDE = InstanceMenuItem(t: "Open CRXDE Lite", a: {target.openCRXDE(instance)}, k: "",instance)
        addItem(openCRXDE)
        
        let openFelixConsole = InstanceMenuItem(t: "Open Felix Console", a: {target.openFelixConsole(instance)}, k: "",instance)
        addItem(openFelixConsole)
        
        addItem(NSMenuItem.separator())
        
        let openInstanceFolder = InstanceMenuItem(t: "Open in \"Finder\"", a: {target.openInstanceFolder(instance)}, k: "",instance)
        addItem(openInstanceFolder)
        
        addItem(NSMenuItem.separator())
        
        let eLog = InstanceMenuItem(t: "Error Log", a: {target.openErrorLog(instance)}, k: "", instance)
        addItem(eLog)
        
        let rLog = InstanceMenuItem(t: "Request Log", a: {target.openRequestLog(instance)}, k: "",instance)
        addItem(rLog)
        
        
    }

    func updateStatus(){
        statusMenuItem?.title = getStatusText()
    }
    
    func getStatusText() -> String {
        return InstanceMenu.getStatusText(instance: self.instance())
    }
    
    static func getStatusText(instance:AEMInstance!) -> String {
        return "\(instance.name) (\(instance.status.rawValue))"
    }
}

protocol InstanceMenuDelegate  {
    
    func notifyNoInstanceSelected()
    func deleteInstance(_ instance: AEMInstanceSupplier)
    func newInstance()
    func editInstance(_ instance: AEMInstanceSupplier)
    
    
    
    func startInstance(_ instance: AEMInstanceSupplier)
    func stopInstance(_ instance: AEMInstanceSupplier)
    func openAuthor(_ instance: AEMInstanceSupplier)
    
    func openCRX(_ instance: AEMInstanceSupplier)
    func openCRXDE(_ instance: AEMInstanceSupplier)
    func openFelixConsole(_ instance: AEMInstanceSupplier)
    func openInstanceFolder(_ instance: AEMInstanceSupplier)
    func openRequestLog(_ instance: AEMInstanceSupplier)
    func openErrorLog(_ instance: AEMInstanceSupplier)
    

    
}

class NewInstanceMenuItem : InstanceMenuItem {
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}

class InstanceMenuItem : NSMenuItem, NSMenuItemValidation {
    var actionClosure: () -> ()
    internal let instance : AEMInstanceSupplier
    
    init(t: String, a: @escaping ()->(), k: String, _ instance: @escaping AEMInstanceSupplier ) {
        self.actionClosure = a
        self.instance = instance;
        super.init(title: t, action: #selector(InstanceMenuItem.action(sender:)), keyEquivalent: k)
        self.target = self;
       
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func action(sender: InstanceMenuItem) {
        self.actionClosure()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return instance() != nil
    }
    
   
}

