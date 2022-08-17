//
//  ContentView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/16.
//

import SwiftUI

struct ContentView: View {
    var isFinishSavingWebtoonAndImage: Bool
    var isFinishSavingClusterWord: Bool
    
    init() {
        isFinishSavingWebtoonAndImage = false
        isFinishSavingClusterWord = false
        
        FirebaseTool.instance.saveWebtoonAndImage {
            print(WebtoonData.instance.getWebtoon()[0].title)
        }
        FirebaseTool.instance.saveClusterWord {
            isFinishSavingClusterWord = true
            print(WebtoonData.instance.getClusterWords()[0].words[0])
        }
    }
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
