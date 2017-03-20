//
//  Kget.swift
//  iTunesLyric
//
//  Created by Kojirou on 2017/3/20.
//  Copyright © 2017年 Putotyra. All rights reserved.
//

import Foundation
import Kanna

struct KgetLyric: LyricProvidable {
	
	struct KgetSearchResult {
		let url: String
		let song: Song
	}
	
	typealias SearchResult = KgetSearchResult
	
	public static func smartSearch(by song: Song) throws -> SFLyric {
		return try parse(result: try search(by: song).first!)
	}
	
	//page: div.kg-paging -> a
	public static func search(by song: Song) throws -> [KgetLyric.KgetSearchResult] {
		guard song.title != "" else {
			print("Title cannnot be nil.")
			return []
		}
		print("Searching")
		let url = "http://www.kget.jp/search/index.php?c=0&r=\(song.artist)&t=\(song.title)&v=&f="
		guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
			let kgetUrl = URL(string: encodedUrl) else {
				print("url add percent error")
				return []
		}
		
		let data = try Data(contentsOf: kgetUrl)
		
		guard let html = HTML(html: data, encoding: .utf8) else {
			throw LyricSearchError.lyricParseError
		}
		
		guard let songlist = html.css("ul.songlist").first else {
			throw LyricSearchError.noResult
		}
		let results = songlist.css("a.lyric-anchor").flatMap { element -> KgetSearchResult? in
			guard let url = element["href"], let title = element.text else {
				return nil
			}
			return KgetSearchResult(url: "http://www.kget.jp" + url, artist: "", title: title)
		}
		return results
		
	}
	
	public static func parse(result: KgetLyric.KgetSearchResult) throws -> SFLyric {
		let data = try Data(contentsOf: URL(string: result.url)!)
		
		guard let html = HTML(html: data, encoding: .utf8) else {
			throw LyricSearchError.lyricParseError
		}
		
		if let lyric = html.css("div#lyric-trunk").first?.content?.components(separatedBy: "\n") {
			print(lyric.joined(separator: "\n"))
			return .plain(lyric)
		} else {
			throw LyricSearchError.lyricParseError
		}
	}
	
}
