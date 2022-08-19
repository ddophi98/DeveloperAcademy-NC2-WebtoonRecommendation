//
//  ColorExtension.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI
 
extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}

extension Color {
    static let background = Color(hex: "2B2B2B")
    static let highlighted = Color(hex: "FBFD76")
    static let mainText = Color(hex: "FFFFFF")
    static let subText = Color(hex: "9F9F9F")
}
