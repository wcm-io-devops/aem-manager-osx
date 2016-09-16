//
//  AppDelegate.swift
//  aem-manager-osx
//
//  Created by Peter Mannel-Wiedemann on 27.11.15.
//  
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    weak var mainVC:ViewController?
       var items: [NSStatusItem] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    @IBAction func newInstance(_ sender: NSMenuItem) {
        print("create new Instance")
    }
    

}

