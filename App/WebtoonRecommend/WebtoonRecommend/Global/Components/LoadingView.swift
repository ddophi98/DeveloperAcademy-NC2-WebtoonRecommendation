//
//  LoadingView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/23.
//

import SwiftUI

// 로티 뷰로 보여지는 로딩 화면 (로딩이 빨리 끝날때)
struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            LottieView(filename: "Loading")
                .frame(width: 200, height: 200)
            Spacer()
        }
    }
}
