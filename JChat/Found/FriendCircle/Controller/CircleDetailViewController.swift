//
//  CircleDetailViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/27.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class CircleDetailViewController: CTViewController {
    
    
    var model = FriendCircleModel()
    
//    fileprivate var chatKeyBoard : ChatKeyBoard!
    
    fileprivate var detailsView : CircleDetailsView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "详情"
        
//        setKeyboard()

        detailsView = Bundle.main.loadNibNamed("CircleDetailsView", owner: self, options: nil)?.last as? CircleDetailsView
        
        if let images = model.images as? [String] {
            detailsView.images = images
        }

        
//        detailsView.dataArray = dataArray
        detailsView.timeLabel.text = model.addtime
        detailsView.nameLabel.setTitle(model.nickname, for: .normal)
        detailsView.avatarBtn.setBackgroundImageFor(.normal, with: URL.init(string: model.avatar ?? "")!, placeholderImage: UIImage.init(named: ""))
        detailsView.titleLabel.text = model.contents
        detailsView.delegate = self
        
        self.view.addSubview(detailsView)
        
        remakeConstraints()

    }
    
    //MARK: 设置约束
    fileprivate func remakeConstraints() {
        
        let title = model.contents ?? ""
        
        var imageCount = 0
        
        if let images = model.images as? [String] {
            imageCount = images.count
        }
        
        var count = imageCount/3
        let count2 = imageCount%3
        
        if count2 != 0 {
            count += 1
        }
        
        var titleHeight = title.size(font: 14, width: ScreenW-80).height + 5
        
        if titleHeight < 20 {
            titleHeight = 20
        }
        
        
        var imageH = CGFloat(count) * (ScreenW-134)/3
        
        if imageCount > 6 {
            imageH += 20
        }else if imageCount > 3 && imageCount <= 6{
            imageH += 10
        }
        
//        var h:CGFloat = 0 //评论区高度
//
//        for title in dataArray {
//
//            let height = title.size(font: 12, width: ScreenW-80).height
//
//            h += height
//        }
        
        let height = titleHeight + imageH + 120 //+ h
        
        detailsView.snp.remakeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        
        detailsView.collectionView.snp.remakeConstraints({ (make) in
            make.top.equalTo(detailsView.titleLabel.snp.bottom).offset(8)
            make.left.equalTo((detailsView.titleLabel)!)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(CGFloat(count) * (ScreenW-134)/3 + 20)
        })
    }
    
    //MARK: 设置键盘
    fileprivate func setKeyboard() {
        
//        chatKeyBoard = ChatKeyBoard.init(navgationBarTranslucent: false)
//
//        chatKeyBoard.delegate = self
//        chatKeyBoard.dataSource = self
//        chatKeyBoard.placeHolder = "评论"
//        chatKeyBoard.keyBoardStyle = .comment
//        chatKeyBoard.allowMore = false
//        chatKeyBoard.allowVoice = false
//        chatKeyBoard.backgroundColor = UIColor.setRGB(0xF6F6F6)
//
//        self.view.addSubview(chatKeyBoard)
//
//        chatKeyBoard.keyboardDownForComment()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        chatKeyBoard.keyboardDownForComment()
    }
    
}

extension CircleDetailViewController : ChatKeyBoardDelegate,ChatKeyBoardDataSource,FacePanelDelegate {
    func chatKeyBoardMorePanelItems() -> [MoreItem]! {
        
        return [MoreItem]()
    }
    
    func chatKeyBoardToolbarItems() -> [ChatToolBarItem]! {
        
        let item = ChatToolBarItem.init(kind: BarItemKind.face, normal: "face", high: "face_HL", select: "keyboard")
        //        let item2 = ChatToolBarItem.init(kind: BarItemKind.switchBar, normal: "switchDown", high: nil, select: nil)
        //        let item3 = ChatToolBarItem.init(kind: BarItemKind.switchBar, normal: "voice", high: "voice_HL", select: "keyboard")
        //        let item4 = ChatToolBarItem.init(kind: BarItemKind.switchBar, normal: "more_ios", high: "more_ios_HL", select: nil)
        
        return [item!]
    }
    
    func chatKeyBoardFacePanelSubjectItems() -> [FaceThemeModel]! {
        
        var subjectArray = [FaceThemeModel]()
        
        let sources = ["face"];
        
        for i in 0..<sources.count {
            
            let plistName = sources[i]
            
            let plistPath = Bundle.main.path(forResource: plistName, ofType: "plist")
            let faceDic = NSDictionary.init(contentsOfFile: plistPath!)
            
            let allkeys = faceDic?.allKeys
            
            let themeM = FaceThemeModel()
            themeM.themeStyle = FaceThemeStyle.customEmoji
            themeM.themeDecribe = "f\(i)"
            
            var modelsArr = [FaceModel]()
            
            for i in 0..<allkeys!.count {
                let name = allkeys?[i] as? String
                let fm = FaceModel()
                fm.faceTitle = name
                fm.faceIcon = faceDic?.object(forKey: name ?? "") as? String
                modelsArr.append(fm)
            }
            
            themeM.faceModels = modelsArr
            
            subjectArray.append(themeM)
        }
        
        return subjectArray
        
    }
    
    func chatKeyBoardSendText(_ text: String!) {
        
        
        
//        dataArray.append(text)
//        detailsView.dataArray = dataArray
//        remakeConstraints()
        
//        chatKeyBoard.keyboardDownForComment()
    }
    
}

extension CircleDetailViewController : CircleDetailsViewDelegate {
    
    func showImage(images: [String]) {
        
//        self.chatKeyBoard.keyboardUpforComment()
        
        let browser = WMPhotoBrowser()
        browser.dataSource = NSMutableArray.init(array: images)
        browser.downLoadNeeded = true
        browser.currentPhotoIndex = 0
        self.present(browser, animated: true, completion: nil)
    }
    
    
    
    func replyAction(cellIndex: Int, index: Int, title:String) {
        
      
        
//        self.chatKeyBoard.keyboardUpforComment()
    }
    
    
    
    func cellHeight(height: CGFloat, indexPath: IndexPath) {
        
    }
    
    
    //MARK: 评论
    func commentAction(index:Int, title:String) {
        
      
        
//        self.chatKeyBoard.keyboardUpforComment()
    }
}
