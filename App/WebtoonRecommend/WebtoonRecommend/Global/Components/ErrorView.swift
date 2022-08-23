//
//  ErrorView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/23.
//

import SwiftUI

// 데이터 로딩중 오류가 발생하면 보여주는 화면
struct ErrorView: View {
    @StateObject var webtoonData: WebtoonData
    
    var body: some View {
        VStack {
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
    }
}
