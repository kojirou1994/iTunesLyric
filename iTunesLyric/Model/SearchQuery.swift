//
//  SearchQuery.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/27.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Foundation

enum SearchType: Int {
    case music = 1
    case album = 10
    case artist = 100
    case playlist = 1000
    case user = 1002
    case mv = 1004
    case lyric = 1006
    case radio = 1009
}

struct SearchQuery {
    var type: SearchType = .music
    var total: Bool = true
    var key: String
    var limit: Int = 100
    var offset: Int = 0
    
    init(key: String) {
        self.key = key
    }
    
    var httpBody: Data? {
        let param: [String : Any] = [
            "s": key,
            "type": type.rawValue,
            "total": total,
            "limit": limit,
            "offset": offset,
            "hlpretag": "<span class=\"s-fc2\">",
            "hlposttag": "</span>"
        ]
        var parts: [String] = []
        for (key, value) in param {
            let part = "\(key)=\(value)"
            parts.append(part)
        }
        return parts.joined(separator: "&").data(using: .utf8)
//        return try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
    }
}
