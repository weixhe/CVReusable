//
//  ViewController.swift
//  CVReusable
//
//  Created by caven on 2018/9/29.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

enum HomeType {
    case hot
    case new
}

let space_line: CGFloat = 1

class ViewController: UIViewController {
    
    var categary: CVReusableView!
    var themeView: CVReusableView!
    
    var left: UIButton!
    var right: UIButton!
    
    var type: HomeType = .hot
    
    
    var hot_cate = ["你好\n中国", "上海\nShanghai", "河北\nHeBei", "广东\nGuangdong", "桂林\nGuiLin", "邢台\nXingtai", "北京\nBaeijing", "山西\nShanXI", "新疆\nXinJiang"]
    var new_cate = [["用户分享", "新门户", "揍你", "亲子活动"], ["用户分享", "新门户", "揍你", "亲子活动"], ["用户分享", "新门户", "揍你", "亲子活动"]]
    var new_cate_image = [["1", "2", "3", "4"], ["5", "6", "7", "8"], ["1", "2", "3", "4"]]

    var hot_theme = [[["pic":"1", "title":"五一活动"], ["pic":"2", "title":"亲自活动"]], [["pic":"3", "title":"港澳行"]]]
    var new_theme = [[["pic":"4", "title":"港澳行"], ["pic":"5", "title":"广场活动"]],
                     [["pic":"6", "title":"爱琴海旅行"]],
                     [["pic":"7", "title":"长城游"], ["pic":"8", "title":"古北水镇"]]]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(hue: 0xF2F2F2, saturation: 0.5, brightness: 0.5, alpha: 1)

        
        left = UIButton(type: .custom)
        left.setTitle("hot", for: .normal)
        left.setTitleColor(UIColor.white, for: UIControl.State.normal)
        left.backgroundColor = UIColor.red
        left.tag = 100
        left.addTarget(self, action: #selector(onClickChangeType(_:)), for: .touchUpInside)
        self.view.addSubview(left)
        
        right = UIButton(type: .custom)
        right.setTitle("new", for: .normal)
        right.setTitleColor(UIColor.white, for: UIControl.State.normal)
        right.backgroundColor = UIColor.red
        right.tag = 101
        right.addTarget(self, action: #selector(onClickChangeType(_:)), for: .touchUpInside)
        self.view.addSubview(right)
        
        left.frame = CGRect(x: 0, y: 80, width: self.view.frame.width / 2, height: 40)
        right.frame = CGRect(x: left.frame.maxX, y: 80, width: self.view.frame.width / 2, height: 40)
        
        
        // 分类
        self.categary = CVReusableView(frame: CGRect(x: 0, y: left.frame.maxY, width: self.view.frame.width, height: 200))
        self.categary.backgroundColor = UIColor.white
        self.categary.register(TestView.self, forItemReuseIdentifier: "TestView")
        self.categary.register(CategaryView.self, forItemReuseIdentifier: "CategaryView")
        self.categary.minimumLineSpacing = 1
        self.categary.delegate = self
        self.categary.dataSource = self
        self.view.addSubview(self.categary)
        
        // 主题
        self.themeView = CVReusableView(frame: CGRect(x: 0, y: self.categary.frame.maxY + 10, width: self.view.frame.width, height: 200))
        self.themeView.backgroundColor = UIColor.white
        self.themeView.register(TestView.self, forItemReuseIdentifier: "TestView")
        self.themeView.register(CategaryView.self, forItemReuseIdentifier: "CategaryView")
        self.themeView.delegate = self
        self.themeView.dataSource = self
        self.themeView.minimumLineSpacing = 1
        self.themeView.minimumInteritemSpacing = 1
        self.view.addSubview(self.themeView)
        
        self.onClickChangeType(left)
    }
    
    @objc func onClickChangeType(_ sender: UIButton) {
        
        for i in 100..<102 {
            let btn = self.view.viewWithTag(i) as! UIButton
            btn.backgroundColor = UIColor.lightGray
        }
        
        sender.backgroundColor = UIColor.red
        
        if sender.tag == 100 {
            self.type = .hot
        } else if sender.tag == 101 {
            self.type = .new
        }
        
        
        if self.type == .hot {
            self.categary.frame = CGRect(x: 0, y: left.frame.maxY + 10, width: self.view.frame.width, height: 60)
            self.themeView.frame = CGRect(x: 0, y: self.categary.frame.maxY + 10, width: self.view.frame.width, height: 150)

        } else if self.type == .new {
            self.categary.frame = CGRect(x: 0, y: left.frame.maxY + 10, width: self.view.frame.width, height: 120)
            self.themeView.frame = CGRect(x: 0, y: self.categary.frame.maxY + 10, width: self.view.frame.width, height: 225)
        }
        self.categary.reloadData()
        self.themeView.reloadData()
    }


}

extension ViewController : CVReusableViewDelegate, CVReusableViewDataSource {
    func numberOfSection(in reusableView: CVReusableView) -> Int {
        
        if self.type == .hot {
            if self.categary == reusableView {
                return 1
            } else if self.themeView == reusableView  {
                return self.hot_theme.count
            }
        } else if self.type == .new {
            if self.categary == reusableView {
                return 2
            } else if self.themeView == reusableView  {
                return self.new_theme.count
            }
        }
        return 0
    }

    func reusableView(_ reusableView: CVReusableView, numberOfRowsInColumn column: Int) -> Int {
        if self.type == .hot {
            if self.categary == reusableView {
                return self.hot_cate.count
            } else if self.themeView == reusableView  {
                return self.hot_theme[column].count
            }
        } else if self.type == .new {
            if self.categary == reusableView {
                return self.new_cate[column].count
            } else if self.themeView == reusableView  {
                return self.new_theme[column].count
            }
        }
        return 0
    }

    func reusableView(_ reusableView: CVReusableView, sizeForRowAt indexPath: IndexPath) -> CGSize {
        if self.type == .hot {
            if self.categary == reusableView {
                return CGSize(width: 60, height: 60)
            } else if self.themeView == reusableView {
                // 这里的theme有三个
                if indexPath.section == 0 {
                    if indexPath.row == 0 { return CGSize(width: 150, height: 75) }
                    if indexPath.row == 1 { return CGSize(width: reusableView.frame.width - 150 - space_line, height: 150)}
                } else if indexPath.section == 1 {
                    if indexPath.row == 0 { return CGSize(width: 150, height: 75 - space_line) }
                }
                return CGSize.zero
            }
        } else if self.type == .new {
            
            if self.categary == reusableView {
                let width = reusableView.frame.width / CGFloat(self.new_cate[indexPath.section].count)
                return CGSize(width: width, height: reusableView.frame.height / 2)
            } else if self.themeView == reusableView {
                // 这里的theme有三个
                if indexPath.section == 0 {
                    
                    if indexPath.row == 0 { return CGSize(width: 150, height: 75) }
                    if indexPath.row == 1 { return CGSize(width: reusableView.frame.width - 150 - space_line, height: 150)}
                    
                } else if indexPath.section == 1 {
                    if indexPath.row == 0 { return CGSize(width: 150, height: 75 - space_line) }
                    
                } else if indexPath.section == 2 {
                    if indexPath.row == 0 { return CGSize(width: 150, height: 75 - space_line) }
                    if indexPath.row == 1 { return CGSize(width: reusableView.frame.width - 150 - space_line, height: 75 - space_line)}
                }
            }
        }
        return CGSize.zero
    }

    func reusableView(_ reusableView: CVReusableView, itemForRowAt indexPath: IndexPath) -> CVReusableViewItem {
        if self.type == .hot {
            if self.categary == reusableView {
                let item = reusableView.dequeueReusableItem(withIdentifier: "TestView") as! TestView
                item.titleLabel.text = self.hot_cate[indexPath.row]
                return item
            } else {
                let ontTheme = self.hot_theme[indexPath.section][indexPath.row]
                let item = reusableView.dequeueReusableItem(withIdentifier: "CategaryView") as! CategaryView
                item.titleLabel.text = ontTheme["title"]
                item.imageView.image = UIImage(named: ontTheme["pic"]!)
                return item
            }
            
        } else if self.type == .new {
            
            if self.categary == reusableView {
                let oneCate = self.new_cate[indexPath.section][indexPath.row]
                let oneCateImage = self.new_cate_image[indexPath.section][indexPath.row]

                let item = reusableView.dequeueReusableItem(withIdentifier: "CategaryView") as! CategaryView
                item.selectedStyle = .blue
                item.titleLabel.text = oneCate
                item.imageView.image = UIImage(named: oneCateImage)
                return item
            } else {
                let ontTheme = self.new_theme[indexPath.section][indexPath.row]
                let item = reusableView.dequeueReusableItem(withIdentifier: "CategaryView") as! CategaryView
                item.titleLabel.text = ontTheme["title"]
                item.imageView.image = UIImage(named: ontTheme["pic"]!)
                return item
            }
        }
        return CVReusableViewItem.init(frame: CGRect.zero)
    }
    
    func reusableView(_ reusableView: CVReusableView, didSelectRowAt indexPath: IndexPath) {
        reusableView.deselectedItem(at: indexPath)
        if self.type == .hot {
            print(self.hot_cate[indexPath.row])
        } else if self.type == .new {
            print(self.new_cate[indexPath.section][indexPath.row])
        }
    }

}


class TestView: CVReusableViewItem {
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(reuseIdentifier: String) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.orange
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.addSubview(self.titleLabel)
    }
    
    
    override func layoutSubviews() {
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }

}


class CategaryView: CVReusableViewItem {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(reuseIdentifier: String) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.orange
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.addSubview(self.titleLabel)
        
        self.imageView = UIImageView(frame: CGRect.zero)
        self.imageView.contentMode = .scaleAspectFill
        self.addSubview(self.imageView)
    }
    
    override func layoutSubviews() {
        
        self.imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.imageView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 10)
        self.titleLabel.frame = CGRect(x: 0, y: self.imageView.frame.maxY + 5, width: self.frame.width, height: 15)

    }

    
}
