//
//  AemActions.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 02.12.15.
//  Copyright © 2015 Peter Mannel-Wiedemann. All rights reserved.
//

import Foundation

class AemActions: NSObject {
    
    
    static func buildCommandLineArguments(instance: AEMInstance) -> [String] {
        var javaArgs = [String]()
        var jarArgs = [String]()
        var args = [String]()
        
        // menory settings
        javaArgs.append("-Xms\(instance.heapMinSizeMB)M")
        javaArgs.append("-Xmx\(instance.heapMaxSizeMB)M")
       // javaArgs.append("-XX:MaxPermSize=\(instance.maxPermSizeMB)M")
        
        if instance.type == AEMInstance.defaultType{
            jarArgs.append("-p\(instance.port)")
        }else{
            javaArgs.append("-D-crx.quickstart.server.port=\(instance.port)")
        }
        let runModes = instance.runMode.rawValue.lowercaseString + "," + ((instance.runModeSampleContent) ? "samplecontent" : "nosamplecontent")
        // rummodes
        if instance.type == AEMInstance.defaultType{
            jarArgs.append("-r\(runModes)")
        }else{
            javaArgs.append("-Dsling.run.modes=\(runModes)")
        }
        
        // Debug
        if instance.jVMDebug && instance.jVMDebugPort > 0 {
           // javaArgs.append("-Xdebug")
            //javaArgs.append("-Xnoagent")
            //javaArgs.append("-Djava.compiler=NONE")
            //javaArgs.append("-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=\(instance.jVMDebugPort)")
            javaArgs.append("-agentlib:jdwp=transport=dt_socket,address=\(instance.jVMDebugPort),server=y,suspend=n")
        }
        
        if instance.jProfiler && instance.jProfilerPort > 0 {
            // javaArgs.append("-agentlib:jprofilerti=port=\(instance.jProfilerPort)")
        }
        
        if instance.jConsole && instance.jConsolePort > 0 {
            javaArgs.append("-Dcom.sun.management.jmxremote.port=\(instance.jConsolePort)")
            javaArgs.append("-Dcom.sun.management.jmxremote.ssl=false")
            javaArgs.append("-Dcom.sun.management.jmxremote.authenticate=false")
        }
        if instance.customJVMArgsActive && !instance.customJVMArgs.isEmpty{
            javaArgs.append(instance.customJVMArgs)
        }
        javaArgs.append("-DhideConfigWizard=true")
        
        // TODO: add startmode (jar args)
        if instance.type == AEMInstance.defaultType {
            jarArgs.append("-nofork")
        }
        jarArgs.append("-v")
        
        
        javaArgs.append("-jar")
        javaArgs.append("\(instance.path)")
        
        args = javaArgs + jarArgs
        print("Args:\(args)")
        
        return args
    }
    
    static func startInstance(instance: AEMInstance) -> String{
        
        if instance.status == BundleStatus.Running || instance.status == BundleStatus.Starting_Stopping || instance.status == BundleStatus.Unknown {
            return ""
        }
        
        let task = NSTask()
        task.launchPath = instance.javaExecutable
        task.arguments = buildCommandLineArguments(instance)
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: NSUTF8StringEncoding)!
        if output.characters.count > 0 {
            return output.substringToIndex(output.endIndex.advancedBy(-1))
            
        }
        print(output)
        instance.status = BundleStatus.Running
        return output
        
    }
    
    
    static func stopInstance(instance: AEMInstance) {
        
        let PasswordString = "\(instance.userName):\(instance.password)"
        let PasswordData = PasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = PasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        var stopUrl = AEMInstance.getUrlWithContextPath(instance)
        stopUrl.appendContentsOf("/system/console/vmstat?shutdown_type=Stop")
        if instance.type != AEMInstance.defaultType {
            stopUrl = AEMInstance.getUrl(instance)
            stopUrl.appendContentsOf("/admin/shutdown")
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: stopUrl)!)
        let session = NSURLSession.sharedSession()
        request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // handle error
            guard error == nil else { return }
            
            print("Response: \(response)")
            
        })
        
        task.resume()
        
        
    }
    
}