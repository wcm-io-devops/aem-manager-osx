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
            // Set admin password
            jarArgs.append("-Dadmin.password=\(instance.password)")
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
        print("Args:\(args)")
        
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
    
    static func enableDavex(_ instance:AEMInstance) -> Bool {
        
        
        if (isDavexDisabled(instance)){
            
            let PasswordString = "\(instance.userName):\(instance.password)"
            let PasswordData = PasswordString.data(using: String.Encoding.utf8)
            let base64EncodedCredential = PasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            
            let davexServletUrl = AEMInstance.getUrlWithContextPath(instance) + "/apps/system/config/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet";
            
            
            let test = AEMInstance.getUrlWithContextPath(instance)  + "system/console/configMgr/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet"
            print(davexServletUrl)
            let url = NSURL(string: davexServletUrl)
            let request = NSMutableURLRequest(url: url! as URL)
            
            request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
            
            print("Enabling Davex Servlet now!")
            request.setValue("jcr:primaryType",forHTTPHeaderField: "sling:OsgiConfig")
            request.setValue("alias",forHTTPHeaderField: "/crx/server")
            request.setValue("dav.create-absolute-uri",forHTTPHeaderField: "true")
            request.setValue("dav.create-absolute-uri@TypeHint",forHTTPHeaderField: "Boolean")
            
            
            let params = ["jcr:primaryType": "sling:OsgiConfig","alias":  "/crx/server", "dav.create-absolute-uri": "true","dav.create-absolute-uri@TypeHint":  "Boolean"]
            let httpData = NSKeyedArchiver.archivedData(withRootObject: params)
            request.httpBody = httpData
            //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let session = URLSession.shared
            session.dataTask(with: request as URLRequest, completionHandler: { (returnData, response, error) -> Void in
                let strData = NSString(data: returnData!, encoding: String.Encoding.utf8.rawValue)
                print("Execured!!\(strData)")
            }).resume() //Remember this one or nothing will happen :-)
        }
        
        return true
    }
    
    static func enableDavexWithCurl(instance: AEMInstance)->Void{
        var args = [String]()
        let task = Process()
        
        args.append("curl -u admin:admin" )
        args.append(AEMInstance.getUrlWithContextPath(instance))
        args.append("/apps/system/config/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet")
        args.append("-F 'jcr:primaryType=sling:OsgiConfig'")
        args.append("-F 'alias=/crx/server'")
        args.append("-F 'dav.create-absolute-uri=true'")
        args.append("-F 'dav.create-absolute-uri@TypeHint=Boolean'")
        
        let pipe = Pipe()
        task.launchPath = "/usr/bin/curl"
        task.arguments = args
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print(output!)
    }
    
    static func isDavexDisabled(_ instance: AEMInstance)-> Bool{
        let PasswordString = "\(instance.userName):\(instance.password)"
        let PasswordData = PasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = PasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        let davExUrl = AEMInstance.getUrlWithContextPath(instance) + "/crx/server/crx.default/jcr:root/.1.json";
        var request = URLRequest(url: URL(string: davExUrl)!)
        request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        do{
            let (data, response) = try URLSession.shared.synchronousDataTask(with: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    print("404:Davex Servlet still disabled: \(response)")
                    return true
                }else{
                    print("200:Davex Servlet enabled: \(response)")
                }
            }
        } catch _ {
            print("Can not enable Davex servlet!")
        }
        return false
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

extension URLSession {
    
    func synchronousDataTask(with request: URLRequest) throws -> (data: Data?, response: HTTPURLResponse?) {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var responseData: Data?
        var theResponse: URLResponse?
        var theError: Error?
        
        dataTask(with: request) { (data, response, error) -> Void in
            
            responseData = data
            theResponse = response
            theError = error
            
            semaphore.signal()
            
            }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = theError {
            throw error
        }
        
        return (data: responseData, response: theResponse as! HTTPURLResponse?)
        
    }
    
}
