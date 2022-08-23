//
//  LoadingView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/23.
//

import SwiftUI

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
