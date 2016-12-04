//
//  LyricDisplayWindow.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa

class LyricDisplayWindow: NSWindow {
	
    var lyric: String {
        set {
            if newValue == innerView.text {
                return
            } else {
				let newFrame = rectOf(text: newValue, font: innerView.font)
                innerView.frame = newFrame
                innerView.text = newValue
				setFrame(NSRect.init(origin: frame.origin, size: CGSize(width: newFrame.size.width, height: newFrame.size.height)), display: true)
            }
        }
        get {
            return innerView.text
        }
    }
    
    var innerView: InnerView
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        innerView = InnerView(frame: contentRect)
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        self.contentView = innerView
        self.level = Int(CGWindowLevelKey.statusWindow.rawValue)
        self.backgroundColor = NSColor.clear
        
        self.isOpaque = false
        self.makeFirstResponder(innerView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LyricDisplayWindow.fontChanged(notification:)), name: NSNotification.Name.init("kNotification_FontChanged"), object: nil)
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func rectOf(text: String, font: NSFont) -> NSRect {
        var size = (text as NSString).size(withAttributes: [NSFontAttributeName: font])
        size.width += 2 * leftMargin
        size.height += 2 * topMargin
        return NSRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func fontChanged(notification: NSNotification) {
        lyric = innerView.text
    }
    
    // MARK: - pragma mark MouseEvent
    var mouseDownInitPoint = NSPoint.zero
    
    override func mouseDown(with event: NSEvent) {
        mouseDownInitPoint = convertToScreen(NSRect(origin: event.locationInWindow, size: CGSize.zero)).origin
        mouseDownInitPoint.x -= frame.origin.x
        mouseDownInitPoint.y -= frame.origin.y
        
        super.mouseDown(with: event)
    }

    
    override func mouseDragged(with event: NSEvent) {
        
        let currentLocation = NSEvent.mouseLocation()
        var newOrigin = NSPoint(x: currentLocation.x - mouseDownInitPoint.x, y: currentLocation.y - mouseDownInitPoint.y)
        
        // Don't let window get dragged up under the menu bar
        if (newOrigin.y + frame.height) > (NSScreen.main()!.frame.origin.y + NSScreen.main()!.frame.height) {
            newOrigin.y = NSScreen.main()!.frame.origin.y + NSScreen.main()!.frame.height - frame.height
        }
        
        //go ahead and move the window to the new location
        setFrameOrigin(newOrigin)
        
        /*
        let currentPoint = self.convertToScreen(NSRect(origin: mouseLocationOutsideOfEventStream, size: CGSize.zero)).origin
        let newPoint = NSPoint(x: currentPoint.x - mouseDownInitPoint.x, y: currentPoint.y - mouseDownInitPoint.y)
        self.setFrameOrigin(newPoint)
        */
        super.mouseDragged(with: event)
    }
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		Swift.print("Window Frame: \(frame)")
	}
}
