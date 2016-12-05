//
//  AppDelegate.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var prefWindow: NSWindow!

    var lyricWindow: LyricDisplayWindow!
    var barView: LyricStatusBarMenu!
    var itunes: iTunesApplication!
    var timer: Timer?
	var lyric: LyricRepresentable? {
		didSet {
//			print(currentLrc)
		}
	}
    var song: Song?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        guard let it = SBApplication(bundleIdentifier: "com.apple.iTunes") as? iTunesApplication else {
            showTerminateAlert()
            return
        }
        
        itunes = it
        
        if !itunes.isRunning {
            itunes.activate()
        }
        sleep(1)
        
        createLyricWindow()
        registerNotification()
        
        // init status bar icon
        barView = LyricStatusBarMenu()
        
        // set preference window
        prefWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)

//        [self.updater checkForUpdatesInBackground];

        // init itunes playing state
        if itunes.playerState! == iTunesEPlS.Playing {
            initTimer()
            self.song = currentPlayingSong()
            if song != nil {
                print("Song Not Nil")
                lyricWindow.lyric = "\(song!.filename)"
				lyric = nil
                iTunesLyricHelper.shared.smartFetchLyric(with: song!, completion: { (lrc) in
//                    self.iTunesLyricFetchFinished(song: song!)
					self.lyric = lrc
					print(self.itunes.currentTrack?.lyrics)
					if lrc != nil && self.itunes.currentTrack?.lyrics == nil || self.itunes.currentTrack?.lyrics == "" {
						self.itunes.currentTrack?.setLyrics?(lrc!.lyric)
					}
                })
            } else {
                print("Song Nil")
                lyricWindow.lyric = "没有检测到歌曲信息"
            }
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("com.apple.toolsQA.CocoaApp_CD")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "iTunesLyric", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try self.applicationDocumentsDirectory.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !properties.isDirectory! {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("iTunesLyric.storedata")
            do {
                try coordinator!.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                 
                /*
                 Typical reasons for an error here include:
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            if let error = failError {
                NSApplication.shared().presentError(error)
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
            fatalError("Unsresolved error: \(failureReason)")
        } else {
            return coordinator!
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

// MARK: - Alert
extension AppDelegate {
    
    func showTerminateAlert() {
        iTunesErrorAlert.runModal()
    }
    
    func terminate() {
        NSApplication.shared().terminate(nil)
    }
    
    var iTunesErrorAlert: NSAlert {
        let alert = NSAlert()
        alert.informativeText = "No iTunes."
        let button = alert.addButton(withTitle: "OK")
        button.target = self
        button.action = #selector(AppDelegate.terminate)
        return alert
    }
	
}


extension AppDelegate {
	
    func createLyricWindow() {
        // create lyric window
        print("creating")
        lyricWindow = LyricDisplayWindow(contentRect: NSRect.init(x: 100, y: 100, width: (NSScreen.main()?.frame.width ?? 1080 - 2 * 100) / 3, height: 80), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        print("created")
        lyricWindow.lyric = "Init"
        lyricWindow.makeKeyAndOrderFront(nil)
        print("Window Frame")
        print(lyricWindow.frame)
        print("Inner Frame")
        print(lyricWindow.innerView.frame)
    }
    
    func registerNotification() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.updateTrackInfo(notification:)), name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.preference(notification:)), name: NSNotification.Name.init("kNotification_ShowWindow"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.hideLyricPanel(notification:)), name: NSNotification.Name.init("kNotification_HideLyric"), object: nil)
        
//        [dnc addObserver:self selector:@selector(updateTrackInfo:) name: @"com.apple.iTunes.playerInfo" object:nil];
    }
    
    func initTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AppDelegate.fetchProgress(timer:)), userInfo: nil, repeats: true)
        }
    }
}

extension AppDelegate {
    // MARK: - iTunes Song Playing
    // get current playing song
    func currentPlayingSong() -> Song? {
        guard let track = itunes?.currentTrack, track.name?.characters.count != 0 else {
            print("No Track Info")
            return nil
        }
        print("Got Track Info")
        return Song(title: track.name!, artist: track.artist!, album: track.album!)
    }

    func updateTrackInfo(notification: NSNotification) {
        guard let state = notification.userInfo?["Player State"] as? String else {
            return
        }
        if state == "Paused" {
            timer?.invalidate()
            timer = nil
        }else if state == "Playing" {
            initTimer()
            if song != currentPlayingSong() {
                song = currentPlayingSong()
                if song != nil {
                    lyricWindow.lyric = "\(song!.filename)"
                }else {
                    lyricWindow.lyric = "没有检测到歌曲信息"
                }
				lyric = nil
                iTunesLyricHelper.shared.smartFetchLyric(with: song!, completion: { lrc in
//                    self.iTunesLyricFetchFinished(song: $0!)
                    self.lyric = lrc
					print(self.itunes.currentTrack?.lyrics)
					if lrc != nil && self.itunes.currentTrack?.lyrics == nil || self.itunes.currentTrack?.lyrics == "" {
						self.itunes.currentTrack?.setLyrics?(lrc!.lyric)
					}
                })
                
                if !lyricWindow.isVisible {
                    lyricWindow.lyric = ""
                    lyricWindow.makeKeyAndOrderFront(nil)
                }
            }

        }
        
    }
    
    func changeSong() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AppDelegate.fetchProgress(timer:)), userInfo: nil, repeats: true)
        self.song = currentPlayingSong()
        self.lyric = nil
        if song != nil {
            lyricWindow.lyric = "\(song!.filename)"
            iTunesLyricHelper.shared.smartFetchLyric(with: song!, completion: { (lrc) in
                //                    self.iTunesLyricFetchFinished(song: song!)
				self.lyric = lrc
				print(self.itunes.currentTrack?.lyrics)
				if lrc != nil && self.itunes.currentTrack?.lyrics == nil || self.itunes.currentTrack?.lyrics == "" {
					self.itunes.currentTrack?.setLyrics?(lrc!.lyric)
				}
            })
        } else {
            lyricWindow.lyric = "没有检测到歌曲信息"
        }
    }
    
    // lyric fetch finished notficaiton
//    func iTunesLyricFetchFinished(song: Song) {
//    if (song.lyrics) {
//    self.song.lyrics = song.lyrics;
//    self.song.lyricId = song.lyricId;
//    
//    if (![song.name isEqualToString: self.song.name]) {
//    self.song.name = song.name;
//    self.song.artist = song.artist;
//    [[iTunesLyricHelper shareHelper] saveSongLyricToLocal: self.song];
//    }
//    }
//    
//    if (song.lyrics) {
//    [self.lyricWindow setLyric: [NSString stringWithFormat: @"%@ - %@", self.song.name, self.song.artist]];
//    [self analyzeLyric: song.lyrics];
//    } else {
//    [self.lyricDict removeAllObjects];
//    [self.lyricWindow setLyric: @"没有检测到歌词信息"];
//    }
//    }
    
    /*
     Search Delegate
    func searchLyricWillBegin() {
        lyricWindow.lyric = "正在导入中..."
    }
    
    func searchLyricDidImportLyricToSong(song: Song?) {
        if song == nil {
            lyricWindow.lyric = "导入失败"
        } else {
            iTunesLyricFetchFinished(song: song!)
        }
    }
    */
    
    //TODO: rewrite
    // song playing timer call back
    func fetchProgress(timer: Timer) {
        guard let playerPosition = itunes?.playerPosition else {
            return
        }
        let lyric = self.lyric?.lyric(by: Int(playerPosition * 1000)) ?? ""
        lyricWindow.lyric = lyric

//        print(playerPosition)
//    NSString *time = [self secs2String: playerPosition];
//    NSString *lyricStr = self.lyricDict[time];
//    if (lyricStr.length) {
//    [self.lyricWindow setLyric: lyricStr];
//    }
    }
    
    //FIXME
    //TODO: remove
    // util to convert sec to string
//    - (NSString *)secs2String:(NSInteger)time
//    {
//    return [NSString stringWithFormat:@"%.2ld:%.2ld",time / 60,time % 60];
//    }
    
    // analy lyric
    //TODO: rewrite
    func analyzeLyric(lyric: String) {
//        if lyricDict == nil {
//            lyricDict = NSMutableDictionary()
//        }
//        lyricDict?.removeAllObjects()
//        
//    if (self.lyricDict == nil) {
//    self.lyricDict = [NSMutableDictionary dictionary];
//    }
//    [self.lyricDict removeAllObjects];
//    
//    NSArray *lyricsArray = [lyrics componentsSeparatedByString: @"\n"];
//    for (NSString *lyric in lyricsArray) {
//    if (lyric.length == 0) continue;
//    NSArray *tmpArray = [lyric componentsSeparatedByString: @"]"];
//    if ([tmpArray.firstObject length] < 1) continue;
//    NSString *timeStr = [[tmpArray firstObject] substringFromIndex: 1];
//    NSArray * timeArray = [timeStr componentsSeparatedByString:@"."];
//    NSString * lyricTimeStr = timeArray.firstObject;
//    NSString * lyricStr = tmpArray.lastObject;
//    
//    if (lyricTimeStr.length && lyricStr.length) {
//    [self.lyricDict setValue: lyricStr forKey: lyricTimeStr];
//    }
//    }
    }

}

// MARK: - Preference
extension AppDelegate {
    /*
    - (IBAction)colorChanged:(id)sender
    {
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotificaiton_ColorChanged object: nil];
    }
    
    - (IBAction)fontChanged:(id)sender
    {
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotification_FontChanged object: nil];
    }
    
    - (IBAction)startupChanged:(id)sender
    {
    
    }
 */
    
    func preference(notification: Notification) {
        guard let tag = notification.object as? StatusBarTag else {
            return
        }
        switch tag {
        case .preference:
            NSApp.activate(ignoringOtherApps: true)
            prefWindow.makeKeyAndOrderFront(nil)
        case .searchLyric:
            NSApp.activate(ignoringOtherApps: true)
            /*
 if (self.searchViewController == nil) {
 self.searchViewController = [[SearchLyricWindowController alloc] initWithWindowNibName: @"SearchLyricWindowController" Song: self.song];
 self.searchViewController.searchLyricDelegate = self;
 [self.searchViewController.window makeKeyAndOrderFront: nil];
 } else {
 self.searchViewController.song = self.song;
 [self.searchViewController.window makeKeyAndOrderFront: nil];
 }
 */
        case .feedback:
            NSWorkspace.shared().open(URL(string: "")!)
        case .about:
            NSApp.orderFrontStandardAboutPanel(nil)
        case .checkUpdate:
            break
        default:
            break
        }
    
    }
    
    func hideLyricPanel(notification: Notification) {
        guard let needHide = notification.object as? Bool else {
            return
        }
        if needHide {
            lyricWindow.orderOut(nil)
        } else {
            let lyric = lyricWindow.lyric
            lyricWindow.lyric = ""
            lyricWindow.makeKeyAndOrderFront(nil)
            lyricWindow.lyric = lyric
        }
    }
}
