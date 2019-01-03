//
//  Window.swift
//  Hoping
//
//  Created by hyc on 2019/1/3.
//  Copyright © 2019 HYC. All rights reserved.
//

import Cocoa

class Window: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.alphaValue = 1.0
        window?.backgroundColor = NSColor.clear
        window?.isOpaque = true
        window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        window?.setFrame(NSMakeRect(0, 0, (NSScreen.main?.frame.size.width)!, 20), display: true)
    }
}
