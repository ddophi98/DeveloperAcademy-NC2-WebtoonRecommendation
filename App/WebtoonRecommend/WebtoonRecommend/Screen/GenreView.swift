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
    @State var selectedPlatform: Platform = .All
    @State var isSelectingPlatform: Bool = false
    @State var webtoonCount: Int = GlobalVar.webtoonSize
    
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
        .navigationBarTitle("") 
        .navigationBarHidden(true)
        .background(Color.background)
        .onChange(of: selectedGenre) { _ in
            getWebtoonCount()
        }
        .onChange(of: selectedPlatform) { _ in
            getWebtoonCount()
        }
    }
    
    // 장르 선택
    @ViewBuilder
    func getGenreListView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Genre.allCases, id: \.self) { genre in
                    Button {
                        selectedGenre = genre
                    } label: {
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
                }
            }.frame(height: 46)
        }
        Rectangle()
            .fill(Color.mainText)
            .frame(height: GlobalVar.lineWidth)
    }
    
    // 플랫폼 선택
    @ViewBuilder
    func getPlatformSelectView() -> some View {
        HStack {
            Spacer()
            Button {
                isSelectingPlatform = true
            } label: {
                HStack(spacing: 5) {
                    Text(selectedPlatform.string)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.subText)
                    Text("(\(webtoonCount))")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.subText)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.subText)
                        .padding(.leading, 5)
                }
            }
        }
        .frame(height: 38)
        .padding(.trailing, 9)
        .confirmationDialog(
            "플랫폼을 선택하세요",
            isPresented: $isSelectingPlatform
        ){
            Button("전체") {
                selectedPlatform = .All
            }
            Button("네이버") {
                selectedPlatform = .Naver
            }
            Button("카카오") {
                selectedPlatform = .Kakao
            }
        }
    }
    
    // 해당 조건에 맞는 웹툰들
    @ViewBuilder
    func getContentView() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]
        
        if webtoonCount == 0 {
            Spacer()
            Text("해당 웹툰은 아직 없습니다.")
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal)
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(webtoonData.webtoons.indices, id: \.self) { index in
                        if isGenreSame(index: index) && isPlatformSame(index: index) {
                            getCell(idx: index)
                        }
                    }
                }
            }
        }
    }
    
    // 테이블 셀
    @ViewBuilder
    func getCell(idx: Int) -> some View {
        NavigationLink(destination: DetailView(webtoonIndex: idx)) {
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
    
    // 현재 선택된 장르와 같은지 비교
    func isGenreSame(index: Int) -> Bool {
        if webtoonData.webtoons[index].genre == selectedGenre.string || Genre.All.string == selectedGenre.string {
            return true
        } else {
            return false
        }
    }
    
    // 현재 선택된 플랫폼과 같은지 비교
    func isPlatformSame(index: Int) -> Bool {
        if webtoonData.webtoons[index].platform == selectedPlatform.string || Platform.All.string == selectedPlatform.string {
            return true
        } else {
            return false
        }
    }
    
    // 해당 조건에 맞는 웹툰 개수 계산
    func getWebtoonCount() {
        var cnt = 0
        for idx in webtoonData.webtoons.indices {
            if isGenreSame(index: idx) && isPlatformSame(index: idx) {
                cnt += 1
            }
        }
        webtoonCount = cnt
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
