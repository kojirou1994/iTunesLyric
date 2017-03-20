//
//  SFLrcParser.swift
//  SFLrcParser
//
//  Created by 王宇 on 2016/8/27.
//
//

import Foundation

public struct SFLyricParser {
    
	public static func parse(lyric: String) -> SFLyric {
		if let lrc = SFLrc(lyric: lyric) {
			return .lrc(lrc)
		}
		else {
			return .plain(lyric.components(separatedBy: "\n"))
		}
    }
	
}

