//
//  File.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/18.
//

import UIKit

class GlobalVar {
    static let webtoonSize = 1788
    static let imageFileName = "thumbnail"
    static let imageFileType = ".jpg"
    static let folderName = "Json"
    static let webtoonJsonName = "webtoons.json"
    static let clusterWordJsonName = "clusterWords.json"
    static let screenW = UIScreen.main.bounds.width
    static let screenH = UIScreen.main.bounds.height
    static let lineWidth: CGFloat = 1
}

enum Platform: CaseIterable {
    case All, Naver, Kakao
    var string: String {
        switch self {
        case .All:
            return "전체"
        case .Naver:
            return "네이버웹툰"
        case .Kakao:
            return "카카오웹툰"
        }
    }
}

enum Genre: CaseIterable {
    case All, Action, Daily, Romance, Drama, Thriller, Youth, Fantasy, Emotion, BL, Sport, Chivalry, RoFan, Comic
    var string: String {
        switch self {
        case .All:
            return "전체"
        case .Action:
            return "액션"
        case .Daily:
            return "일상"
        case .Romance:
            return "로맨스"
        case .Drama:
            return "드라마"
        case .Thriller:
            return "스릴러"
        case .Youth:
            return "소년"
        case .Fantasy:
            return "판타지"
        case .Emotion:
            return "감성"
        case .BL:
            return "BL"
        case .Sport:
            return "스포츠"
        case .Chivalry:
            return "무협"
        case .RoFan:
            return "로판"
        case .Comic:
            return "개그"
        }
    }
}


