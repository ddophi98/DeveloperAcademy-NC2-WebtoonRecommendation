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
            } else if webtoonData.isError {
                getErrorView()
            } else {
                if webtoonData.isImageExist {
                    getLoadingView()
                } else {
                    getProgressLoadingView()
                }
            }
        }
        .background(Color.background)
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
        Rectangle()
            .fill(Color.mainText)
            .frame(height: 2)
    }

    // 로티를 이용한 로딩 애니메이션 및 프로그래스 바 (긴 로딩)
    @ViewBuilder
    func getProgressLoadingView() -> some View {
        Spacer()
        LottieView(filename: "Loading")
            .frame(width: 200, height: 200)
        Text("최초 실행시에만 데이터가 다운로드 됩니다.")
            .foregroundColor(Color.mainText)
            .font(.system(size: 15, weight: .heavy))
            .padding(.bottom, 15)
        ProgressView(value: Double(webtoonData.progress), total: Double(GlobalVar.webtoonSize*2))
            .frame(height: 8.0)
            .scaleEffect(x: 1, y: 2, anchor: .center)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .tint(Color.highlighted)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        Spacer()
    }
    
    // 로티를 이용한 로딩 애니메이션
    @ViewBuilder
    func getLoadingView() -> some View {
        Spacer()
        LottieView(filename: "Loading")
            .frame(width: 200, height: 200)
        Spacer()
    }
    
    // 데이터 받아오는 과정에서 오류가 떴을때 보여주는 뷰
    @ViewBuilder
    func getErrorView() -> some View {
        Spacer()
        VStack(spacing: 20) {
            Text("데이터를 불러오는 중에 오류가 발생했습니다.")
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal)
            Button{
                webtoonData.initInfo()
            } label: {
                HStack{
                    Text("다시 시도하기")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "gobackward")
                        .font(.system(size: 13, weight: .bold))
                }
            }
        }
        Spacer()
    }


    // 원래 보여줘야할 콘텐츠
    @ViewBuilder
    func getContentView() -> some View {
        Text("finish!")
            .padding()
        Spacer()
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
