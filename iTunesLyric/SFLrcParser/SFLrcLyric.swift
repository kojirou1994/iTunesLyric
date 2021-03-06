//
//  SFLyric.swift
//  SFLrcParser
//
//  Created by 王宇 on 2016/8/27.
//
//

import Foundation

public struct SFLrcLyric {
    public var time: Int
    public var text: String
    
    public init?(time: String, text: String) {
        let time = time.substring(from: time.index(time.startIndex, offsetBy: 1))
        guard let minute = Int(time.substring(to: time.index(time.startIndex, offsetBy: 2))),
            let second = Int(time[time.index(time.startIndex, offsetBy: 3)..<time.index(time.startIndex, offsetBy: 5)]),
            case let mileSecondStr = time[time.index(time.startIndex, offsetBy: 6)..<time.endIndex],
			let mileSecond = Int(mileSecondStr) else {
				return nil
        }
		switch mileSecondStr.characters.count {
		case 3:
			self.time = (minute * 60 + second) * 1000 + mileSecond
		case 2:
			self.time = (minute * 60 + second) * 1000 + mileSecond * 10
		default:
			self.time = (minute * 60 + second) * 1000 + mileSecond * 100
		}
        self.text = text
	}
}

extension SFLrcLyric: Comparable {
    
    public static func ==(lhs: SFLrcLyric, rhs: SFLrcLyric) -> Bool {
        return lhs.time == rhs.time && lhs.text == rhs.text
    }
    
    public static func <(lhs: SFLrcLyric, rhs: SFLrcLyric) -> Bool {
        return lhs.time < rhs.time
    }
    
    public static func <=(lhs: SFLrcLyric, rhs: SFLrcLyric) -> Bool {
        return lhs.time <= rhs.time
    }
    
    public static func >=(lhs: SFLrcLyric, rhs: SFLrcLyric) -> Bool {
        return lhs.time >= rhs.time
    }

    public static func >(lhs: SFLrcLyric, rhs: SFLrcLyric) -> Bool {
        return lhs.time > rhs.time
    }
}
