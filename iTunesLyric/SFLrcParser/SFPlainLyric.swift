//
//  SFPlainLyric.swift
//  iTunesLyric
//
//  Created by Kojirou on 2016/12/5.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Foundation

public struct SFPlainLyric: LyricRepresentable {
	
	public var lyrics: [String]
	
	init(lyric: String) {
		lyrics = lyric.components(separatedBy: "\n")
	}
	
	public var lyric: String {
		return lyrics.joined(separator: "\n")
	}
	
}
