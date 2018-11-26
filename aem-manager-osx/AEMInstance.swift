//
//  AEMInstance.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 28.11.15.
//
//

import Cocoa

class AEMInstance: NSObject, NSCoding {
    
    
    static let defaultPort = 4502
    static let defaultHeapMinMB = 128
    static let defaultHeapMaxMB = 2056
    static let defaultPermSizeMB = 256
    static let defaultJProfilerPort = 8849
    static let defaultJConsolePort = 9999
    static let defaultType = "AEM 5.5, 6.0 or higher"
    
    var id = UUID().uuidString
    var name: String = ""
    var path: String = ""
    
    var type: String = defaultType

    var status: BundleStatus = BundleStatus.notActive
    
    var hostName = "localhost"
    var port =  defaultPort
    var contextPath = ""
    var javaExecutable = "/usr/bin/java"
    var userName = "admin"
    var password = "admin"
    var runMode : RunMode! = RunMode.Author
    var runModeSampleContent = false
    var heapMinSizeMB = defaultHeapMinMB
    var heapMaxSizeMB = defaultHeapMaxMB
    var maxPermSizeMB = defaultPermSizeMB
    var jVMDebug = false
    var jVMDebugPort = 0
    var jProfiler = false
    var jProfilerPort = defaultJProfilerPort
    var jConsole = false
    var jConsolePort = 0
    var customJVMArgsActive = false
    var customJVMArgs = ""
    var showIcon = true
    var icon = "Number 1"
    var showProcess = false
    var openBrowser = false
    
    static func save(_ instance: [AEMInstance]) -> Bool {
        if let path = getPath(){
            NSKeyedArchiver.archiveRootObject(instance, toFile: path)
            return true
        }
        return false
    }
    
    static func loadAEMInstances() -> [AEMInstance]{
        
        if let path = getPath(){
            if let instances = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [AEMInstance]{
                return instances
            }
        }
        return [AEMInstance]()
        
    }
    
    static func validate(_ instance : AEMInstance) -> Bool {
        if instance.name.isEmpty ||  instance.path.isEmpty || instance.hostName.isEmpty || instance.port <= 0 {
            return false;
        }
        
        return true
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let c = object as? AEMInstance {
            return c.id == self.id
        }
        return false
    }
    
    override var hash: Int {
        return id.hashValue
    }
    
    static func getUrl(_ instance: AEMInstance) -> String{
        return "http://\(instance.hostName):\(instance.port)"
    }
    
    static func getUrlWithContextPath(_ instance: AEMInstance) -> String{
        var url =  getUrl(instance)
        if !instance.contextPath.isEmpty{
            url.append(instance.contextPath)
        }
        
        return url
    }
    
    static func getLogBaseFolder(_ instance: AEMInstance) -> String{
        var path = NSString(string: instance.path).deletingLastPathComponent
        
        path.append("/crx-quickstart/logs/")
        
        return path
        
    }
    
    // MARK: NSCoding
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.id = decoder.decodeObject(forKey: "id") as! String
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.type = decoder.decodeObject(forKey: "type") as! String
        self.path = decoder.decodeObject(forKey: "path") as! String
        
        self.hostName = decoder.decodeObject(forKey: "hostName") as! String
        self.contextPath = decoder.decodeObject(forKey: "contextPath") as! String
        self.javaExecutable = decoder.decodeObject(forKey: "javaExecutable") as! String
        self.userName = decoder.decodeObject(forKey: "userName") as! String
        self.password = decoder.decodeObject(forKey: "password") as! String
        self.runMode = RunMode(rawValue: decoder.decodeObject(forKey: "runMode") as! String)
        self.runModeSampleContent = decoder.decodeBool(forKey: "runModeSampleContent")
        
        self.port = decoder.decodeInteger(forKey: "port")
        self.heapMinSizeMB = decoder.decodeInteger(forKey: "heapMinSizeMB")
        self.heapMaxSizeMB = decoder.decodeInteger(forKey: "heapMaxSizeMB")
        self.maxPermSizeMB = decoder.decodeInteger(forKey: "maxPermSizeMB")
        
        self.jVMDebug = decoder.decodeBool(forKey: "jVMDebug")
        self.jConsole = decoder.decodeBool(forKey: "jConsole")
        self.jProfiler = decoder.decodeBool(forKey: "jProfiler")
        self.customJVMArgsActive = decoder.decodeBool(forKey: "customJVMArgsActive")
        
        self.jVMDebugPort = decoder.decodeInteger(forKey: "jVMDebugPort")
        self.jConsolePort = decoder.decodeInteger(forKey: "jConsolePort")
        self.jProfilerPort = decoder.decodeInteger(forKey: "ProfilerPort")
        self.customJVMArgs = decoder.decodeObject(forKey: "customJVMArgs") as! String
        
        self.showIcon = decoder.decodeBool(forKey: "showIcon")
        self.showProcess = decoder.decodeBool(forKey: "showProcess")
        self.openBrowser = decoder.decodeBool(forKey: "openBrowser")
        self.icon = decoder.decodeObject(forKey: "icon") as! String
        
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.name, forKey: "name")
        coder.encode(self.type, forKey: "type")
        coder.encode(self.path, forKey: "path")
        coder.encode(self.hostName, forKey: "hostName")
        coder.encode(self.contextPath, forKey: "contextPath")
        coder.encode(self.javaExecutable, forKey: "javaExecutable")
        coder.encode(self.userName, forKey: "userName")
        coder.encode(self.password, forKey: "password")
        coder.encode(self.runMode.rawValue, forKey: "runMode")
        coder.encode(self.runModeSampleContent, forKey: "runModeSampleContent")
        
        coder.encode(self.port, forKey: "port")
        coder.encode(self.heapMinSizeMB, forKey: "heapMinSizeMB")
        coder.encode(self.heapMaxSizeMB, forKey: "heapMaxSizeMB")
        coder.encode(self.maxPermSizeMB, forKey: "maxPermSizeMB")
        
        coder.encode(self.jVMDebug, forKey: "jVMDebug")
        coder.encode(self.jConsole, forKey: "jConsole")
        coder.encode(self.jProfiler, forKey: "jProfiler")
        coder.encode(self.customJVMArgsActive, forKey: "customJVMArgsActive")
        
        coder.encode(self.jVMDebugPort, forKey: "jVMDebugPort")
        coder.encode(self.jConsolePort, forKey: "jConsolePort")
        coder.encode(self.jProfilerPort, forKey: "ProfilerPort")
        coder.encode(self.customJVMArgs, forKey: "customJVMArgs")
        
        coder.encode(self.showIcon, forKey: "showIcon")
        coder.encode(self.showProcess, forKey: "showProcess")
        coder.encode(self.openBrowser, forKey: "openBrowser")
        coder.encode(self.icon, forKey: "icon")
        
    }
    
    fileprivate static func getPath() -> String? {
        let pfd = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let path = pfd.first {
            return path + "/.aeminstances.bin"
        }else {
            return nil
        }
    }
    
}
