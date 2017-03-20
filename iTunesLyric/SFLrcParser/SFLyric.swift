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
	
	func lyric(by mileSecond: Int) -> String {
		switch self {
		case .plain(_):
			return "Only Plain Lyric."
		case .lrc(let lrc):
			guard let laterLyric = lrc.lyrics.index(where: { $0.time > mileSecond }) else {
				return lrc.lyrics.last?.text ?? ""
			}
			return laterLyric == 0 ? "" : lrc.lyrics[laterLyric - 1].text
		}
	}
	
	var lyric: String {
		switch self {
		case .plain(let lines):
			return lines.joined(separator: "\n")
		case .lrc(let lrc):
			return lrc.lyrics.map({ $0.text }).joined(separator: "\n")
		}
	}
}
