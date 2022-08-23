//
//  GenreView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI

struct GenreView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    @State var selectedGenre: Genre = .All
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "장르")
            if webtoonData.isFinishSavingAll {
                getGenreListView()
                getPlatformSelectView()
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
    
    // 장르 선택
    @ViewBuilder
    func getGenreListView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(Genre.allCases, id: \.self) { genre in
                    VStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 2)
                        Text(genre.string)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(genre == selectedGenre ? .highlighted : .mainText)
                            .padding(.horizontal, 15)
                        Rectangle()
                            .fill(genre == selectedGenre ? Color.highlighted : Color.clear)
                            .frame(height: 2)
                            .padding(.horizontal, 4)
                    }
                }
            }.frame(height: 46)
        }
        Rectangle()
            .fill(Color.mainText)
            .frame(height: 1)
    }
    
    // 플랫폼 선택
    @ViewBuilder
    func getPlatformSelectView() -> some View {
        HStack {
            Spacer()
            Text("전체")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.subText)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(.subText)
        }
        .frame(height: 38)
        .padding(.trailing, 9)
    }
    
    // 해당 조건에 맞는 웹툰들
    @ViewBuilder
    func getContentView() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(webtoonData.webtoons.indices, id: \.self) { index in
                    getCell(idx: index)
                }
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
            .frame(width: GlobalVar.screenW / 3, height: 105, alignment: .top)
            .clipped()
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(webtoonData.webtoons[idx].title)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.mainText)
                        .lineLimit(1)
                    Text(webtoonData.webtoons[idx].author)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.subText)
                        .lineLimit(1)
                }
                Spacer()
                Image(webtoonData.webtoons[idx].platform == "네이버웹툰" ? "naver_logo" : "kakao_logo")
                    .resizable()
                    .frame(width: 19, height: 19)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 5)
        }
        .frame(width: GlobalVar.screenW / 3, height: 155)
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
