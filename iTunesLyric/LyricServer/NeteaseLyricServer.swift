//
//  NeteaseLyricServer.swift
//  iTunesLyric
//
//  Created by Kojirou on 2017/3/20.
//  Copyright © 2017年 Putotyra. All rights reserved.
//

import Foundation

enum SearchType: Int {
	case music = 1
	case album = 10
	case artist = 100
	case playlist = 1000
	case user = 1002
	case mv = 1004
	case lyric = 1006
	case radio = 1009
}

struct NeteaseSearchQuery {
	var type: SearchType = .music
	var total: Bool = true
	var key: String
	var limit: Int = 100
	var offset: Int = 0
	
	init(key: String) {
		self.key = key
	}
	
	var httpBody: Data? {
		let param: [String: Any] = [
			"s": key,
			"type": type.rawValue,
			"total": total,
			"limit": limit,
			"offset": offset,
			"hlpretag": "<span class=\"s-fc2\">",
			"hlposttag": "</span>"
		]
		var parts: [String] = []
		
		let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
		
		for (key, value) in param {
			let part = String(format: "%@=%@",
			                  String(describing: key).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!,
			                  String(describing: value).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!)
			parts.append(part)
		}
		return parts.joined(separator: "&").data(using: .utf8)
	}
}

let FetchSongIDURL = "http://music.163.com/api/search/pc"
let FetchSongLyricURL = "http://music.163.com/api/song/lyric?os=osx&lv=-1&kv=-1&tv=-1"

//#define kNotification_ShowWindow                @"kNotification_ShowWindow"
//#define kNotification_HideLyric                 @"kNotification_HideLyric"
//#define kNotificaiton_ColorChanged              @"kNotificaiton_ColorChanged"
//#define kNotification_FontChanged               @"kNotification_FontChanged"

let ENET_COOKIE = "deviceId=5F7F81C3-B8D3-5BA3-AAB2-D25599CBB3BE%7C793F6423-0C45-4DB4-B719-82010F55973E; os=osx; usertrack=c+5+hVVQh8ajuyyLCsdtAg==; __remember_me=true;"

let ENET_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/600.8.9 (KHTML, like Gecko)"

struct NeteaseLyricServer: LyricProvidable, LyricSearchable {
	
	struct NeteaseSearchResult: ResultRepresentable {
		let neteaseId: Int
		let song: Song
		
		var columnCount: Int {
			return 3
		}
		
		func text(at column: Int) -> String {
			return "demo"
		}
	}
	
	var smartFilter: ((Song, [SearchResult]) -> SearchResult)?
	typealias SearchResult = NeteaseSearchResult
	
	public func smartSearch(bySong song: Song, completion: @escaping (Result<SFLyric>) -> Void) {
		do {
			try search(bySong: song, completion: { (result) -> Void in
				switch result {
				case .success(let results):
					guard let firstResult = results.first else {
						completion(.failure(LyricSearchError.noResult))
						return
					}
					do {
						try self.parse(result: firstResult, completion: { (result) in
							completion(result)
						})
					} catch {
						completion(.failure(error))
					}
				case .failure(let err):
					completion(.failure(err))
				}
			})
		} catch {
			completion(.failure(error))
		}
	}
	
	func search(bySong song: Song, completion: @escaping (Result<[NeteaseLyricServer.NeteaseSearchResult]>) -> Void) throws {
		var request = URLRequest(url: URL(string: FetchSongIDURL)!)
		request.setValue(ENET_COOKIE, forHTTPHeaderField: "Cookie")
		request.setValue(ENET_UA, forHTTPHeaderField: "User-Agent")
		request.httpMethod = "POST"
		request.httpBody = NeteaseSearchQuery(key: "\(song.title) \(song.artist)").httpBody
		
		print("Start Smart Fetch")
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			print("Got Smart Response")
			guard error == nil, let data = data, let bodyString = String.init(data: data, encoding: .utf8) else {
				return
			}
			guard let obj = SFJSON(jsonString: bodyString), let songs = obj["result"]["songs"].arrayObject else {
				return
			}
			let results = songs.map({ (json) -> NeteaseSearchResult in
				return NeteaseSearchResult(neteaseId: json["id"].intValue, song: song)
			})
			completion(.success(results))
		}.resume()
	}
	
	func parse(result: NeteaseLyricServer.NeteaseSearchResult, completion: @escaping (Result<SFLyric>) -> Void) throws {
		fetchLyric(with: result, completion: completion)
	}

	
	public func fetchLyric(with result: NeteaseSearchResult, completion: @escaping (Result<SFLyric>) -> Void) {
		var request = URLRequest(url: URL(string: "\(FetchSongLyricURL)&id=\(result.neteaseId)")!)
		request.setValue("Cookie", forHTTPHeaderField: ENET_COOKIE)
		request.setValue("User-Agent", forHTTPHeaderField: ENET_UA)
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data, let response = response as? HTTPURLResponse,
				response.statusCode == 200, let json = SFJSON(data: data) else {
					completion(.failure(nil))
					return
			}
			if let lyric = json["lrc"]["lyric"].string {
				print("\(result.song.filename), 找到正确的歌词信息")
				let lrc = SFLyric(text: lyric)
				completion(.success(lrc))
			} else {
				completion(.failure(nil))
			}
			}.resume()
	}
	
	var description: String {
		return "Netease"
	}

}
