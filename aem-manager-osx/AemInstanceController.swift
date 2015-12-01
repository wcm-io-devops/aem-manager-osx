//
//  AemInstanceController.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 28.11.15.
//
//

import Cocoa

class AemInstanceController: NSViewController {
    
    
    
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
    
    
    @IBOutlet weak var runModeRadio: NSButton!
    
    var aeminstance: AEMInstance? {
        
        didSet {
            nameField?.stringValue = aeminstance!.name
            hostnameField?.stringValue = aeminstance!.hostName
            contextPathFiled?.stringValue = aeminstance!.contextPath
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
            
        }
        
        
    }
    
    
    // MARK: actions
    @IBAction func openJarFileDialog(sender: NSButton) {
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
        if let url = openFile.URL, fname = url.path {
            jarFileField.stringValue = fname
        }
    }
    
    @IBAction func openJavaExecDialog(sender: NSButton) {
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
        if let url = openFile.URL, fname = url.path {
            javaExecField.stringValue = fname
        }
        
    }
    
    @IBAction func cancel(sender: NSButton) {
        view.window?.close()
    }
    
    @IBAction func save(sender: AnyObject) {
        print(aeminstance!)
        
        aeminstance!.name = nameField.stringValue
        aeminstance!.hostName = hostnameField.stringValue
        aeminstance!.contextPath = contextPathFiled.stringValue
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
        aeminstance!.runMode = authorRadioButton?.state == NSOnState ? RunMode.Author : RunMode.Publish
        
        aeminstance!.jProfiler = jProfilerCheckBox.state == NSOnState ? true : false
        aeminstance!.jConsole = jConsoleCheckBox.state == NSOnState ? true : false
        aeminstance!.customJVMArgsActive = customJvmCheckBox.state == NSOnState ? true : false
        aeminstance!.jVMDebug = jvmDebugCheckBox.state == NSOnState ? true : false
        
        if AEMInstance.validate(aeminstance!){
            print(aeminstance!.name)
            AEMInstance.save(aeminstance!)
            
            if let winCrtl = storyboard!.instantiateControllerWithIdentifier("mainView") as? NSWindowController {
                if let aemInstanceGui = winCrtl.contentViewController as? ViewController{
                    aemInstanceGui.table.reloadData()
                }
                
            }
            view.window?.close()
            
        }
        else{
            // show message
            performSegueWithIdentifier("error",sender: self)
            
        }
    }
    
    
    @IBAction func changeRunMode(sender: NSButton) {
        if sender === authorRadioButton{
            aeminstance?.runMode = RunMode.Author
        }else
        {
            aeminstance?.runMode = RunMode.Publish
        }
    }
    
    @IBAction func enableJVMDebugging(sender: NSButton) {
        
        if sender.state == NSOnState{
            aeminstance!.jVMDebug = true
        }else{
            aeminstance!.jVMDebug = false
        }
    }
    
    @IBAction func enableJProfilerSupport(sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.jProfiler = true
        }else{
            aeminstance!.jProfiler = false
        }
    }
    
    @IBAction func enableJConsoleSupport(sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.jConsole = true
        }else{
            aeminstance!.jConsole = false
        }
    }
    @IBAction func enableCustomJVMSettings(sender: NSButton) {
        
        if sender.state == NSOnState{
            aeminstance!.customJVMArgsActive = true
        }else{
            aeminstance!.customJVMArgsActive = false
        }
    }
    @IBAction func enableSampleContent(sender: NSButton) {
        if sender.state == NSOnState{
            aeminstance!.runModeSampleContent = true
        }else{
            aeminstance!.runModeSampleContent = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
