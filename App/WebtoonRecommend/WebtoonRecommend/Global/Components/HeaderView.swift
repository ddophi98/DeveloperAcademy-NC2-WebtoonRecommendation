//
//  HeaderView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/23.
//

import SwiftUI

// 각 탭바의 헤더
struct HeaderView: View {
    let title: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
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
                .frame(height: GlobalVar.lineWidth)
        }
    }
}
