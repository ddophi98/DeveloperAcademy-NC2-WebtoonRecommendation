//
//  ContentView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/16.
//

import SwiftUI

struct ContentView: View {
    @StateObject var webtoonData = WebtoonData()
    let idx = 10
    
    var body: some View {
        VStack {
            if  webtoonData.isFinishSavingAll {
                Text("Finish!")
                    .padding()
                Image(uiImage: UIImage(data: webtoonData.getWebtoon()[idx].thumbnail)!)
                Text("\(webtoonData.getWebtoon()[idx].title)")
                Text("\(webtoonData.getWebtoon()[idx].story)")
                Text("\(webtoonData.getClusterWords()[0].words[0])")
            }else{
                Text("Not yet")
                    .padding()
            }
        }.onAppear(){
            webtoonData.initInfo()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
