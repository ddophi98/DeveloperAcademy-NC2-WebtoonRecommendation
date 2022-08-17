//
//  ContentView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/16.
//

import SwiftUI

struct ContentView: View {
    @StateObject var webtoonData = WebtoonData()
    
    var body: some View {
        VStack {
            if  webtoonData.isFinishSavingAll {
                Text("Finish!")
                    .padding()
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
