//
//  StoryView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI

struct StoryView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "스토리")
            if webtoonData.isFinishSavingAll {
                getContentView()
            } else if webtoonData.isError {
                ErrorView(webtoonData: webtoonData)
            } else {
                if webtoonData.isShortLoading {
                    LoadingView()
                } else {
                    ProgressLoadingView(webtoonData: webtoonData)
                }
            }
        }
        .background(Color.background)
    }
    
    // 전체 웹툰에서 스토리로 묶은 각각의 클러스터 그룹
    @ViewBuilder
    func getContentView() -> some View {
        ScrollView {
            VStack {
                ForEach(webtoonData.clusterWords.indices, id: \.self) { index in
                    if webtoonData.clusterWords[index].genre == Genre.All.string {
                        getClusterGroup(groupIdx: webtoonData.clusterWords[index].clusterNum)
                    }
                }
            }
        }
        
        Spacer()
    }
    
    // 테이블 셀
    @ViewBuilder
    func getCell(idx: Int) -> some View {
        VStack {
            Image(uiImage:
                    UIImage(data: webtoonData.webtoons[idx].thumbnail) ??
                    UIImage(named: "no_image")!
            )
            .resizable()
            .scaledToFill()
            .frame(width: 81, height: 81, alignment: .top)
            .clipped()
            HStack{
                Text(webtoonData.webtoons[idx].title)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.mainText)
                    .lineLimit(1)
                Spacer()
                Image(webtoonData.webtoons[idx].platform == "네이버웹툰" ? "naver_logo" : "kakao_logo")
                    .resizable()
                    .frame(width: 13, height: 13)
            }
        }
        .frame(width: 81, height: 102)
    }
    
    // 테이블 셀로 이루어진 특정 클러스터 그룹
    @ViewBuilder
    func getClusterGroup(groupIdx: Int) -> some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    ForEach(webtoonData.clusterWords[groupIdx].words, id: \.self) { word in
                        Text(word)
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.subText)
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 22) {
                        ForEach(webtoonData.webtoons.indices, id: \.self) { index in
                            if webtoonData.webtoons[index].clusterByStory1 == groupIdx {
                                getCell(idx: index)
                            }
                        }
                    }
                }
            }
            .frame(height: 150)
            .padding(.horizontal, 6)
            Rectangle()
                .fill(Color.mainText)
                .frame(height: GlobalVar.lineWidth)
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
