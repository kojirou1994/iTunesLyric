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
	case writelyric
}

class LyricStatusBarMenu: NSObject, NSMenuDelegate, NSWindowDelegate {

    var statusItem: NSStatusItem!
    var statusMenu: NSMenu!
    
	override init() {
		super.init()
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        statusItem.highlightMode = true
        initStatusMenu()
		statusItem.image = NSImage(named: "music")
		statusItem.menu = statusMenu
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        statusMenu.removeAllItems()
        NSStatusBar.system().removeStatusItem(statusItem)
    }
    
    private func initStatusMenu() {
        statusMenu = NSMenu(title: "menu")
        statusMenu.delegate = self
        
        var newItem: NSMenuItem
        
        newItem = NSMenuItem(title: "隐藏歌词", action: #selector(LyricStatusBarMenu.hideLyric(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.showLyric.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: "搜索歌词...", action: #selector(LyricStatusBarMenu.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.searchLyric.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        statusMenu.addItem(NSMenuItem.separator())
        
        newItem = NSMenuItem(title: "偏好设置...", action: #selector(LyricStatusBarMenu.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.preference.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
		
		newItem = NSMenuItem(title: "写入歌词", action: #selector(LyricStatusBarMenu.showLyricWindow(item:)), keyEquivalent: "")
		newItem.tag = StatusBarTag.writelyric.rawValue
		newItem.target = self
		newItem.isEnabled = true
		statusMenu.addItem(newItem)
		
        //    newItem = [[NSMenuItem allocWithZone: [NSMenu menuZone]] initWithTitle: @"检查更新..." action: @selector(showPreference:) keyEquivalent: @""];
        //    newItem.tag = kStatusCheckUpdateTag;
        //    [newItem setTarget: self];
        //    [newItem setEnabled: YES];
        //    [statusMenu addItem: newItem];
        
        statusMenu.addItem(NSMenuItem.separator())
        
        newItem = NSMenuItem(title: "反馈...", action: #selector(LyricStatusBarMenu.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.feedback.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: "关于...", action: #selector(LyricStatusBarMenu.showPreference(item:)), keyEquivalent: "")
        newItem.tag = StatusBarTag.about.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)

        newItem = NSMenuItem(title: "Quit", action: #selector(LyricStatusBarMenu.quit), keyEquivalent: "")
        newItem.tag = StatusBarTag.quit.rawValue
        newItem.target = self
        newItem.isEnabled = true
        statusMenu.addItem(newItem)
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
		Swift.print("Show Preference \(item.title)")
        NotificationCenter.default.post(name: NSNotification.Name("kNotification_ShowWindow"), object: item.tag)
    }
    
    func quit() {
        NSApplication.shared().terminate(nil)
    }
	
	var lyricWindow = LyricWriteWindowController(windowNibName: "LyricWriteWindowController")
	
	func showLyricWindow(item: NSMenuItem) {
		print("Opening Lyric Write Window.")
		lyricWindow.showWindow(self)
	}
}
