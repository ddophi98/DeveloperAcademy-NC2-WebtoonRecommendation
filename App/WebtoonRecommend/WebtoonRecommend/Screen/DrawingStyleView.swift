//
//  DrawingStyleView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI

struct DrawingStyleView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    @State var isViewLoadingFinish = false
    
    init() {
        print("-- DrawingStyleView init!! --")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "그림체")
            if webtoonData.isFinishSavingAll {
                if isViewLoadingFinish {
                    getContentView()
                } else {
                    LoadingView()
                }
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
        .onLoad {
            print("-- StoryView load!! --")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isViewLoadingFinish = true
            }
        }
    }
    
    // 전체 웹툰에서 그림체로 묶은 각각의 클러스터 그룹
    @ViewBuilder
    func getContentView() -> some View {
        ScrollView {
            VStack {
                ForEach(webtoonData.styleCluster.indices, id: \.self) { index in
                    getClusterGroup(groupIdx: index)
                }
            }
        }
    }
    
    // 테이블 셀로 이루어진 특정 클러스터 그룹
    @ViewBuilder
    func getClusterGroup(groupIdx: Int) -> some View {
        VStack {
            VStack(alignment: .leading) {
                Text("그림체\(groupIdx+1)")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.subText)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 22) {
                        ForEach(webtoonData.styleCluster[groupIdx], id: \.self) { index in
                            getCell(idx: index)
                        }
                    }
                }
            }
            .frame(height: 150)
            .padding(.horizontal, 6)
            if groupIdx != webtoonData.styleCluster.count - 1 {
                Rectangle()
                    .fill(Color.mainText)
                    .frame(height: GlobalVar.lineWidth)
            }
        }
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
}

struct DrawingStyleView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingStyleView()
    }
}
