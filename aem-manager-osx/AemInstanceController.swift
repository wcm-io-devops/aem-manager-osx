//
//  AemInstanceController.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 28.11.15.
//
//

import Cocoa

class AemInstanceController: NSViewController {
    
    var instances = [AEMInstance]()
    
    // MARK: properties
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var hostnameField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var contextPathFiled: NSTextField!
    @IBOutlet weak var typeComboBox: NSComboBox!
    @IBOutlet weak var sampleContentCheckBox: NSButton!
    @IBOutlet weak var jarFileField: NSTextField!
    @IBOutlet weak var javaExecField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var heapMinField: NSTextField!
    @IBOutlet weak var heapMaxField: NSTextField!
    @IBOutlet weak var pemGemField: NSTextField!
    @IBOutlet weak var jvmDebugCheckBox: NSButton!
    @IBOutlet weak var jProfilerCheckBox: NSButton!
    @IBOutlet weak var jConsoleCheckBox: NSButton!
    @IBOutlet weak var jvmDebugField: NSTextField!
    @IBOutlet weak var jProfilerField: NSTextField!
    @IBOutlet weak var jConsoleField: NSTextField!
    @IBOutlet weak var customJvmCheckBox: NSButton!
    @IBOutlet weak var customJvmField: NSTextField!
    @IBOutlet weak var authorRadioButton: NSButton!
    @IBOutlet weak var publishRadioButton: NSButton!
    @IBOutlet weak var iconCheckBox: NSButton!
    @IBOutlet weak var processWindowCheckBox: NSButton!
    @IBOutlet weak var openBrowserCheckBox: NSButton!
    @IBOutlet weak var iconSetComboBox: NSComboBox!
    
    
    @IBOutlet weak var runModeRadio: NSButton!
    
    var aeminstance: AEMInstance? {
        
        didSet {
            nameField?.stringValue = aeminstance!.name
            hostnameField?.stringValue = aeminstance!.hostName
            contextPathFiled?.stringValue = aeminstance!.contextPath
            portField?.stringValue = String(aeminstance!.port)
            typeComboBox?.stringValue = aeminstance!.contextPath
            jarFileField!.stringValue = aeminstance!.path
            javaExecField!.stringValue = aeminstance!.javaExecutable
            usernameField!.stringValue = aeminstance!.userName
            passwordField!.stringValue = aeminstance!.password
            heapMinField!.stringValue = String(aeminstance!.heapMinSizeMB)
            heapMaxField!.stringValue = String(aeminstance!.heapMaxSizeMB)
            pemGemField!.stringValue = String(aeminstance!.maxPermSizeMB)
            jvmDebugField!.stringValue = String(aeminstance!.jVMDebugPort)
            jProfilerField!.stringValue = String(aeminstance!.jProfilerPort)
            jConsoleField!.stringValue = String(aeminstance!.jConsolePort)
            customJvmField!.stringValue = aeminstance!.customJVMArgs
            
            let runMode =  aeminstance!.runMode
            if runMode == RunMode.Author{
                authorRadioButton?.state = NSOnState
                publishRadioButton?.state = NSOffState
            }else{
                publishRadioButton?.state = NSOffState
                authorRadioButton?.state = NSOnState
            }
            jProfilerCheckBox.state = aeminstance?.jProfiler == true ? NSOnState : NSOffState
            jConsoleCheckBox.state = aeminstance?.jConsole == true ? NSOnState : NSOffState
            customJvmCheckBox.state = aeminstance?.customJVMArgsActive == true ? NSOnState : NSOffState
            jvmDebugCheckBox.state = aeminstance?.jVMDebug == true ? NSOnState : NSOffState
            
            iconCheckBox.state = aeminstance?.showIcon == true ? NSOnState : NSOffState
            processWindowCheckBox.state = aeminstance?.showProcess == true ? NSOnState : NSOffState
            openBrowserCheckBox.state = aeminstance?.openBrowser == true ? NSOnState : NSOffState
            iconSetComboBox?.stringValue = aeminstance!.icon
            
        }
        
        
    }
    
    
    // MARK: actions
    @IBAction func openJarFileDialog(_ sender: NSButton) {
        let openFile = NSOpenPanel()
        openFile.title = "Open File"
        openFile.prompt = "Open"
        openFile.worksWhenModal = true
        openFile.allowsMultipleSelection = false
        openFile.canChooseDirectories = false
        openFile.canChooseFiles = true
        openFile.canCreateDirectories = true
        openFile.resolvesAliases = true
        openFile.runModal()
        if let url = openFile.url{
            jarFileField.stringValue = url.path
        }
    }
    
    @IBAction func openJavaExecDialog(_ sender: NSButton) {
        let openFile = NSOpenPanel()
        openFile.title = "Open File"
        openFile.prompt = "Open"
        openFile.worksWhenModal = true
        openFile.allowsMultipleSelection = false
        openFile.canChooseDirectories = false
        openFile.canChooseFiles = true
        openFile.canCreateDirectories = true
        openFile.resolvesAliases = true
        openFile.runModal()
        if let url = openFile.url {
            javaExecField.stringValue = url.path
        }
        
    }
    
    @IBAction func cancel(_ sender: NSButton) {
        view.window?.close()
    }
    
    @IBAction func save(_ sender: AnyObject) {
        aeminstance!.name = nameField.stringValue
        aeminstance!.hostName = hostnameField.stringValue
        aeminstance!.contextPath = contextPathFiled.stringValue
        aeminstance!.port = portField.integerValue
        aeminstance!.type = typeComboBox!.stringValue
        aeminstance!.path = jarFileField!.stringValue
        aeminstance!.javaExecutable = javaExecField!.stringValue
        aeminstance!.userName = usernameField!.stringValue
        aeminstance!.password =  passwordField!.stringValue
        aeminstance!.heapMinSizeMB = Int(heapMinField!.stringValue)!
        aeminstance!.heapMaxSizeMB = heapMaxField!.integerValue
        aeminstance!.maxPermSizeMB = pemGemField!.integerValue
        aeminstance!.jVMDebugPort = jvmDebugField!.integerValue
        aeminstance!.jProfilerPort = jProfilerField!.integerValue
        aeminstance!.jConsolePort = jConsoleField!.integerValue
        aeminstance!.customJVMArgs = customJvmField!.stringValue
        aeminstance!.runMode = authorRadioButton?.state == NSOnState ? RunMode.Author : RunMode.Publish
        
        aeminstance!.jProfiler = jProfilerCheckBox.state == NSOnState ? true : false
        aeminstance!.jConsole = jConsoleCheckBox.state == NSOnState ? true : false
        aeminstance!.customJVMArgsActive = customJvmCheckBox.state == NSOnState ? true : false
        aeminstance!.jVMDebug = jvmDebugCheckBox.state == NSOnState ? true : false
        
        aeminstance!.showProcess = processWindowCheckBox.state == NSOnState ? true : false
        aeminstance!.showIcon = iconCheckBox.state == NSOnState ? true : false
        aeminstance!.openBrowser = openBrowserCheckBox.state == NSOnState ? true : false
        aeminstance!.icon = iconSetComboBox!.stringValue
        
        if AEMInstance.validate(aeminstance!){
            
            if instances.contains(aeminstance!){
                instances.remove(at: instances.index(of: aeminstance!)!)
            }
            
            instances.append(aeminstance!)
            
            print("Saving Instance to db with name:\(aeminstance!.name) and id: \(aeminstance?.id)")
            AEMInstance.save(instances)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
            
            view.window?.close()
            
        }
        else{
            // show message
            performSegue(withIdentifier: "error",sender: self)
            
        }
    }
    
    @IBAction func showIcon(_ sender: NSButton) {
        if sender.state == NSOnState {
            aeminstance!.showIcon = true
        }else {
            aeminstance!.showIcon = false
        }
    }
    
    @IBAction func showProcessOnStartup(_ sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.showProcess = true
        }else{
            aeminstance!.showProcess = false
        }
    }
    
    @IBAction func openBrowser(_ sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.openBrowser = true
        }else{
            aeminstance!.openBrowser = false
        }
    }
    
    @IBAction func changeRunMode(_ sender: NSButton) {
        if sender === authorRadioButton{
            aeminstance!.runMode = RunMode.Author
        }else
        {
            aeminstance!.runMode = RunMode.Publish
        }
    }
    
    @IBAction func enableJVMDebugging(_ sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.jVMDebug = true
        }else{
            aeminstance!.jVMDebug = false
        }
    }
    
    @IBAction func enableJProfilerSupport(_ sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.jProfiler = true
        }else{
            aeminstance!.jProfiler = false
        }
    }
    
    @IBAction func enableJConsoleSupport(_ sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.jConsole = true
        }else{
            aeminstance!.jConsole = false
        }
    }
    @IBAction func enableCustomJVMSettings(_ sender: NSButton) {
        
        if sender.state == NSOnState{
            aeminstance!.customJVMArgsActive = true
        }else{
            aeminstance!.customJVMArgsActive = false
        }
    }
    @IBAction func enableSampleContent(_ sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.runModeSampleContent = true
        }else{
            aeminstance!.runModeSampleContent = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        typeComboBox.selectItem(at: 0)
    }
    
}
