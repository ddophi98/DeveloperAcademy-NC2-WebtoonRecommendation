//
//  ContentView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/16.
//

import SwiftUI

struct ContentView: View {
    init() {
        FirebaseTool.instance.getWebtoon {
            let webtoons = WebtoonData.instance.webtoons
            print(webtoons[0].title)
        }
        FirebaseTool.instance.getClusterWord {
            let clusterWords = WebtoonData.instance.clusterWords
            print(clusterWords[3].words)
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
