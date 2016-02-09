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
    
    var menuInstance: AEMInstance?
    
    var guiarray:[NSWindowController] = []
    var items: [NSStatusItem] = []
    
    
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
        
        checkVersionUpdate()
        
    }
    
    func checkVersionUpdate(){
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let version = nsObject as! String
      
        var tagName: String = ""
        
        let urlPath: String = "https://api.github.com/repos/wcm-io-devops/aem-manager-osx/releases/latest"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse? >= nil
      
        do {
            let dataVal: NSData = try  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            tagName = jsonResult["tag_name"] as! String
            if tagName.hasPrefix("v"){
                tagName.removeAtIndex(tagName.startIndex)
                
            }
            print("Tagname: \(tagName)")
            
        } catch (let e) {
            print(e)
        }
        /*
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://api.github.com/repos/wcm-io-devops/aem-manager-osx/releases/latest")!, completionHandler: { (data, response, error) -> Void in
            do{
              let  str = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as![String:AnyObject]
                
                tagName = str["tag_name"] as! String
                if tagName.hasPrefix("v"){
                    tagName.removeAtIndex(tagName.startIndex)
                    
                }
                print("Tagname: \(tagName)")
                print(str)
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
        */
        print(version)
        if version.versionToInt().lexicographicalCompare(tagName.versionToInt()) {
            performSegueWithIdentifier("versionInfo",sender: self)
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.setDataSource(self)
        table.setDelegate(self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableData:", name: "reload", object: nil)
        
        for instance in instances{
            if instance.showIcon {
                let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
                statusBarItem.target = self
                items.append(statusBarItem)
                let icon = NSImage(named: String(instance.icon.characters.last!))
                statusBarItem.image = icon
                
                
                let menu : NSMenu = NSMenu()
                menu.autoenablesItems = false
                
                let startInstanceMenuItem = InstanceMenuItem(t: "Start Instance", a: "startInstance2:", k: "",instance: instance)
                startInstanceMenuItem.target = self
                menu.addItem(startInstanceMenuItem)
                
                let stopInstanceMenuItem = InstanceMenuItem(t: "Stop Instance", a: "stopInstance2:", k: "",instance: instance)
                stopInstanceMenuItem.target = self
                menu.addItem(stopInstanceMenuItem)
                
                menu.addItem(NSMenuItem.separatorItem())
                
                let openAuthorMenuItem = InstanceMenuItem(t: "Open Author/Publish", a: "openAuthor2:", k: "",instance: instance)
                openAuthorMenuItem.target = self
                menu.addItem(openAuthorMenuItem)
                
                let openCRX = InstanceMenuItem(t: "Open CRX", a: "openCRX2:", k: "",instance: instance)
                openCRX.target = self
                menu.addItem(openCRX)
                
                let openCRXContentExplorer = InstanceMenuItem(t: "Open CRX Content Explorer", a: "openCRXContentExplorer2:", k: "",instance: instance)
                openCRXContentExplorer.target = self
                menu.addItem(openCRXContentExplorer)
                
                let openCRXDE = InstanceMenuItem(t: "Open CRXDE Lite", a: "openCRXDE2:", k: "",instance: instance)
                openCRXContentExplorer.target = self
                menu.addItem(openCRXDE)
                
                let openFelixConsole = InstanceMenuItem(t: "Open Felix Console", a: "openFelixConsole2:", k: "",instance: instance)
                openFelixConsole.target = self
                menu.addItem(openFelixConsole)
                
                menu.addItem(NSMenuItem.separatorItem())
                
                let eLog = InstanceMenuItem(t: "Error Log", a: "openErrorLog2:", k: "",instance: instance)
                eLog.target = self
                menu.addItem(eLog)
                
                let rLog = InstanceMenuItem(t: "Request Log", a: "openRequestLog2:", k: "",instance: instance)
                rLog.target = self
                menu.addItem(rLog)
                
                statusBarItem.menu = menu
                
            }
        }
        
        
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
    
    @IBAction func deleteInstance(sender: NSMenuItem) {
        
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            if instances.contains(selectedInstance!){
                instances.removeAtIndex(instances.indexOf(selectedInstance!)!)
                
                print("Deleting Instance with name:\(selectedInstance!.name) and id: \(selectedInstance?.id)")
                AEMInstance.save(instances)
                
                NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
            }
        }
        
    }
    
    @IBAction func startInstance(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            
            backgroundThread(background: {
                AemActions.startInstance(self.selectedInstance!)
                //NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
                },completion: {
                    // A function to run in the foreground when the background thread is complete
                    //   NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
            })
        }
        
    }
    
    
    func startInstance2(sender: InstanceMenuItem) -> Void {
        
        backgroundThread(background: {
            AemActions.startInstance(sender.ins)
            //NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
            },completion: {
                // A function to run in the foreground when the background thread is complete
                //   NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
        })
    }
    
    
    
    @IBAction func stopInstance(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Stop Instance")
            AemActions.stopInstance(selectedInstance!)
        }
    }
    
    func stopInstance2(sender: InstanceMenuItem) {
        AemActions.stopInstance(sender.ins)
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
    
    func openAuthor2(sender: InstanceMenuItem) {
        if let url = NSURL(string: AEMInstance.getUrlWithContextPath(sender.ins)){
            NSWorkspace.sharedWorkspace().openURL(url)
        }
        
    }
    
    @IBAction func openCRX(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            print("Open CRX")
            openFuncCRX(selectedInstance!)
            
        }
    }
    func openCRX2(sender: InstanceMenuItem) {
        
        print("Open CRX")
        openFuncCRX(sender.ins)
        
        
    }
    func openFuncCRX(instace: AEMInstance){
        var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
        url.appendContentsOf("/crx/explorer/")
        if(selectedInstance?.type != AEMInstance.defaultType){
            url = AEMInstance.getUrl(instace)
            url.appendContentsOf("/crx/")
        }
        if let openUrl = NSURL(string:url){
            NSWorkspace.sharedWorkspace().openURL(openUrl)
        }
    }
    
    @IBAction func openCRXContentExplorer(sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            openCRXContentExplorerFunc(selectedInstance!)
            
        }
    }
    func openCRXContentExplorer2(sender: InstanceMenuItem) {
        
        openCRXContentExplorerFunc(sender.ins)
        
    }
    
    func openCRXContentExplorerFunc(instance: AEMInstance) {
        print("Open CRX Content Explorer")
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.appendContentsOf("/crx/explorer/browser/")
        if(selectedInstance?.type != AEMInstance.defaultType){
            url = AEMInstance.getUrl(instance)
            url.appendContentsOf("/crx/browser/index.jsp")
        }
        if let openUrl = NSURL(string:url){
            NSWorkspace.sharedWorkspace().openURL(openUrl)
        }
    }
    
    @IBAction func openCRXDE(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            openCRXDEFunc(selectedInstance!)
        }
    }
    
    func openCRXDEFunc(instance : AEMInstance) {
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.appendContentsOf("/crx/de/")
        if selectedInstance?.type != AEMInstance.defaultType {
            url = AEMInstance.getUrl(instance)
            url.appendContentsOf("/crxde")
        }
        if let openUrl = NSURL(string: url){
            NSWorkspace.sharedWorkspace().openURL(openUrl)
        }
    }
    
    func openCRXDE2(sender: InstanceMenuItem) {
        openCRXDEFunc(sender.ins)
    }
    
    @IBAction func openFelixConsole(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            openFelixConsoleFunc(selectedInstance!)
        }
    }
    
    func openFelixConsoleFunc(instance: AEMInstance){
        print("Open Felix Console")
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.appendContentsOf("/system/console")
        if let openUrl = NSURL(string: url){
            NSWorkspace.sharedWorkspace().openURL(openUrl)
        }
    }
    
    func openFelixConsole2(sender: InstanceMenuItem) {
        openFelixConsoleFunc(sender.ins)
    }
    
    @IBAction func openErrorLog(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            openErrorLogFunc(selectedInstance!)
        }
    }
    
    func openErrorLog2(sender: InstanceMenuItem) {
        NSApp.activateIgnoringOtherApps(true)
        
        self.view.window?.makeKeyAndOrderFront(self)
        self.view.window!.orderFront(self)
        print("open Error Log")
        openErrorLogFunc(sender.ins)
    }
    
    func openErrorLogFunc(instance: AEMInstance){
        openLogFile(instance, log: "error.log")
    }
    
    func openLogFile(instance:AEMInstance, log: String){
        var url = AEMInstance.getLogBaseFolder(instance)
        url.appendContentsOf(log)
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url){
            NSWorkspace.sharedWorkspace().openFile(url)
        }
    }
    
    @IBAction func openRequestLog(sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegueWithIdentifier("noInstance",sender: self)
        }else{
            openRequestLogFunc(selectedInstance!)
        }
    }
    
    func openRequestLog2(sender: InstanceMenuItem) {
        openRequestLogFunc(sender.ins)
    }
    
    func openRequestLogFunc(instance: AEMInstance){
        openLogFile(instance, log: "request.log")
    }
    
    func reloadTableData(notification: NSNotification){
        instances = AEMInstance.loadAEMInstances()
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
                /* case "status":
                let status = instances[row].status
                switch status {
                case .Running: return "Running"
                case .Starting_Stopping: return "Starting/Stopping"
                case .Unknown: return "Unknown"
                case .NotActive: return "Not active"
                case .Disabled: return "Disabled"
                }
                */
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

class InstanceMenuItem : NSMenuItem {
    var ins: AEMInstance
    init(t: String, a:Selector, k: String,instance:AEMInstance) {
        ins = instance
        super.init(title: t, action: a, keyEquivalent: k)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    func versionToInt() -> [Int] {
        return self.componentsSeparatedByString(".")
            .map {
                Int.init($0) ?? 0
        }
    }
}

