//
//  ContentView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/16.
//

import SwiftUI

struct ContentView: View {
    @StateObject var webtoonData = WebtoonData()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color.background)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.mainText)
    }
    
    var body: some View {
        TabView {
            GenreView()
                .environmentObject(webtoonData)
                .tabItem {
                    Image(systemName: "square.split.bottomrightquarter")
                    Text("장르")
                }
            StoryView()
                .environmentObject(webtoonData)
                .tabItem {
                    Image(systemName: "doc.plaintext")
                    Text("스토리")
                }
            DrawingStyleView()
                .environmentObject(webtoonData)
                .tabItem {
                    Image(systemName: "pencil.and.outline")
                    Text("그림체")
                }
        }
        .accentColor(Color.highlighted)
        .preferredColorScheme(.dark)
        .onAppear(){
            webtoonData.initInfo()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
