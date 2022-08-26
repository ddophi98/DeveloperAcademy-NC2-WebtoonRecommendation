//
//  SearchView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    @Environment(\.presentationMode) var presentationMode
    @FocusState var isFocused: Bool
    @State var searchKeyword = ""
    
    var body: some View {
        VStack(spacing: 0) {
            getSearchView()
                .padding(.bottom, 10)
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 0) {
                        ForEach(filtering(keyword: searchKeyword), id: \.self) { index in
                            getCell(idx: index)
                        }
                        Rectangle()
                            .fill(Color.mainText)
                            .frame(height: GlobalVar.lineWidth)
                    }
                }
                Rectangle()
                    .fill(Color.mainText)
                    .frame(height: GlobalVar.lineWidth)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .background(Color.background)
        
    }
    
    // 검색할 수 있는 뷰
    @ViewBuilder
    func getSearchView() -> some View{
        VStack(spacing: 0) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.mainText)
                        .font(.system(size: 20))
                }
                getInputView()
                    .onTapGesture {
                        isFocused = true
                    }
                Button {
                    isFocused = false
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.mainText)
                        .font(.system(size: 20))
                }
            }
            .padding(15)
            .background(Color.background)
            .frame(height: 46)
        }
    }
    
    // 검색 키워드 입력하는 칸
    @ViewBuilder
    func getInputView() -> some View{
        ZStack(alignment: .leading) {
            TextField("", text: $searchKeyword)
                .foregroundColor(.black)
                .accentColor(.black)
                .font(.system(size: 12))
                .frame(height: 30)
                .padding(.horizontal, 8)
                .padding(.trailing, 25)
                .background(Color.mainText)
                .cornerRadius(5)
                .focused($isFocused)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFocused = true
                    }
                }
            HStack {
                Text("제목, 작가명 검색")
                    .foregroundColor(Color.subText)
                    .font(.system(size: 12))
                    .opacity(searchKeyword.isEmpty ? 1 : 0)
                    .padding(.leading, 2)
                Spacer()
                Button {
                    searchKeyword = ""
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(Color.background)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    @ViewBuilder
    func getCell(idx: Int) -> some View {
        NavigationLink(destination: DetailView(webtoon: webtoonData.webtoons[idx]).environmentObject(webtoonData)) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.mainText)
                    .frame(height: GlobalVar.lineWidth)
                HStack(alignment: .top, spacing: 0) {
                    Image(uiImage:
                            UIImage(data: webtoonData.webtoons[idx].thumbnail) ??
                          UIImage(named: "no_image")!
                    )
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 85, alignment: .top)
                    .clipped()
                    Rectangle()
                        .fill(Color.mainText)
                        .frame(width: GlobalVar.lineWidth)
                    HStack(alignment: .top) {
                        getTextInfoView(curWebtoon: webtoonData.webtoons[idx])
                        Spacer()
                        Image(webtoonData.webtoons[idx].platform == Platform.Naver.string ? "naver_logo" : "kakao_logo")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .padding(8)
                }
                .frame(height: 85)
            }
        }
    }
    
    // 글자로 써져있는 정보들을 보여주는 뷰
    @ViewBuilder
    func getTextInfoView(curWebtoon: Webtoon) -> some View {
        VStack(alignment: .leading ,spacing: 3) {
            Text(curWebtoon.title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.mainText)
                .lineLimit(1)
                .padding(.bottom, 8)
            Text(curWebtoon.author)
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(.subText)
                .lineLimit(1)
            Text("\(curWebtoon.genre) | \(curWebtoon.day) 연재")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(.subText)
                .lineLimit(1)
        }
    }
    
    // 해당 키워드를 포함하는 웹툰들의 인덱스 반환
    func filtering(keyword: String) -> [Int] {
        var indexList = [Int]()
        for idx in webtoonData.webtoons.indices {
            if webtoonData.webtoons[idx].title.contains(keyword) || webtoonData.webtoons[idx].author.contains(keyword) {
                indexList.append(idx)
            }
        }
        return indexList
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
