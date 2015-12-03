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
    
    func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    override func viewDidAppear() {
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.setDataSource(self)
        table.setDelegate(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableData:", name: "reload", object: nil)

        let app = NSApplication.sharedApplication().delegate as! AppDelegate
        app.mainVC = self

    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func editInstance(sender: NSMenuItem) {
        
    
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            
            // open preferences dialog with instance
            if let winCrtl = storyboard!.instantiateControllerWithIdentifier("aemInstanceGUI") as? NSWindowController {
                if let aemInstanceGui = winCrtl.contentViewController as? AemInstanceController{
                    // add data
                    print("Selected Instance in table with id \(selectedInstance?.id) and name \(selectedInstance?.name)")
                    aemInstanceGui.aeminstance = selectedInstance
                    aemInstanceGui.instances = instances
                    print("Edit Instance with name : \(aemInstanceGui.aeminstance!.name) and id: \(aemInstanceGui.aeminstance!.id)")
                }
                winCrtl.showWindow(self)
                guiarray.append(winCrtl)
            }
        }
        
    }
    
    @IBAction func newInstance(sender: NSMenuItem) {
        
        // open new preferences dialog
        if let winCrtl = storyboard!.instantiateControllerWithIdentifier("aemInstanceGUI") as? NSWindowController {
            
            if let aemInstanceGui = winCrtl.contentViewController as? AemInstanceController{
                // add data
                aemInstanceGui.aeminstance = AEMInstance()
                aemInstanceGui.instances = instances
 
                print("New Instance with id \(aemInstanceGui.aeminstance!.id)")
            }
            winCrtl.showWindow(self)
            guiarray.append(winCrtl)
        }
        
    }
    
    @IBAction func startInstance(sender: NSMenuItem) {
        
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Start Instance")
            backgroundThread(background: {
                  AemActions.startInstance(self.selectedInstance!)
                 //NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
            },completion: {
                    // A function to run in the foreground when the background thread is complete
                   //   NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
            })
          
        }
        
    }
    
    @IBAction func stopInstance(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Stop Instance")
            AemActions.stopInstance(selectedInstance!)
        }
    }
    
    @IBAction func openAuthor(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open Author/Publish")
            if let url = NSURL(string: AEMInstance.getUrlWithContextPath(selectedInstance!)){
                NSWorkspace.sharedWorkspace().openURL(url)
            }
        }
    }
    
    @IBAction func openCRX(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open CRX")
            var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
            url.appendContentsOf("/crx/explorer/")
            if(selectedInstance?.type != AEMInstance.defaultType){
                url = AEMInstance.getUrl(selectedInstance!)
                url.appendContentsOf("/crx/")
            }
            if let openUrl = NSURL(string:url){
                 NSWorkspace.sharedWorkspace().openURL(openUrl)
            }
        }
    }
    
    @IBAction func openCRXContentExplorer(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open CRX Content Explorer")
            var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
            url.appendContentsOf("/crx/explorer/browser/")
            if(selectedInstance?.type != AEMInstance.defaultType){
                url = AEMInstance.getUrl(selectedInstance!)
                url.appendContentsOf("/crx/browser/index.jsp")
            }
            if let openUrl = NSURL(string:url){
                NSWorkspace.sharedWorkspace().openURL(openUrl)
            }
            
        }
    }
    
    @IBAction func openCRXDE(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
            url.appendContentsOf("/crx/de/")
            if selectedInstance?.type != AEMInstance.defaultType {
                url = AEMInstance.getUrl(selectedInstance!)
                url.appendContentsOf("/crxde")
            }
            if let openUrl = NSURL(string: url){
                NSWorkspace.sharedWorkspace().openURL(openUrl)
            }
        }
    }
    
    @IBAction func openFelixConsole(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open Felix Console")
            var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
            url.appendContentsOf("/system/console")
            if let openUrl = NSURL(string: url){
                NSWorkspace.sharedWorkspace().openURL(openUrl)
            }
        }
    }
    
    func reloadTableData(notification: NSNotification){
        table.reloadData()
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
            case "status":
                let status = instances[row].status
                switch status {
                case .Running: return "Running"
                case .Starting_Stopping: return "Starting/Stopping"
                case .Unknown: return "Unknown"
                case .NotActive: return "Not active"
                case .Disabled: return "Disabled"
                }
            
            case "url": return AEMInstance.getUrl(instances[row])
            default: break
            }
            
        }
        return nil
    }
    func tableViewSelectionDidChange(notification: NSNotification) {
        if table.selectedRow >= 0 {
            print("Selected instance in table with name : \(instances[table.selectedRow].name) and id: \(instances[table.selectedRow].id)")
            // set seletected instance
            selectedInstance = instances[table.selectedRow]
            
        }
    }
    
    
}



