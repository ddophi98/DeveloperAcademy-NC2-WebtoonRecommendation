//
//  FileTool.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/18.
//

import Foundation

class FileTool {
    private let docsUrl: URL?
    private let fileManager = FileManager.default
    private let webtoonData: WebtoonData
    
    init(webtoonData: WebtoonData) {
        docsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        self.webtoonData = webtoonData
    }
    
    // 파일이 존재하는지 확인하기
    func checkFile(folderName: String, fileName: String) -> Bool {
        print("-- FileTool/checkFile --")
        guard let docsUrl = docsUrl else {
            webtoonData.isError = true
            return false
        }
        let dirUrl = docsUrl.appendingPathComponent(folderName)
        let saveUrl = dirUrl.appendingPathComponent(fileName)
        let result = fileManager.fileExists(atPath: saveUrl.path)
        
        return result
    }
    
    // webtoon 리스트를 json 타입으로 인코딩하기
    func encodeWebtoon(data: [Webtoon]) -> Data? {
        print("-- FileTool/encodeWebtoon --")
        let jsonEncoder = JSONEncoder()
        var encodedData: Data? = nil
        do {
            encodedData = try jsonEncoder.encode(data)
        } catch {
            webtoonData.isError = true
        }
        return encodedData
    }
    
    // ClusterWord 리스트를 json 타입으로 인코딩하기
    func encodeClusterWord(data: [ClusterWord]) -> Data? {
        print("-- FileTool/encodeClusterWord --")
        let jsonEncoder = JSONEncoder()
        var encodedData: Data? = nil
        do {
            encodedData = try jsonEncoder.encode(data)
        } catch {
            webtoonData.isError = true
        }
        return encodedData
    }
    
    // json 데이터를 webtoon 리스트 타입으로 디코딩하기
    func decodeWebtoon(data: Data?) -> [Webtoon]? {
        print("-- FileTool/decodeWebtoon --")
        guard let data = data else {
            return nil
        }
        let jsonDecoder = JSONDecoder()
        var decodedData: [Webtoon]? = nil
        do {
            decodedData = try jsonDecoder.decode([Webtoon].self, from: data)
        } catch {
            webtoonData.isError = true
        }
        return decodedData
    }
    
    // json 데이터를 clusterWord 리스트 타입으로 디코딩하기
    func decodeClusterWord(data: Data?) -> [ClusterWord]? {
        print("-- FileTool/decodeClusterWord --")
        guard let data = data else {
            return nil
        }
        let jsonDecoder = JSONDecoder()
        var decodedData: [ClusterWord]? = nil
        do {
            decodedData = try jsonDecoder.decode([ClusterWord].self, from: data)
        } catch {
            webtoonData.isError = true
        }
        return decodedData
    }
    
    // 앱 내부 저장소에 파일 저장하기
    func writeFile(data: Data?, folderName: String, fileName: String) {
        print("-- FileTool/writeFile \(fileName) --")
        guard let docsUrl = docsUrl,
              let data = data else { return }
        let dirUrl = docsUrl.appendingPathComponent(folderName)
        let saveUrl = dirUrl.appendingPathComponent(fileName)
        
        do {
            try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true)
            try data.write(to: saveUrl, options: .atomic)
        } catch {
            webtoonData.isError = true
        }
    }
    
    // 앱 내부 저장소에서 파일 불러오기
    func loadFile(folderName: String, fileName: String) -> Data? {
        print("-- FileTool/loadFile \(fileName) --")
        guard let docsUrl = docsUrl else { return nil }
        let dirUrl = docsUrl.appendingPathComponent(folderName)
        let saveUrl = dirUrl.appendingPathComponent(fileName)
        
        var data: Data? = nil
        do {
            data = try Data.init(contentsOf: saveUrl)
        } catch {
            webtoonData.isError = true
        }
        return data
    }
    
    
}
