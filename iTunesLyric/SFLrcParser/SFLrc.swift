//
//  SFLrc.swift
//  SFLrcParser
//
//  Created by 王宇 on 2016/8/29.
//
//

import Foundation

public struct SFLrc: LyricRepresentable {
    
    public var lyrics: [SFLrcLyric]
	
	init?(lyric: String) {
		lyrics = [SFLrcLyric]()
		let lines = lyric.components(separatedBy: "\n").filter { !$0.isEmpty && $0.hasPrefix("[") && $0.contains("]") }
		lines.forEach({ line in
			let separateIndex = line.range(of: "]")!.lowerBound
			let tag = line.substring(to: separateIndex)
			let text = line.substring(from: line.index(separateIndex, offsetBy: 1))
			if tag.characters.count == 8 || tag.characters.count == 9 || tag.characters.count == 10
				&& tag[tag.index(tag.startIndex, offsetBy: 3)] == ":"
				&& tag[tag.index(tag.startIndex, offsetBy: 6)] == ".",
				let lyric = SFLrcLyric(time: tag, text: text) {
				lyrics.append(lyric)
			} else {
				// Lrc tag info handling
			}
		})
		lyrics.sort{ $0 < $1 }
	}
	
	public func lyric(by mileSecond: Int) -> String {
		guard let laterLyric = lyrics.index(where: { $0.time > mileSecond }) else {
			return lyrics.last?.text ?? ""
		}
		return laterLyric == 0 ? "" : lyrics[laterLyric - 1].text
	}
	
	public var lyric: String {
		return lyrics.map({ $0.text }).joined(separator: "\n")
	}
	
}
