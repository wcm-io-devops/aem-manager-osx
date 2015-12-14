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
    static let defaultHeapMaxMB = 1024
    static let defaultPermSizeMB = 256
    static let defaultJProfilerPort = 8849
    static let defaultJConsolePort = 9999
    static let defaultType = "AEM 5.5, 6.0 or higher"
    
    let id = NSUUID().UUIDString
    var name: String = ""
    var path: String = ""
    
    var type: String = defaultType
    // ?
    var status: BundleStatus = BundleStatus.NotActive
    
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
    
    static func save(instance: [AEMInstance]) -> Bool {
        if let path = getPath(){
            NSKeyedArchiver.archiveRootObject(instance, toFile: path)
            return true
        }
        return false
    }
    
    static func loadAEMInstances() -> [AEMInstance]{
        
        if let path = getPath(){
            if let instances = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [AEMInstance]{
                return instances
            }
        }
        return [AEMInstance]()
        
    }
    
    static func validate(instance : AEMInstance) -> Bool {
        if instance.name.isEmpty ||  instance.path.isEmpty || instance.hostName.isEmpty || instance.port <= 0 {
            return false;
        }
        
        return true
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let c = object as? AEMInstance {
            return c.id == self.id
        }
        return false
    }
    
    override var hash: Int {
        return id.hashValue
    }
    
    static func getUrl(instance: AEMInstance) -> String{
        return "http://\(instance.hostName):\(instance.port)"
    }
    
    static func getUrlWithContextPath(instance: AEMInstance) -> String{
        var url =  getUrl(instance)
        if !instance.contextPath.isEmpty{
            url.appendContentsOf(instance.contextPath)
        }
        
        return url
    }
    
    static func getLogBaseFolder(instance: AEMInstance) -> String{
        var path = NSString(string: instance.path).stringByDeletingLastPathComponent
        
        path.appendContentsOf("/crx-quickstart/logs/")
        
        return path
        
    }
    
    // MARK: NSCoding
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.name = decoder.decodeObjectForKey("id") as! String
        self.name = decoder.decodeObjectForKey("name") as! String
        self.type = decoder.decodeObjectForKey("type") as! String
        self.path = decoder.decodeObjectForKey("path") as! String
        
        self.hostName = decoder.decodeObjectForKey("hostName") as! String
        self.contextPath = decoder.decodeObjectForKey("contextPath") as! String
        self.javaExecutable = decoder.decodeObjectForKey("javaExecutable") as! String
        self.userName = decoder.decodeObjectForKey("userName") as! String
        self.password = decoder.decodeObjectForKey("password") as! String
        self.runMode = RunMode(rawValue: decoder.decodeObjectForKey("runMode") as! String)
        self.runModeSampleContent = decoder.decodeBoolForKey("runModeSampleContent")
        
        self.port = decoder.decodeIntegerForKey("port")
        self.heapMinSizeMB = decoder.decodeIntegerForKey("heapMinSizeMB")
        self.heapMaxSizeMB = decoder.decodeIntegerForKey("heapMaxSizeMB")
        self.maxPermSizeMB = decoder.decodeIntegerForKey("maxPermSizeMB")
        
        self.jVMDebug = decoder.decodeBoolForKey("jVMDebug")
        self.jConsole = decoder.decodeBoolForKey("jConsole")
        self.jProfiler = decoder.decodeBoolForKey("jProfiler")
        self.customJVMArgsActive = decoder.decodeBoolForKey("customJVMArgsActive")
        
        self.jVMDebugPort = decoder.decodeIntegerForKey("jVMDebugPort")
        self.jConsolePort = decoder.decodeIntegerForKey("jConsolePort")
        self.jProfilerPort = decoder.decodeIntegerForKey("ProfilerPort")
        self.customJVMArgs = decoder.decodeObjectForKey("customJVMArgs") as! String
        
        self.showIcon = decoder.decodeBoolForKey("showIcon")
        self.showProcess = decoder.decodeBoolForKey("showProcess")
        self.openBrowser = decoder.decodeBoolForKey("openBrowser")
        self.icon = decoder.decodeObjectForKey("icon") as! String
        
        
    }
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "id")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.type, forKey: "type")
        coder.encodeObject(self.path, forKey: "path")
        coder.encodeObject(self.hostName, forKey: "hostName")
        coder.encodeObject(self.contextPath, forKey: "contextPath")
        coder.encodeObject(self.javaExecutable, forKey: "javaExecutable")
        coder.encodeObject(self.userName, forKey: "userName")
        coder.encodeObject(self.password, forKey: "password")
        coder.encodeObject(self.runMode.rawValue, forKey: "runMode")
        coder.encodeBool(self.runModeSampleContent, forKey: "runModeSampleContent")
        
        coder.encodeInteger(self.port, forKey: "port")
        coder.encodeInteger(self.heapMinSizeMB, forKey: "heapMinSizeMB")
        coder.encodeInteger(self.heapMaxSizeMB, forKey: "heapMaxSizeMB")
        coder.encodeInteger(self.maxPermSizeMB, forKey: "maxPermSizeMB")
        
        coder.encodeBool(self.jVMDebug, forKey: "jVMDebug")
        coder.encodeBool(self.jConsole, forKey: "jConsole")
        coder.encodeBool(self.jProfiler, forKey: "jProfiler")
        coder.encodeBool(self.customJVMArgsActive, forKey: "customJVMArgsActive")
        
        coder.encodeInteger(self.jVMDebugPort, forKey: "jVMDebugPort")
        coder.encodeInteger(self.jConsolePort, forKey: "jConsolePort")
        coder.encodeInteger(self.jProfilerPort, forKey: "ProfilerPort")
        coder.encodeObject(self.customJVMArgs, forKey: "customJVMArgs")
        
        coder.encodeBool(self.showIcon, forKey: "showIcon")
        coder.encodeBool(self.showProcess, forKey: "showProcess")
        coder.encodeBool(self.openBrowser, forKey: "openBrowser")
        coder.encodeObject(self.icon, forKey: "icon")
        
    }
    
    private static func getPath() -> String? {
        let pfd = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let path = pfd.first {
            return path + "/.aeminstances.bin"
        }else {
            return nil
        }
    }
    
}
