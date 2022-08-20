//
//  GenreView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI

struct GenreView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    
    var body: some View {
        VStack {
            getHeaderView()
            if webtoonData.isFinishSavingAll {
                getContentView()
            } else {
                getLoadingView()
            }
        }
        .background(Color.mainText)
    }
    
    // 제목과 검색 버튼 있는 헤더
    @ViewBuilder
    func getHeaderView() -> some View {
        HStack {
            Text("장르")
                .foregroundColor(Color.mainText)
                .font(.system(size: 20, weight: .heavy))
            Spacer()
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.mainText)
                .font(.system(size: 20))
        }
        .padding(15)
        .background(Color.background)
    }

    // 로티를 이용한 로딩 애니메이션
    @ViewBuilder
    func getLoadingView() -> some View {
        Spacer()
        LottieView(filename: "Loading")
            .frame(width: 200, height: 200)
        Text(String(webtoonData.progress))
            .padding()
            .background(Color.background)
        Spacer()
    }

    // 원래 보여줘야할 콘텐츠
    @ViewBuilder
    func getContentView() -> some View {
        Text("finish!")
            .padding()
            .background(Color.background)
        Spacer()
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
