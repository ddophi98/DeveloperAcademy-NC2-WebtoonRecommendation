//
//  DetailView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/25.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    @Environment(\.presentationMode) var presentationMode
    @State var isAllStroyShown = false
    @State var canBeLonger = false
    let curWebtoon: Webtoon
    
    init(webtoon: Webtoon) {
        self.curWebtoon = webtoon
    }
    
    var body: some View {
        VStack(spacing: 0) {
            getBackBarView()
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.mainText)
                    .frame(height: GlobalVar.lineWidth)
                ScrollView {
                    VStack(spacing: 0) {
                        getWebtoonInfoView()
                        getSimilarWebtoonsView()
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .background(Color.background)
    }
    
    // 비슷한 웹툰들 보여주는 뷰
    @ViewBuilder
    func getSimilarWebtoonsView() -> some View {
        HStack {
            Text("비슷한 웹툰들")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.mainText)
            Spacer()
        }
        .frame(height: 36)
        .padding(.horizontal, 8)
        getClusterGroup(title: "장르가 같은 웹툰", clusterBy: "genre")
        getClusterGroup(title: "스토리가 비슷한 웹툰", clusterBy: "story")
        getClusterGroup(title: "그림체가 비슷한 웹툰", clusterBy: "style")
    }
    
    // 백버튼 있는 커스텀 네비게이션 바
    @ViewBuilder
    func getBackBarView() -> some View {
        
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.mainText)
                    .font(.system(size: 20))
            }
            Spacer()
        }
        .padding(15)
        .background(Color.background)
        .frame(height: 46)
        .padding(.bottom, 10)
        
        
    }
    
    // 웹툰의 각종 정보들을 보여주는 뷰
    @ViewBuilder
    func getWebtoonInfoView() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.mainText)
                .frame(height: GlobalVar.lineWidth)
            getOtherInfoView()
            Rectangle()
                .fill(Color.mainText)
                .frame(height: GlobalVar.lineWidth)
            getStoryInfoView()
            Rectangle()
                .fill(Color.mainText)
                .frame(height: GlobalVar.lineWidth)
        }
    }
    
    // 스토리를 제외한 나머지 정보들을 보여주는 뷰
    @ViewBuilder
    func getOtherInfoView() -> some View {
        HStack(alignment: .top, spacing: 0) {
            Image(uiImage:
                    UIImage(data: curWebtoon.thumbnail) ??
                  UIImage(named: "no_image")!
            )
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 129, alignment: .top)
            .clipped()
            Rectangle()
                .fill(Color.mainText)
                .frame(width: GlobalVar.lineWidth)
            HStack(alignment: .top) {
                getTextInfoView()
                Spacer()
                Image(curWebtoon.platform == Platform.Naver.string ? "naver_logo" : "kakao_logo")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .cornerRadius(7)
            }
            .padding(8)
        }
        .frame(height: 129)
    }
    
    // 글자로 써져있는 정보들을 보여주는 뷰
    @ViewBuilder
    func getTextInfoView() -> some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text(curWebtoon.title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.mainText)
                .padding(.bottom, 8)
            Text(curWebtoon.author)
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(.subText)
            Text("\(curWebtoon.genre) | \(curWebtoon.day) 연재")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(.subText)
            Spacer()
            Button {
                openUrl(link: curWebtoon.url)
            } label: {
                HStack(spacing: 4) {
                    Text("웹툰 보러 가기")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.highlighted)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.highlighted)
                }
            }
        }
    }
    
    // 스토리를 보여주는 뷰
    @ViewBuilder
    func getStoryInfoView() -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("스토리")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.mainText)
                    HStack(alignment: .bottom) {
                        ZStack(alignment: .top) {
                            if !canBeLonger {
                                Text(curWebtoon.story)
                                    .font(.system(size: 13, weight: .heavy))
                                    .lineLimit(nil)
                                    .overlay(
                                        GeometryReader { proxy in
                                            determineViewSpread(height: proxy.size.height)
                                        }
                                    )
                            }
                            Text(curWebtoon.story)
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.subText)
                                .lineLimit(canBeLonger ? (isAllStroyShown ? nil : 3) : nil)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        if canBeLonger {
                            Image(systemName: isAllStroyShown ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.subText)
                                .padding(.bottom, 4)
                        }
                    }
                }
            }
            .padding(8)
            .onTapGesture {
                isAllStroyShown.toggle()
            }
        }
    }
    
    // 테이블 셀로 이루어진 특정 클러스터 그룹
    @ViewBuilder
    func getClusterGroup(title: String, clusterBy: String) -> some View {
        Rectangle()
            .fill(Color.mainText)
            .frame(height: GlobalVar.lineWidth)
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.subText)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.flexible())], spacing: 22) {
                        switch clusterBy {
                        case "genre":
                            ForEach(webtoonData.webtoons.indices, id: \.self) { index in
                                if webtoonData.webtoons[index].genre == curWebtoon.genre && curWebtoon.id != index {
                                    getCell(idx: index)
                                }
                            }
                        case "story":
                            ForEach(webtoonData.storyCluster[curWebtoon.genre]![curWebtoon.clusterByStory2], id: \.self) { index in
                                if curWebtoon.id != index {
                                    getCell(idx: index)
                                }
                            }
                        case "style":
                            ForEach(webtoonData.styleCluster[curWebtoon.clusterByStyle], id: \.self) { index in
                                if curWebtoon.id != index {
                                    getCell(idx: index)
                                }
                            }
                        default:
                            Text("존재하지 않습니다")
                        }
                    }
                }
                .frame(height: 102)
                Spacer()
            }
            .frame(height: 150)
            .padding(.horizontal, 6)
            .padding(.top, 12)
        }
    }
    
    // 테이블 셀
    @ViewBuilder
    func getCell(idx: Int) -> some View {
        NavigationLink(destination: DetailView(webtoon: webtoonData.webtoons[idx]).environmentObject(webtoonData)) {
            VStack {
                Image(uiImage:
                        UIImage(data: webtoonData.webtoons[idx].thumbnail) ??
                      UIImage(named: "no_image")!
                )
                .resizable()
                .scaledToFill()
                .frame(width: 81, height: 81, alignment: .top)
                .clipped()
                .cornerRadius(5)
                HStack{
                    Text(webtoonData.webtoons[idx].title)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.mainText)
                        .lineLimit(1)
                    Spacer()
                    Image(webtoonData.webtoons[idx].platform == Platform.Naver.string ? "naver_logo" : "kakao_logo")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .cornerRadius(3)
                }
            }
            .frame(width: 81, height: 102)
        }
    }
    
    // 해당 웹툰 url 열어주기
    func openUrl(link: String) {
        guard let url = URL(string: link), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // 스토리 나오는 뷰 높이 계산해서 펼치기 넣을지 결정하기
    func determineViewSpread(height: CGFloat) -> some View {
        return Text("")
            .opacity(0)
            .onAppear {
                if height > 48 {
                    canBeLonger = true
                }
            }
    }
}
