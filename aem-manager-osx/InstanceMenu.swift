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


protocol InstanceMenuDelegate  {
    
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


// Represents the Instances-Menu. It is also used for the context-menu. Therefore I had to introduce the abstraction AEMInstanceSupplier
// that supplies the AEM-Instance in question to support all those cases.
// The status-bar item's menus inherit from this class. See StatusBarInstanceMenu below
class InstanceMenu : NSMenu {
    internal let instance: AEMInstanceSupplier
    internal let target: InstanceMenuDelegate!
    
    init(target: InstanceMenuDelegate!, instance: @escaping AEMInstanceSupplier){
        
        self.instance = instance
        self.target = target
        
        super.init(title: "Instances")
        
        autoenablesItems = true
        
        addItems()
    }
    
    fileprivate func addItems(){
        addNewInstanceItem()
        addEditInstanceItem()
        addDeleteItem()
        
        addItem(NSMenuItem.separator())
        
        addStandardMenuItems()
    }
    
    fileprivate func addStandardMenuItems() {
        addItem(InstanceMenuItem(t: "Start Instance", a: {self.target.startInstance(self.instance)}, k: "",self.instance))
        
        addItem(InstanceMenuItem(t: "Stop Instance", a: {self.target.stopInstance(self.instance)}, k: "",self.instance))
        
        addItem(NSMenuItem.separator())
        
        addItem(InstanceMenuItem(t: "Open Author/Publish", a: {self.target.openAuthor(self.instance)}, k: "",self.instance))
        
        addItem(InstanceMenuItem(t: "Open CRX", a: {self.target.openCRX(self.instance)}, k: "",self.instance))
        
        addItem(InstanceMenuItem(t: "Open CRXDE Lite", a: {self.target.openCRXDE(self.instance)}, k: "",self.instance))
        
        addItem(InstanceMenuItem(t: "Open Felix Console", a: {self.target.openFelixConsole(self.instance)}, k: "",self.instance))
        
        addItem(NSMenuItem.separator())
        
        addItem(InstanceMenuItem(t: "Open in \"Finder\"", a: {self.target.openInstanceFolder(self.instance)}, k: "",self.instance))
        
        addItem(NSMenuItem.separator())
        
        addItem(InstanceMenuItem(t: "Error Log", a: {self.target.openErrorLog(self.instance)}, k: "", self.instance))
        
        addItem(InstanceMenuItem(t: "Request Log", a: {self.target.openRequestLog(self.instance)}, k: "",self.instance))
    }
    
    fileprivate func addEditInstanceItem() {
        addItem(InstanceMenuItem(t: "Edit", a: {self.target.editInstance(self.instance)}, k: "", self.instance))
    }
    
    fileprivate func addNewInstanceItem() {
        addItem(NewInstanceMenuItem(t: "New", a: {self.target.newInstance()}, k: "n",{nil}))
    }
    
    fileprivate func addDeleteItem(){
        addItem(InstanceMenuItem(t: "Delete", a: {self.target.deleteInstance(self.instance)}, k: String(UnicodeScalar(NSBackspaceCharacter)!),self.instance))
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



class StatusBarInstanceMenu : InstanceMenu {
    
    internal var statusMenuItem:NSMenuItem?
    
    
    override init(target: InstanceMenuDelegate!, instance: @escaping AEMInstanceSupplier){
        super.init(target: target,instance: instance)
    }
    
    fileprivate func addStatusItem() {
        statusMenuItem = NSMenuItem(title: instance()!.name, action: nil, keyEquivalent: "")
        statusMenuItem!.isEnabled = false
        
        addItem(statusMenuItem!)
    }
    
    fileprivate override func addItems() {
        addStatusItem()
        
        addItem(NSMenuItem.separator())
        
        addEditInstanceItem()
        
        addItem(NSMenuItem.separator())
        
        addStandardMenuItems()
    }
    
    
   
    
    func updateStatus(){
        statusMenuItem?.title = getStatusText()
    }
    
    func getStatusText() -> String {
        return StatusBarInstanceMenu.getStatusText(instance: self.instance())
    }
    
    static func getStatusText(instance:AEMInstance!) -> String {
        return "\(instance.name) (\(instance.status.rawValue))"
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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

