//
//  InnerView.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa

class InnerView: NSView {
    
    var text: String = "" {
        willSet {
            
        }
        didSet {
            needsDisplay = true
        }
    }
    
    var color: NSColor = .red
    
    var font: NSFont = NSFont.boldSystemFont(ofSize: (UserDefaults.standard.object(forKey: "lyricFont") as? CGFloat) ?? 35) {
        didSet {
            needsDisplay = true
        }
    }
    var mouseIn: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    var trackingArea: NSTrackingArea?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        updateTrackingAreas()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InnerView.colorChanged(notification:)), name: NSNotification.Name(rawValue: "kNotificaiton_ColorChanged"), object: nil)
        
        if let data = UserDefaults.standard.object(forKey: "lyricColor") as? Data, let color = NSUnarchiver.unarchiveObject(with: data) as? NSColor {
            self.color = color
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
        if mouseIn {
            NSColor(calibratedRed: 0, green: 0, blue: 0.4, alpha: 0.5).setFill()
            let path = NSBezierPath(roundedRect: bounds, xRadius: 10, yRadius: 10)
            path.fill()
        }
        (text as NSString).draw(in: NSRect.init(x: leftMargin, y: topMargin, width: bounds.width - 2 * leftMargin, height: bounds.height - 2 * topMargin), withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
//        Swift.print(self.frame)
        // Drawing code here.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func mouseEntered(with event: NSEvent) {
//        Swift.print("mouseEntered")
        mouseIn = true
        super.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
//        Swift.print("mouseExited")
        mouseIn = false
        super.mouseExited(with: event)
    }
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		Swift.print("View Frame: \(frame)")
	}

    override func updateTrackingAreas() {
        if trackingArea != nil {
            removeTrackingArea(trackingArea!)
        }
        let opts: NSTrackingAreaOptions = [.mouseEnteredAndExited, .activeAlways]
        trackingArea = NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    func colorChanged(notification: NSNotification) {
        if let data = UserDefaults.standard.object(forKey: "lyricColor") as? Data {
            color = NSUnarchiver.unarchiveObject(with: data) as! NSColor
            needsDisplay = true
        }
    }
    
    func fontChanged(notification: NSNotification) {
        let fontSize = UserDefaults.standard.object(forKey: "lyricFont") as! CGFloat
        font = NSFont.boldSystemFont(ofSize: fontSize)
    }
}
