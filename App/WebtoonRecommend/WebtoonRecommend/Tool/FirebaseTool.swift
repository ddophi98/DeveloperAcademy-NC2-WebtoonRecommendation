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
        getWebtoon() { (isError1, webtoonArr) in
            if !isError1 {
                self.getThumbnail() { (isError2, thumbnailArr) in
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
    }
    
    // 클러스터 단어 저장하기
    func saveClusterWord(completion: @escaping ()->Void) {
        print("-- FirebaseTool/saveClusterWord --")
        getClusterWord() { (isError, clusterWordArr) in
            if !isError {
                print("-- FirebaseTool/addClusterWords in for block --")
                for clusterWord in clusterWordArr {
                    self.webtoonData.addClusterWords(jsonData: clusterWord)
                }
                completion()
            }
        }
    }
    
    // 파이어베이스에서 웹툰 정보 가져오기
    private func getWebtoon(completion: @escaping (Bool, [WebtoonJson])->Void ) {
        print("-- FirebaseTool/getWebtoon --")
        var webtoonJsonArr = [WebtoonJson]()
        var isError = false
        
        webtoonRef.getDocuments() { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("Error in getting documents: \(err!)")
                isError = true
                completion(isError, webtoonJsonArr)
                return
            }
            
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
        print("-- FirebaseTool/getThumbnail --")
        var imageArr: [Data?] = Array(repeating: nil, count: GlobalVar.webtoonSize)
        var isError = false
        
        for idx in 0..<GlobalVar.webtoonSize {
            let filePath = storagePath + GlobalVar.imageFileName + String(idx) + GlobalVar.imageFileType
            storage.reference(forURL: filePath).getData(maxSize: 1 * 512 * 512) { data, err in
                guard let data = data else {
                    print("Error in getting images\(idx): \(err!)")
                    isError = true
                    return
                }
                imageArr[idx] = data
                let nilCnt = imageArr.filter({($0) == nil}).count
                self.webtoonData.progress = GlobalVar.webtoonSize - nilCnt
                if nilCnt == 0 {
                    completion(isError, imageArr)
                }
            }
        }
    }
    
    // 파이어베이스에서 클러스터 단어 가져오기
    private func getClusterWord(completion: @escaping (Bool, [ClusterWordJson])->Void ) {
        print("-- FirebaseTool/getClusterWord --")
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
