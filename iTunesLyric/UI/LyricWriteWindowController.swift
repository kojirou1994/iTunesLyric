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
		queue.async {
			for index in 0...6484 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 6485...12970 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		
		queue.async {
			for index in 12970...19455 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 19456...25940 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 25941...30000 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 30000...36000 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 36001...42000 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 42001...50000 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
		queue.async {
			for index in 50000...51873 {
				let it = tracks[index] as! iTunesTrack
				let song = Song(title: it.name!, artist: it.artist!/*, album: track.album!*/)!
				print("\(index) - \(song.filename) Searching..")
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
