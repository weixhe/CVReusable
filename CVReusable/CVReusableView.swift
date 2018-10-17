//
//  CVReusableView.swift
//  CVReusable
//
//  Created by caven on 2018/9/29.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

enum CVReusableViewSelectionStyle {
    case single     // 单击
    case none
}
class CVReusableView: UIView {
    /* 公有属性 */
    var delegate: CVReusableViewDelegate?
    var dataSource: CVReusableViewDataSource?
    /// 选中样式：单击，无
    var selectStyle: CVReusableViewSelectionStyle = .single
    /// 行距
    var minimumLineSpacing: CGFloat = 0
    /// 列距
    var minimumInteritemSpacing: CGFloat = 0
    
    
    private(set) var numberOfSection: Int = 1
    
    
    /* 私有属性 */
    private var scrollView: UIScrollView!
    private var reusableItems: [String:[CVReusableViewItem]] = [:]
    private var visiableItems: [CVReusableViewItem] = []
    private var reuseIdentifier: [String:CVReusableViewItem.Type] = [:] // 保存标识符identifier
    private var itemClass: CVReusableViewItem.Type?        // 记录item的类型
    private var numberOfRowsInColumn: [Int:Int] = [:]       // 保存每行的列数
    private var sizeOfIndexPath: [IndexPath:CGSize] = [:]   // 保存item的尺寸
    private var movePoint: CGPoint = CGPoint.zero   // 布局item时原点位置的移动，计算
    private var selectedIndexPath: IndexPath?   // 记录选中的item的位置
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.bounces = false
        self.addSubview(self.scrollView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.scrollView.frame = self.bounds
    }

    /// 注册item类
    public func register(_ itemClass: CVReusableViewItem.Type, forItemReuseIdentifier identifier: String) {
        self.reuseIdentifier[identifier] = itemClass
    }
    
    /// 从队列中取出一个item
    public func dequeueReusableItem(withIdentifier identifier: String) -> CVReusableViewItem {
        
        if !self.reuseIdentifier.keys.contains(identifier) {
            assertionFailure("您还没有注册标识符 \(identifier)，请检查注册标识信息")
        }
        
        var reusableArray: [CVReusableViewItem] = self.reusableItems[identifier] ?? []
        
        if reusableArray.count == 0 {
            let Class = self.reuseIdentifier[identifier]!
            let item = Class.init(reuseIdentifier: identifier)
            if self.selectStyle == .single {
                item.__addAction { [weak self] (indexPath) in
                    if let strongSelf = self {
                        if let path = strongSelf.selectedIndexPath {
                            if indexPath.section == path.section && indexPath.row == path.row {
                                // 点击的同一个item，不作处理
                            } else {
                                if let sele_item = strongSelf.itemForIndexPath(path) {
                                    sele_item.isSelected = false
                                    sele_item.isHighlight = false
                                }
                            }
                        }
                        
                        strongSelf.selectedIndexPath = indexPath
                        strongSelf.delegate?.reusableView?(strongSelf, didSelectRowAt: indexPath)
                    }
                }
            }
            // 将item放到已使用的数组中，并保存到字典中
            self.visiableItems.append(item)
            return item
            
        } else {
            let item = reusableArray.remove(at: 0)
            // 将item放到已使用的数组中，并保存到字典中
            self.visiableItems.append(item)
            return item
        }
    }
    
    /// 刷新数据
    public func reloadData() {
        
        // 将已显示的item，放到 队列中
        for item in self.visiableItems {
            let identifier = item.reuseIdentifier
            var reusableArray: [CVReusableViewItem] = self.reusableItems[identifier] ?? []
            item.removeFromSuperview()
            reusableArray.append(item)
        }
        
       self.clean()

        // 取值 行，列
        if let dataSource = self.dataSource {
            self.numberOfSection = dataSource.numberOfSection?(in: self) ?? 1
            for colum in 0..<self.numberOfSection {
                let rowCount = dataSource.reusableView(self, numberOfRowsInColumn: colum)
                self.numberOfRowsInColumn[colum] = rowCount;
            }

            for colum in 0..<self.numberOfSection {
                let numberOfRows = self.numberOfRowsInColumn[colum] ?? 0
                for row in 0..<numberOfRows {
                    let indexPath = IndexPath(item: row, section: colum)
                    let item: CVReusableViewItem = dataSource.reusableView(self, itemForRowAt: indexPath)
                    item.__indexPath = indexPath
                    let size: CGSize = self.delegate?.reusableView?(self, sizeForRowAt: indexPath) ?? self.frame.size
                    self.sizeOfIndexPath[indexPath] = size
                    self.updateItemFrame(item, indexPath: indexPath)
                    self.scrollView.addSubview(item)
                }
            }
        }
        
        //  更新contentSize
        self.updateContentSize()
    }
    
    /// 查找一个item，根据indexPath
    func itemForIndexPath(_ indexPath: IndexPath?) -> CVReusableViewItem? {
        var result: CVReusableViewItem? = nil
        if indexPath != nil {
            for item in self.visiableItems {
                if item.__indexPath!.section == indexPath!.section && item.__indexPath?.row == indexPath!.row {
                    result = item
                    break
                }
            }
        }
        return result
    }
    
    /// 设置item选中状态取消
    func deselectedItem(at indexPath: IndexPath) {
        let item = self.itemForIndexPath(indexPath)
        if item != nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                item!.isHighlight = false
                item!.isSelected = false
                item!.cleanSelectedStatus()
                self.selectedIndexPath = nil
            }
        }
    }
}



private extension CVReusableView {
    
    /// 清空
    func clean() {
        self.numberOfSection = 1
        self.numberOfRowsInColumn.removeAll()
        self.sizeOfIndexPath.removeAll()
        self.visiableItems.removeAll()
        self.movePoint = CGPoint.zero
    }

    /// 更新frame
    func updateItemFrame(_ item: CVReusableViewItem, indexPath: IndexPath) {
        
        if let size = self.sizeOfIndexPath[indexPath] {
            
            
            var x: CGFloat = self.movePoint.x
            var y: CGFloat = self.movePoint.y
            
            
            if indexPath.row == 0 {  // 每一行的第一列
                x = 0
            } else {
                for everyItem in self.visiableItems {
                    if everyItem.__indexPath!.row == indexPath.row - 1 && everyItem.__indexPath!.section == indexPath.section {
                        x = everyItem.frame.maxX + self.minimumInteritemSpacing
                        break
                    }
                }
            }
            
            if indexPath.section == 0 {  // 每一列的第一行
                y = 0
            } else {
                for everyItem in self.visiableItems {
                    if everyItem.__indexPath!.row == indexPath.row && everyItem.__indexPath!.section == indexPath.section - 1 {
                        y = everyItem.frame.maxY + self.minimumLineSpacing
                        break
                    }
                }
            }
            
            self.movePoint = CGPoint(x: x, y: y)
            item.frame = CGRect(x: self.movePoint.x, y: self.movePoint.y, width: size.width, height: size.height)
            item.__updateFrame()
        }
    }
    
    /// 更新contentSize
    func updateContentSize() {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        let firstColumnWidths = self.visiableItems.map { (everyItem: CVReusableViewItem) -> CGFloat in
            return everyItem.__indexPath!.section == 0 ? everyItem.frame.width : 0
        }
        
        let firstRowHeights = self.visiableItems.map { (everyItem: CVReusableViewItem) -> CGFloat in
            return everyItem.__indexPath!.row == 0 ? everyItem.frame.height : 0
        }
        
        for w in firstColumnWidths {
            width += w
        }
        for h in firstRowHeights {
            height += h
        }
        
        self.scrollView.contentSize = CGSize(width: width, height: height)
    }
}

// MARK: - CVReusableViewItem 扩展
typealias ClickClosure = ((_ indexPath: IndexPath)->())
private let color_select_gray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6)
private let color_select_blue = UIColor(red: 33/255, green: 64/255, blue: 1, alpha: 1)

fileprivate extension CVReusableViewItem {

    struct exten_key {
        static var indexPath = "indexPath"
        static var clickClosure = "clickClosure"
        static var button = "button"
        static var selectedBGView = "selectedBGView"
    }

    
    var __indexPath: IndexPath? {
        set {
            objc_setAssociatedObject(self, &exten_key.indexPath, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &exten_key.indexPath) as? IndexPath
        }
    }
    
    var __click: ClickClosure? {
        set {
            objc_setAssociatedObject(self, &exten_key.clickClosure, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &exten_key.clickClosure) as? ClickClosure
        }
    }
    
    var __button: UIButton? {
        set {
            objc_setAssociatedObject(self, &exten_key.button, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &exten_key.button) as? UIButton
        }
    }
    
    /// 选中时的背景颜色
    var __selectedBGView: UIView? {
        set {
            objc_setAssociatedObject(self, &exten_key.selectedBGView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &exten_key.selectedBGView) as? UIView
        }
    }
    
    func __addAction(click: @escaping ClickClosure) {
        self.__click = click
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(onClickTouchDown(_:)), for: UIControl.Event.touchDown)
        btn.addTarget(self, action: #selector(onClickTouchUp(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(btn)
        self.__button = btn
        
        self.__selectedBGView = UIView(frame: CGRect.zero)
        self.cleanSelectedStatus()
        self.addSubview(self.__selectedBGView!)
        self.sendSubviewToBack(self.__selectedBGView!)
    }
    
    
    
    func __updateFrame() {
        self.__button?.frame = self.bounds
        self.__selectedBGView?.frame = self.bounds
    }
    
    // MARK: - Actions
    @objc func onClickTouchDown(_ sender: UIButton) {
        self.isHighlight = true
        self.setSelectedStatus()
    }
    @objc func onClickTouchUp(_ sender: UIButton) {
        self.isHighlight = false
        self.isSelected = true
        self.setSelectedStatus()
        self.__click?(self.__indexPath!)
    }
    
    /// 清空选中样式
    func cleanSelectedStatus() {
        self.__selectedBGView!.backgroundColor = UIColor.clear
    }
    
    /// 选中item, 设置选中样式
    func setSelectedStatus() {
        if self.selectedStyle == .none {
            return
        } else if selectedStyle == .gray {
            self.__selectedBGView!.backgroundColor = color_select_gray
        } else if selectedStyle == .blue {
            self.__selectedBGView!.backgroundColor = color_select_blue
        } else if selectedStyle == .custom {
            self.__selectedBGView!.backgroundColor = self.selectedColor ?? color_select_gray
        }
    }
}
