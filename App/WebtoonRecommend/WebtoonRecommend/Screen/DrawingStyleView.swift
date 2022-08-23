//
//  DrawingStyleView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI

struct DrawingStyleView: View {
    @EnvironmentObject var webtoonData: WebtoonData
    
    var body: some View {
        VStack {
            HeaderView(title: "그림체")
            if webtoonData.isFinishSavingAll {
                getContentView()
            } else if webtoonData.isError {
                ErrorView(webtoonData: webtoonData)
            } else {
                if webtoonData.isImageExist {
                    LoadingView()
                } else {
                    ProgressLoadingView(webtoonData: webtoonData)
                }
            }
        }
        .background(Color.background)
    }
    
    // 원래 보여줘야할 콘텐츠
    @ViewBuilder
    func getContentView() -> some View {
        Text("finish!")
            .padding()
        Spacer()
    }
}

struct DrawingStyleView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingStyleView()
    }
}
