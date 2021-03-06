//
//  SFLyric.swift
//  iTunesLyric
//
//  Created by Kojirou on 2017/3/20.
//  Copyright © 2017年 Putotyra. All rights reserved.
//

import Foundation

public enum SFLyric {
	
	case plain(SFPlainLyric)
	case lrc(SFLrc)
	case none
	
	init(text: String) {
		if text.characters.count == 0 {
			self = .none
		}
		else if let lrc = SFLrc(lyric: text) {
			self = .lrc(lrc)
		}
		else {
			self = .plain(text.components(separatedBy: "\n"))
		}
	}
	
	func lyric(by mileSecond: Int) -> String {
		switch self {
		case .plain(_):
			return "Only Plain Lyric."
		case .lrc(let lrc):
			guard let laterLyric = lrc.lyrics.index(where: { $0.time > mileSecond }) else {
				return lrc.lyrics.last?.text ?? ""
			}
			return laterLyric == 0 ? "" : lrc.lyrics[laterLyric - 1].text
		case .none:
			return "No Lyric."
		}
	}
	
	var lyric: String {
		switch self {
		case .plain(let lines):
			return lines.joined(separator: "\n")
		case .lrc(let lrc):
			return lrc.lyrics.map({ $0.text }).joined(separator: "\n")
		case .none:
			return ""
		}
	}
}

extension SFLyric: Equatable {
	public static func ==(lhs: SFLyric, rhs: SFLyric) -> Bool {
		switch (lhs, rhs) {
		case (.none, .none):
			return true
		case (.lrc(let lrc1), .lrc(let lrc2)):
			return lrc1.lyrics == lrc2.lyrics
		case (.plain(let lrc1), .plain(let lrc2)):
			return lrc1 == lrc2
		default:
			return false
		}
	}
}
