//
//  StringExtension.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/28.
//

extension String {
    func slice(start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: end)
        let sliced_str = self[startIndex ..< endIndex]
        return String(sliced_str)
    }
}
