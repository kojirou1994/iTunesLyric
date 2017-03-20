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

struct NeteaseLyricServer: LyricProvidable {
	
	struct NeteaseSearchResult {
		let neteaseId: Int
		let song: Song
	}
	typealias SearchResult = NeteaseSearchResult
	
	public static func search(by song: Song) throws -> [NeteaseSearchResult] {
		<#code#>
	}
	
	public static func smartSearch(by song: Song) throws -> SFLyric {
		<#code#>
	}
	
	public static func parse(result: NeteaseSearchResult) throws -> SFLyric {
		<#code#>
	}
	
	public static func fetchLyric(with result: NeteaseSearchResult) {
		var request = URLRequest(url: URL(string: "\(FetchSongLyricURL)&id=\(result.neteaseId)")!)
		request.setValue("Cookie", forHTTPHeaderField: ENET_COOKIE)
		request.setValue("User-Agent", forHTTPHeaderField: ENET_UA)
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data, let response = response as? HTTPURLResponse,
				response.statusCode == 200, let json = SFJSON(data: data) else {
					//                completion(nil)
					return
			}
			if let lyric = json["lrc"]["lyric"].string {
				print("\(result.song.filename), 找到正确的歌词信息")
				let lrc = SFLyricParser.parse(lyric: lyric)
				//                print(lyric)
				completion(.success(lrc))
			} else {
				//				print(String.init(data: data, encoding: .utf8))
			}
			}.resume()
	}
}
