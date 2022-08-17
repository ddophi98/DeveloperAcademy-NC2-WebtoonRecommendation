//
//  WebtoonData.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/17.
//

class WebtoonData {
    static let instance = WebtoonData()
    
    var webtoons = [Webtoon]()
    var clusterWords = [ClusterWord]()
}

struct Webtoon: Decodable {
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

struct ClusterWord: Decodable {
    var genre: String
    var clusterNum: Int
    var words: String
    
    enum CodingKeys: String, CodingKey {
        case genre = "genre"
        case clusterNum = "cluster_num"
        case words = "words"
    }
}
