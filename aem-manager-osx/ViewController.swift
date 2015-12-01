//
//  ViewController.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 27.11.15.
//
//

import Cocoa

class ViewController: NSViewController {
    
    // MARK: properties
    @IBOutlet weak var table: NSTableView!
    
    
    var instances = AEMInstance.loadAEMInstances()
    
    var selectedInstance: AEMInstance?
    
    var guiarray:[NSWindowController] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.setDataSource(self)
        table.setDelegate(self)
        
        // Rückverweis in AppDelegate-Objekt
        let app = NSApplication.sharedApplication().delegate as! AppDelegate
        app.mainVC = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func editInstance(sender: NSMenuItem) {
        
    
        if table.selectedRow <= 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            
            // open preferences dialog with instance
            print("Edit Instance")
            if let winCrtl = storyboard!.instantiateControllerWithIdentifier("aemInstanceGUI") as? NSWindowController {
                if let aemInstanceGui = winCrtl.contentViewController as? AemInstanceController{
                    // add data
                    aemInstanceGui.aeminstance = selectedInstance
                }
                winCrtl.showWindow(self)
                guiarray.append(winCrtl)
            }
        }
        
        
    }
    
    @IBAction func newInstance(sender: NSMenuItem) {
        
        // open new preferences dialog
        print("New Instance")
        if let winCrtl = storyboard!.instantiateControllerWithIdentifier("aemInstanceGUI") as? NSWindowController {
            
            if let aemInstanceGui = winCrtl.contentViewController as? AemInstanceController{
                // add data
                aemInstanceGui.aeminstance = AEMInstance()
            }
            winCrtl.showWindow(self)
            guiarray.append(winCrtl)
        }
        
    }
    
    @IBAction func startInstance(sender: NSMenuItem) {
        
        
        if table.selectedRow <= 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Start Instance")
        }
        
    }
    @IBAction func stopInstance(sender: NSMenuItem) {
        
        if table.selectedRow <= 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Stop Instance")
        }
        
        
        
    }
    @IBAction func openAuthor(sender: NSMenuItem) {
        if table.selectedRow <= 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open Author/Publish")
        }
        
        
    }
    @IBAction func openCRXDE(sender: NSMenuItem) {
        if table.selectedRow <= 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open CRX DE")
        }
        
        
    }
    
    @IBAction func openFelixConsole(sender: NSMenuItem) {
        if table.selectedRow <= 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open Felix Console")
        }
        
        
    }
    
    
    
}

extension ViewController: NSTableViewDataSource , NSTableViewDelegate {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return instances.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let coid = tableColumn?.identifier {
            switch coid {
            case "name": return instances[row].name
            case "path": return instances[row].path
            case "type": return instances[row].type
            case "status": return instances[row].status
            case "url": return instances[row].url
            default: break
            }
            
        }
        return nil
    }
    func tableViewSelectionDidChange(notification: NSNotification) {
        if table.selectedRow >= 0 {
            print(instances[table.selectedRow].name)
            // set seletected instance
            selectedInstance = instances[table.selectedRow]
            
        }
    }
    
    
}



