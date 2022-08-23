//
//  ProgressLoadingView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/23.
//

import SwiftUI

struct ProgressLoadingView: View {
    @StateObject var webtoonData: WebtoonData
    
    var body: some View {
        VStack {
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
    }
}
