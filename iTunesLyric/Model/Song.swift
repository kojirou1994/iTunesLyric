//
//  Song.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa

open class Song {
    
//	var album: String
	
    var artist: String
    
    var title: String
	
    init?(title: String, artist: String/*, album: String, neteaseId: Int = 0*/) {
        guard title.characters.count != 0 else {
            return nil
        }
//        self.album = album
        self.artist = artist
        self.title = title.components(separatedBy: "(")[0]
//        self.neteaseId = neteaseId
    }
}

extension Song: Equatable {
	
	public static func ==(lhs: Song, rhs: Song) -> Bool {
		return lhs.title == rhs.title && lhs.artist == rhs.artist
	}
	
}

extension Song {
	
	var filename: String {
		return "\(artist == "" ? "Unknown Artist" : artist) - \(title)"
	}
	
}
