//
//  WebtoonData.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/17.
//

import SwiftUI

class WebtoonData: ObservableObject {
    private var webtoons = [Webtoon]()
    private var clusterWords = [ClusterWord]()
    private var isFinishSavingWebtoonAndImage = false
    private var isFinishSavingClusterWord = false
    
    @Published var isFinishSavingAll = false
    
    // 웹툰 정보 가져오기
    func initInfo() {
        let firebaseTool = FirebaseTool(webtoonData: self)
        
        firebaseTool.saveWebtoonAndImage {
            self.isFinishSavingWebtoonAndImage = true
//            print(WebtoonData.instance.getWebtoon()[0].title)
            if self.isFinishSavingClusterWord {
                self.isFinishSavingAll = true
            }
        }
        firebaseTool.saveClusterWord {
            self.isFinishSavingClusterWord = true
//            print(WebtoonData.instance.getClusterWords()[0].words[0])
            if self.isFinishSavingWebtoonAndImage {
                self.isFinishSavingAll = true
            }
        }
    }
    
    // 웹툰 배열에 추가하기
    func addWebtoon(jsonData: WebtoonJson, thumbnail: Data?){
        var image: UIImage
        
        if thumbnail == nil {
            image = UIImage(named: "no_image")!
        } else {
            if UIImage(data: thumbnail!) == nil {
                image = UIImage(named: "no_image")!
            } else {
                image = UIImage(data: thumbnail!)!
            }
        }

        let newWebtoon = Webtoon(
            id: jsonData.id,
            title: jsonData.title,
            author: jsonData.author,
            day: jsonData.day,
            genre: jsonData.genre,
            platform: jsonData.platform,
            story: jsonData.story,
            thumbnail: image,
            clusterByStory1: jsonData.clusterByStory1,
            clusterByStory2: jsonData.clusterByStory2,
            clusterByStyle: jsonData.clusterByStyle
        )
        self.webtoons.append(newWebtoon)
    }
    
    // 웹툰 배열 가져오기
    func getWebtoon() -> [Webtoon] {
        return webtoons
    }
    
    // 단어 배열에 추가하기
    func addClusterWords(jsonData: ClusterWordJson) {
        let wordGroup = jsonData.words
        let startIndex = wordGroup.index(wordGroup.startIndex, offsetBy: 1)// 사용자지정 시작인덱스
        let endIndex = wordGroup.index(wordGroup.startIndex, offsetBy: wordGroup.count-1)// 사용자지정 끝인덱스
        let sliced_str = wordGroup[startIndex ..< endIndex]
        let words = sliced_str.components(separatedBy: ", ")
        
        let newClusterWords = ClusterWord(
            genre: jsonData.genre,
            clusterNum: jsonData.clusterNum,
            words: words
        )
        self.clusterWords.append(newClusterWords)
    }
    
    // 단어 배열 가져오기
    func getClusterWords() -> [ClusterWord] {
        return clusterWords
    }
}

struct Webtoon {
    var id: Int
    var title: String
    var author: String
    var day: String
    var genre: String
    var platform: String
    var story: String
    var thumbnail: UIImage
    var clusterByStory1: Int
    var clusterByStory2: Int
    var clusterByStyle: Int
}

struct WebtoonJson: Decodable {
    var id: Int
    var title: String
    var author: String
    var day: String
    var genre: String
    var platform: String
    var story: String
    var thumbnailUrl: String
    var clusterByStory1: Int
    var clusterByStory2: Int
    var clusterByStyle: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case author = "author"
        case day = "day"
        case genre = "genre"
        case platform = "platform"
        case story = "story"
        case thumbnailUrl = "thumbnail"
        case clusterByStory1 = "cluster_story1"
        case clusterByStory2 = "cluster_story2"
        case clusterByStyle = "cluster_style"
    }
}

struct ClusterWord {
    var genre: String
    var clusterNum: Int
    var words: [String]
}

struct ClusterWordJson: Decodable {
    var genre: String
    var clusterNum: Int
    var words: String
    
    enum CodingKeys: String, CodingKey {
        case genre = "genre"
        case clusterNum = "cluster_num"
        case words = "words"
    }
}
