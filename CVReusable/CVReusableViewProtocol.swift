//
//  CVReusableViewProtocol.swift
//  CVReusable
//
//  Created by caven on 2018/9/29.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CVReusableViewDelegate {
 
    /// 设置每个item的size
    @objc optional func reusableView(_ reusableView: CVReusableView, sizeForRowAt indexPath: IndexPath) -> CGSize
    
    /// 点击item
    @objc optional func reusableView(_ reusableView: CVReusableView, didSelectRowAt indexPath: IndexPath)
    
}

@objc protocol CVReusableViewDataSource {
    
    /// 设置 多少行，默认：1行
    @objc optional func numberOfSection(in reusableView: CVReusableView) -> Int
    
    /// 设置每行有多少列
    func reusableView(_ reusableView: CVReusableView, numberOfRowsInColumn column: Int) -> Int
    
    /// 设置每个位置的item
    func reusableView(_ reusableView: CVReusableView, itemForRowAt indexPath: IndexPath) -> CVReusableViewItem
}
