//
//  RoundedNSView.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/31.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa

class RoundedNSView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 1).setFill()
        let path = NSBezierPath(roundedRect: dirtyRect, xRadius: 10, yRadius: 10)
        path.fill()
        // Drawing code here.
    }
    
}
