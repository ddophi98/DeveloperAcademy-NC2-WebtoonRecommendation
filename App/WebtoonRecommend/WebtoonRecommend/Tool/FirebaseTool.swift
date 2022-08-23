//
//  FirebaseTool.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/17.
//

import FirebaseFirestore
import FirebaseStorage

class FirebaseTool {
    private let decoder = JSONDecoder()
    private let webtoonRef = Firestore.firestore().collection("webtoonInfo")
    private let clusterWordRef = Firestore.firestore().collection("clusterWord")
    private let storagePath = "gs://webtoonrecommendation.appspot.com/thumbnails/"
    private let storage = Storage.storage()
    private let webtoonData: WebtoonData
    
    init(webtoonData: WebtoonData) {
        self.webtoonData = webtoonData
    }
    
    // 웹툰 정보 및 썸네일 사진 저장하기
    func saveWebtoonAndImage(completion: @escaping ()->Void) {
        print("-- FirebaseTool/saveWebtoonAndImage --")
        getWebtoon() { [weak self] webtoonArr in
            guard let self = self else {return}
            self.getThumbnail() { [weak self] thumbnailArr in
                guard let self = self else {return}
                DispatchQueue.global().async {
                    print("-- FirebaseTool/addWebtoon in for block --")
                    for (webtoon, thumbnail) in zip(webtoonArr, thumbnailArr) {
                        self.webtoonData.addWebtoon(jsonData: webtoon, thumbnail: thumbnail)
                        DispatchQueue.main.async {
                            self.webtoonData.progress += 1
                        }
                    }
                    completion()
                }
            }
        }
    }
    
    // 클러스터 단어 저장하기
    func saveClusterWord(completion: @escaping ()->Void) {
        print("-- FirebaseTool/saveClusterWord --")
        getClusterWord() { [weak self] clusterWordArr in
            guard let self = self else {return}
            print("-- FirebaseTool/addClusterWords in for block --")
            for clusterWord in clusterWordArr {
                self.webtoonData.addClusterWords(jsonData: clusterWord)
            }
            completion()
            
        }
    }
    
    // 파이어베이스에서 웹툰 정보 가져오기
    private func getWebtoon(completion: @escaping ([WebtoonJson])->Void ) {
        print("-- FirebaseTool/getWebtoon --")
        var webtoonJsonArr = [WebtoonJson]()
        
        webtoonRef.getDocuments() { [weak self] (querySnapshot, err) in
            guard let self = self else {return}
            guard let documents = querySnapshot?.documents else {
                self.webtoonData.isError = true
                return
            }
            for document in documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let webtoonJson = try self.decoder.decode(WebtoonJson.self, from: jsonData)
                    webtoonJsonArr.append(webtoonJson)
                } catch {
                    self.webtoonData.isError = true
                    return
                }
            }
            completion(webtoonJsonArr)
        }
    }
    
    // 파이어베이스에서 썸네일 사진 가져오기
    private func getThumbnail(completion: @escaping ([Data?])->Void ) {
        print("-- FirebaseTool/getThumbnail --")
        var imageArr: [Data?] = Array(repeating: nil, count: GlobalVar.webtoonSize)
        
        for idx in 0..<GlobalVar.webtoonSize {
            let filePath = storagePath + GlobalVar.imageFileName + String(idx) + GlobalVar.imageFileType
            storage.reference(forURL: filePath).getData(maxSize: 1 * 512 * 512) { [weak self] data, err in
                guard let self = self else {return}
                guard let data = data else {
                    self.webtoonData.isError = true
                    return
                }
                imageArr[idx] = data
                let nilCnt = imageArr.filter({($0) == nil}).count
                self.webtoonData.progress = GlobalVar.webtoonSize - nilCnt
                if nilCnt == 0 {
                    completion(imageArr)
                }
            }
        }
    }
    
    // 파이어베이스에서 클러스터 단어 가져오기
    private func getClusterWord(completion: @escaping ([ClusterWordJson])->Void ) {
        print("-- FirebaseTool/getClusterWord --")
        var clusterWordArr = [ClusterWordJson]()
        
        clusterWordRef.getDocuments() { [weak self] (querySnapshot, err) in
            guard let self = self else {return}
            guard let documents = querySnapshot?.documents else {
                self.webtoonData.isError = true
                return
            }
            for document in documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let clusterWordJson = try self.decoder.decode(ClusterWordJson.self, from: jsonData)
                    clusterWordArr.append(clusterWordJson)
                } catch {
                    self.webtoonData.isError = true
                    return
                }
            }
            completion(clusterWordArr)
        }
    }
}
