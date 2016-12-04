//
//  SFLrc.swift
//  SFLrcParser
//
//  Created by 王宇 on 2016/8/29.
//
//

import Foundation

public struct SFLrc {
    
    public var lyrics: [SFLyric]
    
    public func currentLyric(byTime mileSecond: Int) -> String {
        guard let laterLyric = lyrics.index(where: { $0.time > mileSecond }) else {
            return lyrics.last?.text ?? ""
        }
		
		return laterLyric == 0 ? "" : lyrics[laterLyric - 1].text
    }
	
	public var lyric: String {
		return lyrics.map({ $0.text }).joined(separator: "\n")
	}
	
}
