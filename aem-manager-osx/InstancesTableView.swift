//
//  InstancesTableView.swift
//  aem-manager-osx
//
//  Created by mceruti on 27.11.18.
//  Copyright © 2018 Peter Mannel-Wiedemann.
//  Fixes and additional Tweaks by Matteo Ceruti.
//  All rights reserved.

import Foundation
import Cocoa

class InstancesTableView : NSTableView {

    // Unfortunately this is necessary so that the context-menu behaves as expected. I adapted the important pieces from
    // https://forums.macrumors.com/threads/cocoa-nstableview-right-click-action-and-row-detection-cruel-joke.2089066/

    override func menu(for event: NSEvent) -> NSMenu? {
        
        if (self.numberOfRows == 0) {
            return nil
        }
        
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        
        if (row == -1) {
            return nil
        }
        
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        let controller = delegate as! ViewController
        return controller.openContextMenu()
    }
}
