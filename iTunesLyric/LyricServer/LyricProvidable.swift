//
//  LyricProvidable.swift
//  kget
//
//  Created by Kojirou on 2017/3/9.
//
//

import Foundation
import Kanna

enum LyricSearchError: Error {
	case noResult
	case lyricParseError
}

//public typealias Lyric = [String]

public protocol LyricProvidable {
	
	associatedtype SearchResult
	
	static func smartSearch(by song: Song, completion: (SFLyric) -> Void) throws
	
	static func search(by song: Song, completion: ([SearchResult]) -> Void) throws
	
	static func parse(result: SearchResult, completion: (SFLyric) -> Void) throws
	
}

extension LyricProvidable {
	
	public func filteredNilString(_ input: SFPlainLyric) -> SFPlainLyric {
		var result = input
		while let first = result.first, first == "" {
			result.removeFirst()
		}
		return result
	}
	
}

