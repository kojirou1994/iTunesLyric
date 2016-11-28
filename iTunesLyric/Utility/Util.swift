//
//  Util.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Cocoa

func createRoundRectPath(in rect: CGRect, radius: CGFloat) -> CGPath {
    let mr = min(rect.height, rect.width)
    let radius = min(radius, 0.5 * mr)
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    return path
}
