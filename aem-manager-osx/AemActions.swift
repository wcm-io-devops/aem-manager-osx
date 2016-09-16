//
//  AemActions.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 02.12.15.
//  Copyright © 2015 Peter Mannel-Wiedemann. All rights reserved.
//

import Foundation

class AemActions: NSObject {
    
    
    static func buildCommandLineArguments(_ instance: AEMInstance) -> [String] {
        var javaArgs = [String]()
        var jarArgs = [String]()
        var args = [String]()
        
        // menory settings
        javaArgs.append("-Xms\(instance.heapMinSizeMB)M")
        javaArgs.append("-Xmx\(instance.heapMaxSizeMB)M")
        javaArgs.append("-XX:MaxPermSize=\(instance.maxPermSizeMB)M")
        
        if instance.type == AEMInstance.defaultType{
            jarArgs.append("-p\(instance.port)")
        }else{
            javaArgs.append("-D-crx.quickstart.server.port=\(instance.port)")
        }
        let runModes = instance.runMode.rawValue.lowercased() + "," + ((instance.runModeSampleContent) ? "samplecontent" : "nosamplecontent")
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
        if !instance.contextPath.isEmpty && instance.contextPath != "/" {
            jarArgs.append("-contextpath \(instance.contextPath)")
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
        
        if instance.showProcess {
            jarArgs.append("-v")
        }
        
        if !instance.openBrowser{
            jarArgs.append("-nobrowser")
        }
        
        javaArgs.append("-jar")
        javaArgs.append("\(instance.path)")
        
        args = javaArgs + jarArgs
        //print("Args:\(args)")
        
        return args
    }
    
    static func startInstance(_ instance: AEMInstance) -> String {
        
        if instance.status == BundleStatus.running || instance.status == BundleStatus.starting_Stopping || instance.status == BundleStatus.unknown {
            return "Instance already started!"
        }
        
        let task = Process()
        task.launchPath = instance.javaExecutable
        task.arguments = buildCommandLineArguments(instance)
        print("Arguments:\(task.arguments!)")
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        instance.status = BundleStatus.starting_Stopping
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.characters.count > 0 {
            return output.substring(to: output.characters.index(output.endIndex, offsetBy: -1))
            
        }
        print(output)
        
        
        return output
        
    }
    
    
    static func stopInstance(_ instance: AEMInstance) {
        
        let PasswordString = "\(instance.userName):\(instance.password)"
        let PasswordData = PasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = PasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        var stopUrl = AEMInstance.getUrlWithContextPath(instance)
        stopUrl.append("/system/console/vmstat?shutdown_type=Stop")
        if instance.type != AEMInstance.defaultType {
            stopUrl = AEMInstance.getUrl(instance)
            stopUrl.append("/admin/shutdown")
        }
        
        var request = URLRequest(url: URL(string: stopUrl)!)
        let session = URLSession.shared
        request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            // handle error
            guard error == nil else { return }
            
            print("Response: \(response)")
            
        })
        instance.status = BundleStatus.notActive
        task.resume()
        
        
    }
    
    static func checkBundleState(_ instance: AEMInstance) {
        
        let PasswordString = "\(instance.userName):\(instance.password)"
        let PasswordData = PasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = PasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        var felixUrl = AEMInstance.getUrlWithContextPath(instance)
        felixUrl.append("/system/console/bundles/.json")
        
        var request = URLRequest(url: URL(string: felixUrl)!)
        //request.timeoutInterval = (number as! NSTimeInterval)
        let session = URLSession.shared
        request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            // handle error
            if (error != nil){
                instance.status = BundleStatus.notActive
                print(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("response was not 200: \(response)")
                    instance.status = BundleStatus.notActive
                    return
                }
                else
                {
                    do {
                        let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        let status = jsonResult["status"] as! String
                        print("Status: \(status)")
                        if status.contains("resolved")  || status.contains("installed"){
                            instance.status = BundleStatus.starting_Stopping
                        }else{
                            instance.status = BundleStatus.running
                        }
                        
                    } catch let error as NSError {
                        instance.status = BundleStatus.notActive
                        print(error)
                    }
                }
            }
            
        })
        task.resume()
        
        
        
    }
    
}
