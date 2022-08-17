//
//  FirebaseTool.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/17.
//

import FirebaseFirestore

class FirebaseTool {
    static let instance = FirebaseTool()
    
    let decoder = JSONDecoder()
    let webtoonRef = Firestore.firestore().collection("clusterInfo")
    let clusterWordRef = Firestore.firestore().collection("clusterTopWords")
    
    // 파이어베이스에서 웹툰 정보 가져오기
    func getWebtoon(completion: @escaping ()->Void ) {
        webtoonRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error in getting documents: \(err)")
                return
            }
            guard let documents = querySnapshot?.documents else {return}
            for document in documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let webtoon = try self.decoder.decode(Webtoon.self, from: jsonData)
                    WebtoonData.instance.webtoons.append(webtoon)
                } catch let err {
                    print("Error in getting documents: \(err)")
                }
            }
            completion()
        }
    }
    
    // 파이어베이스에서 클러스터 단어 가져오기
    func getClusterWord(completion: @escaping ()->Void ) {
        clusterWordRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error in getting documents: \(err)")
                return
            }
            guard let documents = querySnapshot?.documents else {return}
            for document in documents {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let clusterWord = try self.decoder.decode(ClusterWord.self, from: jsonData)
                    WebtoonData.instance.clusterWords.append(clusterWord)
                } catch let err {
                    print("Error in getting documents: \(err)")
                }
            }
            completion()
        }
    }
}
