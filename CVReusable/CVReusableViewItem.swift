//
//  CVReusableViewItem.swift
//  CVReusable
//
//  Created by caven on 2018/9/29.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit



enum CVReusableViewItemSelectedStyle {
    case none
    case gray
    case blue
    
    case custom     // 自定义选中样式，此时：selectedColor有效
}

class CVReusableViewItem: UIView {
    
    var reuseIdentifier: String = ""
    var selectedColor: UIColor?
    var selectedStyle: CVReusableViewItemSelectedStyle = .gray
    
    var isHighlight: Bool = false
    var isSelected: Bool = false
    
    
    required init(reuseIdentifier: String) {
        self.init()
        self.reuseIdentifier = reuseIdentifier
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
