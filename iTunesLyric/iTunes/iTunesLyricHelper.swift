//
//  iTunesLyricHelper.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Foundation
import Dispatch

protocol iTunesLyricHelperDelegate: class {
	func didGetLyric(forSong song: Song, lyrics: [SFLyric])
}

class iTunesLyricHelper {
    
    static let shared = iTunesLyricHelper()

	var currentServers: [LyricSearchable] = [KgetLyric(), NeteaseLyricServer()]
	weak var delegate: iTunesLyricHelperDelegate?
	var currentSong: Song?
	var currentResults: [SFLyric] = []
	var serverStatus: [ServerStatus] = []
	
	let searchQueue = DispatchQueue.init(label: "com.Putotyra.searchQueue")
	
	enum ServerStatus {
		case waiting, success, failure
	}
	
	func tryEveryServer(song: Song) {
		currentSong = song
		currentResults = [SFLyric](repeating: .none, count: currentServers.count)
		serverStatus = [ServerStatus](repeating: .waiting, count: currentServers.count)
		for index in 0..<currentServers.count {
			searchQueue.async {
				self.currentServers[index].smartSearch(bySong: song, completion: { result in
					switch result {
					case .success(let lyric):
						self.currentResults[index] = lyric
						self.serverStatus[index] = .success
					case .failure(_):
						self.serverStatus[index] = .failure
					}
					guard !self.serverStatus.contains(.waiting) else {
						return
					}
					self.delegate?.didGetLyric(forSong: self.currentSong!, lyrics: self.currentResults.filter({ $0 != .none }))
				})
			}
		}
	}
	
	func search(song: Song, using server: LyricSearchable, completion: @escaping (Result<SFLyric>) -> Void) {
		server.smartSearch(bySong: song, completion: completion)
	}
	
    /**
     根据歌曲（含有歌词id）获取歌词
     */
    func fetchLyric(withNeteaseID id: Int, completion: @escaping (Result<SFLyric>) -> Void) {
        print("Fetching Lyric")
        var request = URLRequest(url: URL(string: "\(FetchSongLyricURL)&id=\(id)")!)
        request.setValue("Cookie", forHTTPHeaderField: ENET_COOKIE)
        request.setValue("User-Agent", forHTTPHeaderField: ENET_UA)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse,
                response.statusCode == 200, let json = SFJSON(data: data) else {
//                completion(nil)
                return
            }
            if let lyric = json["lrc"]["lyric"].string {
                print("Netease ID: \(id), 找到正确的歌词信息")
                let lrc = SFLyric(text: lyric)
//                print(lyric)
                completion(.success(lrc))
			} else {
//				print(String.init(data: data, encoding: .utf8))
				completion(.failure(nil))
			}
        }.resume()
    }
	
	let lyricPath: URL
	
	init() {
		if let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
			lyricPath = path.appendingPathComponent("iTunesLyric", isDirectory: true).appendingPathComponent("lrc", isDirectory: true)
			
		} else {
			lyricPath = FileManager.default.temporaryDirectory.appendingPathComponent("lrc", isDirectory: true)
		}
		try? FileManager.default.createDirectory(at: lyricPath, withIntermediateDirectories: true, attributes: nil)
	}
	
	// MARK: - 保存歌词到本地
	func save(lyric: SFLyric,for song: Song, force: Bool) throws {
		let lrcPath = lyricPath.appendingPathComponent("\(song.filename).lrc")
		let fm = FileManager.default
		func save(lyric: SFLyric, to path: URL) throws {
			try (lyric.lyric as NSString).write(to: path, atomically: true, encoding: String.Encoding.utf8.rawValue)
		}
		
		if fm.fileExists(atPath: lrcPath.absoluteString) {
			if force {
				try save(lyric: lyric, to: lrcPath)
			}
		} else {
			try save(lyric: lyric, to: lrcPath)
		}
    }
	
	func fetchLocalLyric(for song: Song, completion: (Result<SFLyric>) -> Void) {
		let lrcPath = lyricPath.appendingPathComponent("\(song.filename).lrc")
		guard let content = try? NSString(contentsOf: lrcPath, encoding: String.Encoding.utf8.rawValue) else {
			completion(.failure(nil))
			return
		}
		completion(.success(SFLyric(text: content as String)))
	}
    
    func validateArtist(l: String?, r: String) -> Bool {
        guard let l = l else {
            return r == ""
        }
        let noWhiteL = l.replacingOccurrences(of: " ", with: "").lowercased().applyingTransform(StringTransform(rawValue: "Hant-Hans"), reverse: false)!
        let noWhiteR = r.replacingOccurrences(of: " ", with: "").lowercased().applyingTransform(StringTransform(rawValue: "Hant-Hans"), reverse: false)!
        print("Comparing " + noWhiteL + " and " + noWhiteR)
        if noWhiteL == noWhiteR || noWhiteL.contains(noWhiteR) || noWhiteR.contains(noWhiteL) {
			print("Result: Matched")
            return true
        } else {
			print("Result: UnMatched")
            return false
        }
    }

}
