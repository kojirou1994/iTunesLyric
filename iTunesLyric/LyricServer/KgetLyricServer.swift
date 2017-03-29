//
//  Kget.swift
//  iTunesLyric
//
//  Created by Kojirou on 2017/3/20.
//  Copyright © 2017年 Putotyra. All rights reserved.
//

import Foundation
import Kanna

struct KgetLyric: LyricProvidable, LyricSearchable {
	
	struct KgetSearchResult: ResultRepresentable {
		let url: String
		let title: String
		let artist: String
		
		var columnCount: Int {
			return 2
		}
		
		func text(at column: Int) -> String {
			return "demo"
		}
	}
	var smartFilter: ((Song, [SearchResult]) -> SearchResult)?
	typealias SearchResult = KgetSearchResult
	
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
	
	//page: div.kg-paging -> a
	public func search(bySong song: Song, completion: @escaping (Result<[KgetSearchResult]>) -> Void) throws {
		guard song.title != "" else {
			print("Title cannnot be nil.")
			completion(.failure(LyricSearchError.noResult))
			return
		}
		print("Searching")
		let url = "http://www.kget.jp/search/index.php?c=0&r=\(song.artist)&t=\(song.title)&v=&f="
		guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
			let kgetUrl = URL(string: encodedUrl) else {
				print("url add percent error")
				completion(.failure(LyricSearchError.noResult))
				return
		}
		
		let data = try Data(contentsOf: kgetUrl)
		
		guard let html = HTML(html: data, encoding: .utf8) else {
			completion(.failure(LyricSearchError.lyricParseError))
			return
		}
		
		guard let songlist = html.css("ul.songlist").first else {
			completion(.failure(LyricSearchError.noResult))
			return
		}
		let results = songlist.css("a.lyric-anchor").flatMap { element -> KgetSearchResult? in
			guard let url = element["href"], let title = element.text else {
				return nil
			}
			let result = KgetSearchResult(url: "http://www.kget.jp" + url, title: title, artist: "")
			return result
		}
		completion(.success(results))
	}
	
	public func parse(result: KgetLyric.KgetSearchResult, completion: @escaping (Result<SFLyric>) -> Void) throws {
		let data = try Data(contentsOf: URL(string: result.url)!)
		
		guard let html = HTML(html: data, encoding: .utf8) else {
			throw LyricSearchError.lyricParseError
		}
		
		if let lyric = html.css("div#lyric-trunk").first?.content?.components(separatedBy: "\n") {
//			print(lyric.joined(separator: "\n"))
			completion(.success(.plain(filteredNilString(lyric))))
		} else {
			throw LyricSearchError.lyricParseError
		}
	}
	
	var description: String {
		return "Kget"
	}
}
