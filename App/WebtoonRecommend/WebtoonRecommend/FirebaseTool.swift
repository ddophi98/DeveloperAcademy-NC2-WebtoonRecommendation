//
//  FirebaseTool.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/17.
//

import FirebaseFirestore
import FirebaseStorage

class FirebaseTool {
    static let instance = FirebaseTool()
    
    private let decoder = JSONDecoder()
    private let webtoonRef = Firestore.firestore().collection("webtoonInfo")
    private let clusterWordRef = Firestore.firestore().collection("clusterWord")
    private let storagePath = "gs://webtoonrecommendation.appspot.com/thumbnails/"
    private let storage = Storage.storage()
    private var size = -1
    
    // 웹툰 정보 및 썸네일 사진 저장하기
    func saveWebtoonAndImage(completion: @escaping ()->Void) {
        getWebtoon() { (isError1, webtoonArr) in
            if !isError1 {
                self.getThumbnail() { (isError2, thumbnailArr) in
                    for (webtoon, thumbnail) in zip(webtoonArr, thumbnailArr) {
                        WebtoonData.instance.addWebtoon(jsonData: webtoon, thumbnail: thumbnail)
                    }
                    print(isError2)
                    print(webtoonArr.count)
                    print(thumbnailArr.count)
                    print("wow!!")
                    completion()
                }
            }
        }
    }
    
    // 클러스터 단어 저장하기
    func saveClusterWord(completion: @escaping ()->Void) {
        getClusterWord() { (isError, clusterWordArr) in
            if !isError {
                for clusterWord in clusterWordArr {
                    WebtoonData.instance.addClusterWords(jsonData: clusterWord)
                }
                completion()
            }
        }
    }
    
    // 파이어베이스에서 웹툰 정보 가져오기
    private func getWebtoon(completion: @escaping (Bool, [WebtoonJson])->Void ) {
        var webtoonJsonArr = [WebtoonJson]()
        var isError = false
        
        webtoonRef.getDocuments() { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("Error in getting documents: \(err!)")
                isError = true
                completion(isError, webtoonJsonArr)
                return
            }
            
            self.size = documents.count
            for document in documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let webtoonJson = try self.decoder.decode(WebtoonJson.self, from: jsonData)
                    webtoonJsonArr.append(webtoonJson)
                } catch let err {
                    print("Error in getting documents: \(err)")
                }
            }
            completion(isError, webtoonJsonArr)
        }
    }
    
    // 파이어베이스에서 썸네일 사진 가져오기
    private func getThumbnail(completion: @escaping (Bool, [Data?])->Void ) {
        var imageArr = [Data?]()
        var isError = false
        
        for idx in 0..<size {
            let filePath = storagePath + "thumbnail" + String(idx) + ".jpg"
            storage.reference(forURL: filePath).getData(maxSize: 1 * 512 * 512) { data, err in
                guard let data = data else {
                    print("Error in getting images: \(err!)")
                    isError = true
                    imageArr.append(nil)
                    return
                }
                imageArr.append(data)
                print(idx)
                if idx == self.size-1 {
                    completion(isError, imageArr)
                }
            }
        }
    }
    
    // 파이어베이스에서 클러스터 단어 가져오기
    private func getClusterWord(completion: @escaping (Bool, [ClusterWordJson])->Void ) {
        var clusterWordArr = [ClusterWordJson]()
        var isError = false
        
        clusterWordRef.getDocuments() { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("Error in getting documents: \(err!)")
                isError = true
                completion(isError, clusterWordArr)
                return
            }
            for document in documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let clusterWordJson = try self.decoder.decode(ClusterWordJson.self, from: jsonData)
                    clusterWordArr.append(clusterWordJson)
                } catch let err {
                    print("Error in getting documents: \(err)")
                    isError = true
                    completion(isError, clusterWordArr)
                }
            }
            completion(isError, clusterWordArr)
        }
    }
}
