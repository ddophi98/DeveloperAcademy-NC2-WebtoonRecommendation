//
//  GenreView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/19.
//

import SwiftUI

struct GenreView: View {
    var body: some View {
        VStack {
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
            Spacer()
        }
        .background(Color.mainText)
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
