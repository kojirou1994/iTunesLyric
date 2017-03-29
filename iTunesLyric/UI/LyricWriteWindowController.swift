//
//  LyricWriteWindowController.swift
//  iTunesLyric
//
//  Created by Kojirou on 2017/3/21.
//  Copyright © 2017年 Putotyra. All rights reserved.
//

import Cocoa
import Dispatch

class LyricWriteWindowController: NSWindowController {

	@IBAction func startButtonTapped(_ sender: Any) {
		print("Starting...")
		let appDelegate = NSApplication.shared().delegate as! AppDelegate
		let itunes = appDelegate.itunes
		guard let tracks = itunes?.tracks?() else {
			log("No tracks.")
			return
		}
		let server = KgetLyric()
		let opq = OperationQueue()
		opq.maxConcurrentOperationCount = 20
		for track in tracks {
			let it = track as! iTunesTrack
			let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
			print("\(index) - \(song.filename) Searching..")
			opq.addOperation {
				server.smartSearch(bySong: song, completion: { (result) in
					switch result {
					case .success(let lrc):
						it.setLyrics?(lrc.lyric)
						print("\(song.filename) Write Lyric OK.")
					case .failure(_):
						print("\(song.filename) No Lyric.")
					}
				})
			}
		}
	}
	
	@IBOutlet weak var logTextField: NSTextField!
	
	let queue = DispatchQueue(label: "writelyric", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
	
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
	
	func log(_ text: String) {
		logTextField.stringValue.append(text)
	}
    
}
