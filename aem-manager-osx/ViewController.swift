//
//  ViewController.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 27.11.15.
//
//

import Cocoa

import os.log

class ViewController: NSViewController, InstanceMenuDelegate {
  
    
    // MARK: properties
    @IBOutlet weak var table: NSTableView!
    
    
    var instances = AEMInstance.loadAEMInstances()
    weak var selectedInstance: AEMInstance?
    
    var guiarray:[NSWindowController] = []
    var statusBarItems: [StatusBarItem] = []
    
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
    
    @objc func checkStatus(){
        for instance in instances {
            AemActions.checkBundleState(instance)
        }
        
        table.reloadData()
        
        statusBarItems.forEach{
            item in item.updateStatus()
        }
    }
    
    @IBAction func checkVersionUpdate(_ sender: NSMenuItem){
        checkVersion()
        
    }
    
    @objc func checkVersion(){
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
                
                os_log("Tagname: %@",type:.info,self.tagName )
                
            }
            catch {
                os_log("Can not fetch Version: %@",type:.error,error.localizedDescription )
            }
        })
        task.resume()
        os_log("Version: %@ --- Tagname: %@",type:.info,version,self.tagName )
        
        
        if version.versionToInt().lexicographicallyPrecedes(tagName.versionToInt()) {
            performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "versionInfo"),sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTableData(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        
        NSApp.mainMenu?.item(withTitle: "Instances");
        
        let mm:NSMenuItem = NSMenuItem(title: "Piff", action: nil, keyEquivalent: "");
        
        NSApp.mainMenu?.insertItem(mm, at: 1)
        NSApp.mainMenu?.setSubmenu(InstanceMenu(target:self,instance:{self.selectedInstance}), for: mm)
   
        
        initStatusBarItems()
    }
    
    func initStatusBarItems(){
        
        statusBarItems.forEach {
            item in item.removeFromStatusBar()
        }
        
        for instance in instances{
            if instance.showIcon {
                statusBarItems.append(StatusBarItem(target: self, instance: instance))
            }
        }
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func editInstance(_ sender: NSMenuItem) {
        editInstance({selectedInstance})
    }
    
    func editInstance(_ instance: AEMInstanceSupplier) {
        
        if let instance = instance() {
            
            // open preferences dialog with instance
            if let winCrtl = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "aemInstanceGUI")) as? NSWindowController {
                if let aemInstanceGui = winCrtl.contentViewController as? AemInstanceController{
                    // add data
                    aemInstanceGui.aeminstance = instance
                    aemInstanceGui.instances = instances
                    os_log("Edit Instance with name : %@ and id: %@",type:.info,aemInstanceGui.aeminstance!.name, aemInstanceGui.aeminstance!.id)
                }
                winCrtl.showWindow(self)
                guiarray.append(winCrtl)
            }
        }
        else {
            notifyNoInstanceSelected()
        }
        
    }
    
    @IBAction func doubleClickInstance(_ sender: NSObject) {
        if table.selectedRow >= 0 {
            editInstance({selectedInstance})
        }
    }
    
    func openContextMenu() -> NSMenu? {
        if(selectedInstance != nil) {
            return InstanceMenu(target: self, instance: { self.selectedInstance! },
                                statusBarItem:false, isContextMenu:true)
        }
        return nil
    }
    
    func newInstance() {
        
        // open new preferences dialog
        if let winCrtl = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "aemInstanceGUI")) as? NSWindowController {
            
            if let aemInstanceGui = winCrtl.contentViewController as? AemInstanceController{
                // add data
                aemInstanceGui.aeminstance = AEMInstance()
                aemInstanceGui.instances = instances
                
                os_log("New Instance with id: %@",type:.info, aemInstanceGui.aeminstance!.id)
            }
            winCrtl.showWindow(self)
            guiarray.append(winCrtl)
        }
        
    }
    
    func deleteInstance(_ instance: AEMInstanceSupplier) {
        
        if let instance = instance() {
        
            if instances.contains(instance){
                instances.remove(at: instances.index(of: instance)!)
                
                AEMInstance.save(instances)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
            }
        }
        else {
            notifyNoInstanceSelected()
        }
        
    }
    
    func notifyNoInstanceSelected(){
        performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "noInstance"),sender: self)
    }
    
    func startInstance(_ instance: AEMInstanceSupplier) {
        
        if let instance = instance() {
            backgroundThread(background: {
                AemActions.startInstance(instance)
            },completion: {
                
            })
        } else {
            notifyNoInstanceSelected()
        }
 
    }
    
    
    func stopInstance(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            AemActions.stopInstance(instance)
        }
        else {
            notifyNoInstanceSelected()
        }
    }

    
    func openAuthor(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            if let url = URL(string: AEMInstance.getUrlWithContextPath(instance)){
                NSWorkspace.shared.open(url)
            }
        }
        else {
            notifyNoInstanceSelected()
        }
    }

    
    func openCRX(_ instance: AEMInstanceSupplier) {
        
        if let instance = instance() {
            openFuncCRX(instance)
        }
         else {
            notifyNoInstanceSelected()
        }
        
    }

    
    func openFuncCRX(_ instace: AEMInstance){
        var url = AEMInstance.getUrlWithContextPath(selectedInstance!)
        url.append("/crx/explorer/")
        if(selectedInstance?.type != AEMInstance.defaultType){
            url = AEMInstance.getUrl(instace)
            url.append("/crx/")
        }
        if let openUrl = URL(string:url){
            NSWorkspace.shared.open(openUrl)
        }
    }
    
    @IBAction func showHelp(_ sender: NSMenuItem) {
        
        let url = "https://docs.adobe.com/docs/en/aem/6-2/develop/ref.html"
        if let openUrl = URL(string:url){
            NSWorkspace.shared.open(openUrl)
        }
    }
    
    
    func openCRXDE(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            openCRXDEFunc(instance)
        }
        else {
            notifyNoInstanceSelected()
        }
    }
    
    func openInstanceFolder(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            openInstanceFolderFunc(instance)
        }
        else {
            notifyNoInstanceSelected()
        }
    }
    
    func openInstanceFolderFunc(_ instance: AEMInstance){
        NSWorkspace.shared.selectFile(instance.path, inFileViewerRootedAtPath: "")
        
    }
    
    
    func openCRXDEFunc(_ instance : AEMInstance) {
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.append("/crx/de/")
        if selectedInstance?.type != AEMInstance.defaultType {
            url = AEMInstance.getUrl(instance)
            url.append("/crxde")
        }
        
        // enable davex
        if selectedInstance?.type == AEMInstance.defaultType {
            AemActions.enableDavex(selectedInstance!)
        }
        
        if let openUrl = URL(string: url){
            NSWorkspace.shared.open(openUrl)
        }
    }
    
    
    func openFelixConsole(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            openFelixConsoleFunc(instance)
        }
        else {
            notifyNoInstanceSelected()
        }
    }
    
    func openFelixConsoleFunc(_ instance: AEMInstance){
        var url = AEMInstance.getUrlWithContextPath(instance)
        url.append("/system/console")
        if let openUrl = URL(string: url){
            NSWorkspace.shared.open(openUrl)
        }
    }
    
 
    
    func openErrorLog(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            openErrorLogFunc(instance)
        }
        else {
            notifyNoInstanceSelected()
        }
    }
    
    func openErrorLogFunc(_ instance: AEMInstance){
        openLogFile(instance, log: "error.log")
    }
    
    func openLogFile(_ instance:AEMInstance, log: String){
        var url = AEMInstance.getLogBaseFolder(instance)
        url.append(log)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url){
            NSWorkspace.shared.openFile(url)
        }
    }
    
    func openRequestLog(_ instance: AEMInstanceSupplier) {
        if let instance = instance() {
            openRequestLogFunc(instance)
        }
        else {
            notifyNoInstanceSelected()
        }
    }
    
    
    func openRequestLogFunc(_ instance: AEMInstance){
        openLogFile(instance, log: "request.log")
    }
    
    @objc func reloadTableData(_ notification: Notification){
        instances = AEMInstance.loadAEMInstances()
        table.reloadData()
        initStatusBarItems()
    }
    
    
//    func validateMenuItem(_ menuItem: InstanceMenuItem) -> Bool {
//        return selectedInstance != nil
//    }
  
}





extension ViewController: NSTableViewDataSource , NSTableViewDelegate {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return instances.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let coid = tableColumn?.identifier {
            switch coid.rawValue {
            case "name": return instances[row].name
            case "path": return instances[row].path
            case "type": return instances[row].type
            case "status":
                let status = instances[row].status
                return status.rawValue;
                
            case "url": return AEMInstance.getUrl(instances[row])
            default: break
            }
            
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if table.selectedRow >= 0 {
            os_log("Selected instance in table with name : %@ and id: %@",type:.info,instances[table.selectedRow].name, instances[table.selectedRow].id)
            // set seletected instance
            selectedInstance = instances[table.selectedRow]
        }
        else {
            selectedInstance = nil
        }
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

