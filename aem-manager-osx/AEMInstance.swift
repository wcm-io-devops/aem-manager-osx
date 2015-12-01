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
    
    
    var name: String = ""
    var path: String = ""
    // ?
    var url: String = ""
    var type: String = defaultType
    // ?
    var status: String = ""
    var hostName = "localhost"
    var port: Int = defaultPort
    var contextPath = "/"
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
    
    static func save(instance: AEMInstance) -> Bool {
        if let path = getPath(){
            NSKeyedArchiver.archiveRootObject(instance, toFile: path)
            return true
        }
        return false
    }
    
    static func loadAEMInstances() -> [AEMInstance]{
        var inst = [AEMInstance]()
        if let path = getPath(){
            if let instances = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [AEMInstance]{
                inst.appendContentsOf(instances)
            }
        }
        
        /*
        var instances = [AEMInstance]()
        for var i = 1; i<=3; i++ {
        let instance = AEMInstance()
        instance.name = "Test\(i)"
        instance.path = "/test/test\(i)"
        instance.url = "localhost"
        instance.type = "CQ6"
        instance.status = "Running"
        instances.append(instance)
        }
        
        
        return instances
        */
        return inst
        
    }
    
    static func validate(instance : AEMInstance) -> Bool {
        if instance.name.isEmpty ||  instance.path.isEmpty || instance.hostName.isEmpty || instance.port <= 0 {
            return false;
        }
        
        return true
    }
    
    // MARK: NSCoding
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.name = decoder.decodeObjectForKey("name") as! String
        self.type = decoder.decodeObjectForKey("type") as! String
        self.path = decoder.decodeObjectForKey("path") as! String
        self.url = decoder.decodeObjectForKey("url") as! String
        self.status = decoder.decodeObjectForKey("status") as! String
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
        
        self.jVMDebugPort = decoder.decodeIntegerForKey("jVMDebugPort ")
        self.jConsolePort = decoder.decodeIntegerForKey("jConsolePort")
        self.jProfilerPort = decoder.decodeIntegerForKey("ProfilerPort")
        self.customJVMArgs = decoder.decodeObjectForKey("customJVMArgs") as! String
        
        
    }
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.type, forKey: "type")
        coder.encodeObject(self.path, forKey: "path")
        coder.encodeObject(self.url, forKey: "url")
        coder.encodeObject(self.status, forKey: "status")
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
        coder.encodeInteger(self.maxPermSizeMB, forKey: "maxePermSizeMB")
        
        coder.encodeBool(self.jVMDebug, forKey: "jVMDebug")
        coder.encodeBool(self.jConsole, forKey: "jConsole")
        coder.encodeBool(self.jProfiler, forKey: "jProfiler")
        coder.encodeBool(self.customJVMArgsActive, forKey: "customJVMArgsActive")
        
        coder.encodeInteger(self.jVMDebugPort, forKey: "jVMDebugPort")
        coder.encodeInteger(self.jConsolePort, forKey: "jConsolePort")
        coder.encodeInteger(self.jProfilerPort, forKey: "ProfilerPort")
        coder.encodeObject(self.customJVMArgs, forKey: "customJVMArgs")
        
    }
    
    private static func getPath() -> String? {
        let pfd = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let path = pfd.first {
            return path + "/aeminstances.bin"
        }else {
            return nil
        }
    }
    
}
