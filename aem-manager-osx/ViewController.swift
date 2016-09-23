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
    
    var timer = Timer()
    var timer2 = Timer()
    var tagName: String = ""
    
    func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if(background != nil){ background!(); }
            
            let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    
    
    override func viewDidAppear() {
        checkVersion()
        
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ViewController.checkStatus), userInfo: nil, repeats: true)
        
        timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.checkVersion), userInfo: nil, repeats: false)
        
    }
    
    func checkStatus(){
        for instance in instances {
            AemActions.checkBundleState(instance)
        }
        
        table.reloadData()
    }
    
    @IBAction func checkVersionUpdate(_ sender: NSMenuItem){
        checkVersion()
        
    }
    
    func checkVersion(){
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String
        
        let urlPath: String = "https://api.github.com/repos/wcm-io-devops/aem-manager-osx/releases/latest"
        
        let task = URLSession.shared.dataTask(with: URL(string: urlPath)!, completionHandler: { (data, response, error) -> Void in
            do{
                let  str = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as![String:AnyObject]
                
                self.tagName = str["tag_name"] as! String
                if self.tagName.hasPrefix("v"){
                    self.tagName.remove(at: self.tagName.startIndex)
                    
                }
                print("Tagname: \(self.tagName)")
                
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
        
        print("ALL: \(version) : \(tagName)")
        
        
        if version.versionToInt().lexicographicallyPrecedes(tagName.versionToInt()) {
            performSegue(withIdentifier: "versionInfo",sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTableData(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        for instance in instances{
            if instance.showIcon {
                let statusBarItem = NSStatusBar.system().statusItem(withLength: -1)
                statusBarItem.target = self
                items.append(statusBarItem)
                let icon = NSImage(named: String(instance.icon.characters.last!))
                statusBarItem.image = icon
                
                
                let menu : NSMenu = NSMenu()
                menu.autoenablesItems = false
                
                let startInstanceMenuItem = InstanceMenuItem(t: "Start Instance", a: #selector(ViewController.startInstance2(_:)), k: "",instance: instance)
                startInstanceMenuItem.target = self
                menu.addItem(startInstanceMenuItem)
                
                let stopInstanceMenuItem = InstanceMenuItem(t: "Stop Instance", a: #selector(ViewController.stopInstance2(_:)), k: "",instance: instance)
                stopInstanceMenuItem.target = self
                menu.addItem(stopInstanceMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                
                let openAuthorMenuItem = InstanceMenuItem(t: "Open Author/Publish", a: #selector(ViewController.openAuthor2(_:)), k: "",instance: instance)
                openAuthorMenuItem.target = self
                menu.addItem(openAuthorMenuItem)
                
                let openCRX = InstanceMenuItem(t: "Open CRX", a: #selector(ViewController.openCRX2(_:)), k: "",instance: instance)
                openCRX.target = self
                menu.addItem(openCRX)
                
                let openCRXContentExplorer = InstanceMenuItem(t: "Open CRX Content Explorer", a: #selector(ViewController.openCRXContentExplorer2(_:)), k: "",instance: instance)
                openCRXContentExplorer.target = self
                menu.addItem(openCRXContentExplorer)
                
                let openCRXDE = InstanceMenuItem(t: "Open CRXDE Lite", a: #selector(ViewController.openCRXDE2(_:)), k: "",instance: instance)
                openCRXContentExplorer.target = self
                menu.addItem(openCRXDE)
                
                let openFelixConsole = InstanceMenuItem(t: "Open Felix Console", a: #selector(ViewController.openFelixConsole2(_:)), k: "",instance: instance)
                openFelixConsole.target = self
                menu.addItem(openFelixConsole)
                
                menu.addItem(NSMenuItem.separator())
                
                let openInstanceFolder = InstanceMenuItem(t: "Open in \"Finder\"", a: #selector(ViewController.openInstanceFolder2(_:)), k: "",instance: instance)
                openInstanceFolder.target = self
                menu.addItem(openInstanceFolder)
                
                menu.addItem(NSMenuItem.separator())
                
                let eLog = InstanceMenuItem(t: "Error Log", a: #selector(ViewController.openErrorLog2(_:)), k: "",instance: instance)
                eLog.target = self
                menu.addItem(eLog)
                
                let rLog = InstanceMenuItem(t: "Request Log", a: #selector(ViewController.openRequestLog2(_:)), k: "",instance: instance)
                rLog.target = self
                menu.addItem(rLog)
                
                statusBarItem.menu = menu
                
            }
        }
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func editInstance(_ sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            
            // open preferences dialog with instance
            if let winCrtl = storyboard!.instantiateController(withIdentifier: "aemInstanceGUI") as? NSWindowController {
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
    
    @IBAction func newInstance(_ sender: NSMenuItem) {
        
        // open new preferences dialog
        if let winCrtl = storyboard!.instantiateController(withIdentifier: "aemInstanceGUI") as? NSWindowController {
            
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
    
    @IBAction func deleteInstance(_ sender: NSMenuItem) {
        
        
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            if instances.contains(selectedInstance!){
                instances.remove(at: instances.index(of: selectedInstance!)!)
                
                print("Deleting Instance with name:\(selectedInstance!.name) and id: \(selectedInstance?.id)")
                AEMInstance.save(instances)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
            }
        }
        
    }
    
    @IBAction func startInstance(_ sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            
            backgroundThread(background: {
                AemActions.startInstance(self.selectedInstance!)
                
                },completion: {
                    
            })
        }
        
    }
    
    
    func startInstance2(_ sender: InstanceMenuItem) -> Void {
        
        backgroundThread(background: {
            AemActions.startInstance(sender.ins)
            },completion: {
                
        })
    }
    
    
    
    @IBAction func stopInstance(_ sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            print("Stop Instance")
            AemActions.stopInstance(selectedInstance!)
        }
    }
    
    func stopInstance2(_ sender: InstanceMenuItem) {
        AemActions.stopInstance(sender.ins)
    }
    
    @IBAction func openAuthor(_ sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            print("Open Author/Publish")
            if let url = URL(string: AEMInstance.getUrlWithContextPath(selectedInstance!)){
                NSWorkspace.shared().open(url)
            }
        }
    }
    
    func openAuthor2(_ sender: InstanceMenuItem) {
        if let url = URL(string: AEMInstance.getUrlWithContextPath(sender.ins)){
            NSWorkspace.shared().open(url)
        }
        
    }
    
    @IBAction func openCRX(_ sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            print("Open CRX")
            openFuncCRX(selectedInstance!)
            
        }
    }
    func openCRX2(_ sender: InstanceMenuItem) {
        
        print("Open CRX")
        openFuncCRX(sender.ins)
        
        
    }
    func openFuncCRX(_ instace: AEMInstance){
        var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
        url.append("/crx/explorer/")
        if(selectedInstance?.type != AEMInstance.defaultType){
            url = AEMInstance.getUrl(instace)
            url.append("/crx/")
        }
        if let openUrl = URL(string:url){
            NSWorkspace.shared().open(openUrl)
        }
    }
    
    @IBAction func openCRXContentExplorer(_ sender: NSMenuItem) {
        
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            openCRXContentExplorerFunc(selectedInstance!)
            
        }
    }
    func openCRXContentExplorer2(_ sender: InstanceMenuItem) {
        
        openCRXContentExplorerFunc(sender.ins)
        
    }
    
    func openCRXContentExplorerFunc(_ instance: AEMInstance) {
        print("Open CRX Content Explorer")
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.append("/crx/explorer/browser/")
        if(selectedInstance?.type != AEMInstance.defaultType){
            url = AEMInstance.getUrl(instance)
            url.append("/crx/browser/index.jsp")
        }
        if let openUrl = URL(string:url){
            NSWorkspace.shared().open(openUrl)
        }
    }
    
    @IBAction func openCRXDE(_ sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            openCRXDEFunc(selectedInstance!)
        }
    }
    
    @IBAction func openInstanceFolder(_ sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            openInstanceFolderFunc(selectedInstance!)
        }
    }
    
    func openInstanceFolder2(_ sender: InstanceMenuItem) {
        openInstanceFolderFunc(sender.ins)
    }
    
    func openInstanceFolderFunc(_ instance: AEMInstance){
        print("Open Instance Folder")
        
        NSWorkspace.shared().selectFile(instance.path, inFileViewerRootedAtPath: "")
        
    }
    
    
    func openCRXDEFunc(_ instance : AEMInstance) {
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.append("/crx/de/")
        if selectedInstance?.type != AEMInstance.defaultType {
            url = AEMInstance.getUrl(instance)
            url.append("/crxde")
        }
        if let openUrl = URL(string: url){
            NSWorkspace.shared().open(openUrl)
        }
    }
    
    func openCRXDE2(_ sender: InstanceMenuItem) {
        openCRXDEFunc(sender.ins)
    }
    
    @IBAction func openFelixConsole(_ sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            openFelixConsoleFunc(selectedInstance!)
        }
    }
    
    func openFelixConsoleFunc(_ instance: AEMInstance){
        print("Open Felix Console")
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.append("/system/console")
        if let openUrl = URL(string: url){
            NSWorkspace.shared().open(openUrl)
        }
    }
    
    func openFelixConsole2(_ sender: InstanceMenuItem) {
        openFelixConsoleFunc(sender.ins)
    }
    
    @IBAction func openErrorLog(_ sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            openErrorLogFunc(selectedInstance!)
        }
    }
    
    func openErrorLog2(_ sender: InstanceMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        
        self.view.window?.makeKeyAndOrderFront(self)
        self.view.window!.orderFront(self)
        print("open Error Log")
        openErrorLogFunc(sender.ins)
    }
    
    func openErrorLogFunc(_ instance: AEMInstance){
        openLogFile(instance, log: "error.log")
    }
    
    func openLogFile(_ instance:AEMInstance, log: String){
        var url = AEMInstance.getLogBaseFolder(instance)
        url.append(log)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url){
            NSWorkspace.shared().openFile(url)
        }
    }
    
    @IBAction func openRequestLog(_ sender: NSMenuItem) {
        if table.selectedRow < 0 {
            performSegue(withIdentifier: "noInstance",sender: self)
        }else{
            openRequestLogFunc(selectedInstance!)
        }
    }
    
    func openRequestLog2(_ sender: InstanceMenuItem) {
        openRequestLogFunc(sender.ins)
    }
    
    func openRequestLogFunc(_ instance: AEMInstance){
        openLogFile(instance, log: "request.log")
    }
    
    func reloadTableData(_ notification: Notification){
        instances = AEMInstance.loadAEMInstances()
        table.reloadData()
    }
    
}


extension ViewController: NSTableViewDataSource , NSTableViewDelegate {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return instances.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let coid = tableColumn?.identifier {
            switch coid {
            case "name": return instances[row].name
            case "path": return instances[row].path
            case "type": return instances[row].type
            case "status":
                let status = instances[row].status
                switch status {
                case .running: return "Running"
                case .starting_Stopping: return "Starting/Stopping"
                case .unknown: return "Unknown"
                case .notActive: return "Not active"
                case .disabled: return "Disabled"
                }
                
            case "url": return AEMInstance.getUrl(instances[row])
            default: break
            }
            
        }
        return nil
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
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
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension String {
    func versionToInt() -> [Int] {
        return self.components(separatedBy: ".")
            .map {
                Int.init($0) ?? 0
        }
    }
}

