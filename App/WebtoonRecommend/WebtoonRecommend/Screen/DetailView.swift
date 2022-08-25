//
//  DetailView.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/25.
//

import SwiftUI

struct DetailView: View {
    let webtoonIndex: Int
    
    init(webtoonIndex: Int) {
        self.webtoonIndex = webtoonIndex
        UINavigationBar.appearance().tintColor = UIColor(Color.mainText)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(webtoonIndex: 1)
    }
}
