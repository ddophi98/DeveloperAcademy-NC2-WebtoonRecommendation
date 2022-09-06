//
//  NavigationExtension.swift
//  WebtoonRecommend
//
//  Created by 김동락 on 2022/08/25.
//

import UIKit

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
