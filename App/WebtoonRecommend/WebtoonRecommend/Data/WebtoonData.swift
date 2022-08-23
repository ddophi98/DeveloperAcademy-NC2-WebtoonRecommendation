//
//  WebtoonData.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/17.
//

import SwiftUI

class WebtoonData: ObservableObject {
    var webtoons = [Webtoon]()
    var clusterWords = [ClusterWord]()
    private var isFinishSavingWebtoonAndImage = false
    private var isFinishSavingClusterWord = false
    
    @Published var isError = false
    @Published var isImageExist = true
    @Published var isFinishSavingAll = false
    @Published var progress = 0
    
    // 웹툰 정보 가져오기
    func initInfo() {
        print("-- WebtoonData/initInfo --")
        let firebaseTool = FirebaseTool(webtoonData: self)
        let fileTool = FileTool(webtoonData: self)
        initVariable()
        
        // 앱 내부 저장소에 웹툰 데이터가 없다면 (JSON + 이미지 파일 가져오는거라서 느리게 끝남)
        if !fileTool.checkFile(folderName: GlobalVar.folderName, fileName: GlobalVar.webtoonJsonName) {
            isImageExist = false
            getWebtoonFromFirebase(firebaseTool: firebaseTool, fileTool: fileTool)
        } else {
            // 의도적으로 딜레이 주기
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.getWebtoonFromStorage(fileTool: fileTool)
            }
        }
        
        // 앱 내부 저장소에 단어 데이터가 없다면 (JSON 파일 가져오는거라서 빠르게 끝남)
        if !fileTool.checkFile(folderName: GlobalVar.folderName, fileName: GlobalVar.clusterWordJsonName) {
            getClusterWordFromFirebase(firebaseTool: firebaseTool, fileTool: fileTool)
        } else {
            getClusterWordFromStorage(fileTool: fileTool)
        }
    }
    
    // 변수들 초기화히기
    private func initVariable() {
        webtoons = [Webtoon]()
        clusterWords = [ClusterWord]()
        isFinishSavingWebtoonAndImage = false
        isFinishSavingClusterWord = false
        isError = false
        isImageExist = true
        isFinishSavingAll = false
        progress = 0
    }
    
    // 모든 작업이 끝났는지 체크하기
    private func setFinish() {
        print("-- WebtoonData/setFinish --")
        if self.isFinishSavingWebtoonAndImage && self.isFinishSavingClusterWord {
            DispatchQueue.main.async {
                self.isFinishSavingAll = true
            }
            print("-- All Loading Finish --")
        }
    }
    
    // 파이어베이스에서 웹툰 데이터 가져오기
    private func getWebtoonFromFirebase(firebaseTool: FirebaseTool, fileTool: FileTool) {
        print("-- WebtoonData/getWebtoonFromFirebase --")
        firebaseTool.saveWebtoonAndImage {
            // 그리고 앱 내부에 데이터 저장하기
            let encodedData = fileTool.encodeWebtoon(data: self.webtoons)
            fileTool.writeFile(data: encodedData, folderName: GlobalVar.folderName, fileName: GlobalVar.webtoonJsonName)
            self.isFinishSavingWebtoonAndImage = true
            self.setFinish()
        }
    }
    
    // 앱 내부 저장소에서 웹툰 데이터 꺼내오기
    private func getWebtoonFromStorage(fileTool: FileTool) {
        print("-- WebtoonData/getWebtoonFromStorage --")
        let jsonData = fileTool.loadFile(folderName: GlobalVar.folderName, fileName: GlobalVar.webtoonJsonName)
        guard let decodedData = fileTool.decodeWebtoon(data: jsonData) else {
            isError = true
            return
        }
        self.webtoons = decodedData
        
        self.isFinishSavingWebtoonAndImage = true
        setFinish()
    }
    
    // 파이어베이스에서 단어 데이터 가져오기
    private func getClusterWordFromFirebase(firebaseTool: FirebaseTool, fileTool: FileTool) {
        print("-- WebtoonData/getClusterWordFromFirebase --")
        firebaseTool.saveClusterWord {
            // 그리고 앱 내부에 데이터 저장하기
            let encodedData = fileTool.encodeClusterWord(data: self.clusterWords)
            fileTool.writeFile(data: encodedData, folderName: GlobalVar.folderName, fileName: GlobalVar.clusterWordJsonName)
            
            self.isFinishSavingClusterWord = true
            self.setFinish()
        }
    }
    
    // 앱 내부 저장소에서 단어 데이터 꺼내오기
    private func getClusterWordFromStorage(fileTool: FileTool) {
        print("-- WebtoonData/getClusterWordFromStorage --")
        let jsonData = fileTool.loadFile(folderName: GlobalVar.folderName, fileName: GlobalVar.clusterWordJsonName)
        guard let decodedData = fileTool.decodeClusterWord(data: jsonData) else {
            isError = true
            return
        }
        self.clusterWords = decodedData
        
        self.isFinishSavingClusterWord = true
        setFinish()
    }
    
    // 웹툰 배열에 추가하기
    func addWebtoon(jsonData: WebtoonJson, thumbnail: Data?){
        var image: Data = UIImage(named: "no_image")!.pngData()!
        
        if thumbnail != nil {
            image = thumbnail!
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
}

struct Webtoon: Codable {
    var id: Int
    var title: String
    var author: String
    var day: String
    var genre: String
    var platform: String
    var story: String
    var thumbnail: Data
    var clusterByStory1: Int
    var clusterByStory2: Int
    var clusterByStyle: Int
}

struct WebtoonJson: Codable {
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

struct ClusterWord: Codable {
    var genre: String
    var clusterNum: Int
    var words: [String]
}

struct ClusterWordJson: Codable {
    var genre: String
    var clusterNum: Int
    var words: String
    
    enum CodingKeys: String, CodingKey {
        case genre = "genre"
        case clusterNum = "cluster_num"
        case words = "words"
    }
}
