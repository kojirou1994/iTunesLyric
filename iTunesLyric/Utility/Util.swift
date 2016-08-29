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
    let innerRect = CGRect()
    let path = CGMutablePath()
    
    path.move(to: CGPoint(x: innerRect.minX - radius, y: innerRect.minY))
    
    path.addArc(center: CGPoint(x: innerRect.minX, y: innerRect.minY), radius: radius, startAngle: CGFloat.pi, endAngle: 3 * CGFloat.pi / 2, clockwise: false)
    path.addArc(center: CGPoint(x: innerRect.maxX, y: innerRect.minY), radius: radius, startAngle: 3 * CGFloat.pi / 2, endAngle: 0, clockwise: false)
    path.addArc(center: CGPoint(x: innerRect.maxX, y: innerRect.maxY), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: false)
    path.addArc(center: CGPoint(x: innerRect.minX, y: innerRect.maxY), radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: false)

    path.closeSubpath()

    return path
}
