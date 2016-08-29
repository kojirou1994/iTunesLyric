//
//  StatusBarView.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa

enum StatusBarTag: Int {
    case showLyric = 0
    case searchLyric
    case preference
    case feedback
    case about
    case quit
    case checkUpdate
}

class StatusBarView: NSView, NSMenuDelegate, NSWindowDelegate {

    var statusItem: NSStatusItem!
    var statusMenu: NSMenu!
    var normalIcon: CGImage?
    var isHilight: Bool = false
    
    override init(frame frameRect: NSRect) {
        statusItem = NSStatusBar.system().statusItem(withLength: -2)
        let itemWidth = statusItem.length
        let itemHeight = NSStatusBar.system().thickness
        let itemRect = NSRect(x: 0, y: 0, width: itemWidth, height: itemHeight)
        super.init(frame: itemRect)
        statusItem.highlightMode = true
        initStatusMenu()
        statusItem.view = self
        statusItem.highlightMode = true
        let normalImage = NSImage(named: "star")
        normalIcon = normalImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        statusMenu.removeAllItems()
        NSStatusBar.system().removeStatusItem(statusItem)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    private func initStatusMenu() {
        statusMenu = NSMenu(title: "menu")
        statusMenu.delegate = self
        
        var newItem: NSMenuItem
        
        newItem = NSMenuItem(title: "隐藏歌词", action: #selector(StatusBarView.hideLyric(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.showLyric.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: "搜索歌词...", action: #selector(StatusBarView.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.searchLyric.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        statusMenu.addItem(NSMenuItem.separator())
        
        newItem = NSMenuItem(title: "偏好设置...", action: #selector(StatusBarView.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.preference.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        //    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"检查更新..." action: @selector(showPreference:) keyEquivalent: @""];
        //    newItem.tag = kStatusCheckUpdateTag;
        //    [newItem setTarget: self];
        //    [newItem setEnabled: YES];
        //    [statusMenu addItem: newItem];
        
        statusMenu.addItem(NSMenuItem.separator())
        
        newItem = NSMenuItem(title: "反馈...", action: #selector(StatusBarView.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.feedback.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: "关于...", action: #selector(StatusBarView.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.about.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)

        newItem = NSMenuItem(title: "Quit", action: #selector(StatusBarView.quit), keyEquivalent: "")
        newItem.tag = StatusBarTag.quit.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
    }
    
    // MARK: - pragma mark Mouse Event
    
    override func rightMouseDown(with event: NSEvent) {
        isHilight = true
        needsDisplay = true
        statusItem.popUpMenu(statusMenu)
        super.rightMouseDown(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        isHilight = true
        needsDisplay = true
        statusItem.popUpMenu(statusMenu)
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        isHilight = false
        needsDisplay = true
        super.mouseUp(with: event)
    }

    
    // MARK: - pragma mark NSMenu Delegate
    func menuWillOpen(_ menu: NSMenu) {
        isHilight = true
        needsDisplay = true
    }
    
    func menuDidClose(_ menu: NSMenu) {
        isHilight = false
        needsDisplay = true
    }
    
    // MARK: - pragma mark NSMenu Action
    
    func hideLyric(item: NSMenuItem) {
        var needHide = false
        if item.title == "隐藏歌词" {
            item.title = "显示歌词"
            needHide = true
        }else {
            item.title = "隐藏歌词"
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("kNotification_HideLyric"), object: needHide)
    }
    
    func showPreference(item: NSMenuItem) {
        NotificationCenter.default.post(name: NSNotification.Name("kNotification_ShowWindow"), object: item.tag)
    }
    
    func quit() {
        NSApplication.shared().terminate(nil)
    }
}
