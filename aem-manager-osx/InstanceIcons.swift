//
//  InstanceIcon.swift
//  aem-manager-osx
//
//  Created by mceruti on 27.11.18.
//  Copyright © 2018 Matteo Ceruti. All rights reserved.
//

import Foundation
import Cocoa
import CoreImage

class InstanceIcons {
 
    static func getIcon(instance:AEMInstance!) -> NSImage! {
        let num  = String(instance.icon.last!)
        let background = backgroundImage(instance: instance)
        let icon = makeIcon(background: background, overlay: num)
        return icon
    }
    
    
    internal static func makeIcon(background:String, overlay:String) -> NSImage! {
        let bg = NSImage(named: NSImage.Name(rawValue: background))
        let num = NSImage(named: NSImage.Name(rawValue: overlay))
        
        let filter = CIFilter(name: "CISourceOverCompositing")!
        filter.setDefaults()
        filter.setValue(CIImage(data:num!.tiffRepresentation!), forKey: "inputImage")
        filter.setValue(CIImage(data:bg!.tiffRepresentation!), forKey: "inputBackgroundImage")
        
        let resultImage = filter.outputImage
        
        let rep = NSCIImageRep(ciImage: resultImage!)
        let finalResult = NSImage(size: rep.size)
        finalResult.addRepresentation(rep)
        
        return finalResult
        
    }
    
    internal static func backgroundImage(instance:AEMInstance!) -> String {
        switch instance.status {
            case .running: return "running"
            case .disabled: return "disabled"
            case .starting_Stopping: return "starting"
            default:
                return "unknown"
            
        }
    
    }
}
