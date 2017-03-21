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

public enum Result<T> {
	case success(T)
	case failure(Error?)
}

public protocol LyricSearchable {
	func smartSearch(bySong song: Song, completion: @escaping (Result<SFLyric>) -> Void)
}

public protocol LyricProvidable: CustomStringConvertible {
	
	associatedtype SearchResult: ResultRepresentable
	
	func search(bySong song: Song, completion: @escaping (Result<[SearchResult]>) -> Void) throws
	
	func parse(result: SearchResult, completion: @escaping (Result<SFLyric>) -> Void) throws
	
}

extension LyricProvidable {
	
	public func filteredNilString(_ input: SFPlainLyric) -> SFPlainLyric {
		var result = input
		while let first = result.first, first == "" {
			result.removeFirst()
		}
		return result
	}
	
	public func validateArtist(l: String?, r: String) -> Bool {
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

public protocol ResultRepresentable {
	var columnCount: Int { get }
	func text(at column: Int) -> String
}
