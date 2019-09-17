//
//  FriendCircleViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/24.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
import TZImagePickerController
import Toast

class FriendCircleViewController: CTViewController {
    
    fileprivate let cellId = "friendCircleCell"
    
    
    fileprivate var dataArray = [FriendCircleModel]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var headView : FriendCircleHeadView?
    
//    fileprivate var chatKeyBoard : ChatKeyBoard!
    
    var tag = 0 //记录点击按钮，1为更换banner，2为更换头像
    
    fileprivate var commentIndex = 0 //评论cell位置
    
    fileprivate var replyIndex = 0
    
    fileprivate var titleText = ""
    
    fileprivate var isNavBar = true //是否隐藏导航栏
    
    fileprivate var page = 1
    
    fileprivate lazy var notTextBtn : UIButton! = {
        
        let button = UIButton()
        button.setTitle("你还未发布过动态，去发布", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.black, for: .normal)
        button.isHidden = true
        return button
        
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.title = "朋友圈"
    
        self.setNavRightItem(imageStr: "takePhoto")
        
        getData()
        
        setKeyboard()
        
        headView = Bundle.main.loadNibNamed("FriendCircleHeadView", owner: self, options: nil)?.last as? FriendCircleHeadView
        headView!.frame = .init(x: 0, y: 0, width: ScreenW, height: 220)
        headView?.autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        
        headView?.backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        headView?.photoBtn.addTarget(self, action: #selector(selectPhoto(sender:)), for: .touchUpInside)
        headView?.avatarBtn.addTarget(self, action: #selector(selectPhoto(sender:)), for: .touchUpInside)
        
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(selectBanner(sender:)))
        headView?.bannerImage.isUserInteractionEnabled = true
        headView?.bannerImage.addGestureRecognizer(tapGestrue)
        
        self.setAdjustmentBehavior(srvData: tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.tableHeaderView = headView
        tableView.register(UINib.init(nibName: "FriendCircleCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        notTextBtn.addTarget(self, action: #selector(sendCircle), for: .touchUpInside)
        tableView.addSubview(notTextBtn)
        
        notTextBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.greaterThanOrEqualTo(10)
            make.height.greaterThanOrEqualTo(10)
        }
        
        AlertClass.setRefresh(with: tableView, headerAction: {[weak self] in
            
            self?.page = 1
            self?.getData()
            
        }) {[weak self] in
        
            self?.getData()
        }
        
    }
    
    //MARK: 获取内容
    fileprivate func getData() {
    
        NetworkRequest.requestMethod(.get, URLString: url_friendCircle, parameters: ["page":"\(self.page)","pageSize":"10"], success: { (value, json) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    
                    for item in array {
                        let model = FriendCircleModel.setModel(with: item)
                        self.dataArray.append(model)
                    }
                    
                    if array.count > 0 {
                        self.page += 1
                    }
                    
                    self.showEmptyView()
                    
                    self.tableView.reloadData()
                }
            }
            
        }) {
         
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }
    }
    
    func showEmptyView(){
        
        if self.dataArray.count == 0 {
            notTextBtn.isHidden = false
        }else{
            notTextBtn.isHidden = true
        }
    }
    
    @objc fileprivate func sendCircle() {
        
        let sendCircleVC = SendCircleViewController()
        sendCircleVC.sendBlock = {
            
            self.page = 1
            self.getData()
            
        }
        self.navigationController?.pushViewController(sendCircleVC)
    }
    
    override func actionRightItemClick() {
        
        let sendCircleVC = SendCircleViewController()
        sendCircleVC.sendBlock = {
            
            self.page = 1
            self.getData()
        }
        self.navigationController?.pushViewController(sendCircleVC)
    }
    
    
    //MARK: 设置键盘
    fileprivate func setKeyboard() {
        
//
//        chatKeyBoard = ChatKeyBoard.init(navgationBarTranslucent: false)
//
//        chatKeyBoard.delegate = self
//        chatKeyBoard.dataSource = self
//        chatKeyBoard.placeHolder = "评论"
//        chatKeyBoard.keyBoardStyle = .comment
//        chatKeyBoard.allowMore = false
//        chatKeyBoard.allowVoice = false
//        chatKeyBoard.backgroundColor = UIColor.setRGB(0xF6F6F6)
////        chatKeyBoard.frame = .init(x: 0, y: ScreenH, width: ScreenW, height: 60)
////        chatKeyBoard.associateTableView = tableView
//        self.view.addSubview(chatKeyBoard)
//
//        chatKeyBoard.isHidden = true
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tableView != nil {
            if tableView.contentOffset.y > StatusBarAddNavBarHeight {
                self.navigationController?.navigationBar.isHidden = false
            }else{
                self.navigationController?.navigationBar.isHidden = true
            }
        }else{
            self.navigationController?.navigationBar.isHidden = true//isNavBar
        }
        
        
//        if !isNavBar {
//            tableView.snp.remakeConstraints { (make) in
//                make.left.right.bottom.equalToSuperview()
//                make.top.equalToSuperview().offset(-StatusBarAddNavBarHeight)
//            }
//        }else{
//            tableView.snp.remakeConstraints { (make) in
//                make.left.right.bottom.equalToSuperview()
//                make.top.equalToSuperview()
//            }
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        
    }

    //MARK: 返回
    @objc fileprivate func backAction() {
        
        self.navigationController?.popViewController()
    }
    
    //MARK: 选择背景图片
    @objc fileprivate func selectBanner(sender:UITapGestureRecognizer) {
        
        self.tag = 3
        showPhotoView()
    }
    
    //MARK: 选择图片
    @objc fileprivate func selectPhoto(sender:UIButton) {
        
        tag = sender.tag
        
        if tag == 1 {
            
            let sendCircleVC = SendCircleViewController()
            sendCircleVC.sendBlock = {
             
//                self.commentArray.insert([String](), at: 0)
                self.page = 1
                self.getData()

            }
            self.navigationController?.pushViewController(sendCircleVC)
        }else if tag == 2 {
            
            self.navigationController?.pushViewController(MyCircleViewController())
        }
        
        
//        showPhotoView()
        
    }
    
    //MARK: 显示图片页面
    fileprivate func showPhotoView() {
        
        let selectPhotoVC = SelectPhotoViewController()
        selectPhotoVC.modalPresentationStyle = .overCurrentContext
        selectPhotoVC.photoBlock = {(title) in
            
            if title == "从手机相册选择" {
                
                self.selectFromAlbum()
                
            }else if title == "拍摄" {
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            
        }
        self.present(selectPhotoVC, animated: false, completion: nil)
    }
    
    //MARK: 相机
    fileprivate lazy var imagePicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    //MARK: 从相册选择
    fileprivate func selectFromAlbum() {
        
        if self.tag == 1 {
            let imagePickerVC = TZImagePickerController.init(maxImagesCount: 9, delegate: self)
            
            //通过block或代理得到用户选择的照片
            imagePickerVC?.didFinishPickingPhotosHandle = {(images,assets,flag) in
                
                
            }
            
            
            self.present(imagePickerVC!, animated: true, completion: nil)
        }else if self.tag == 3 {
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            let temp_mediaType = UIImagePickerController.availableMediaTypes(for: picker.sourceType)
            picker.mediaTypes = temp_mediaType!
            picker.allowsEditing = true
            picker.modalTransitionStyle = .coverVertical
            present(picker, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    
}

extension FriendCircleViewController : FriendCircleCellDelegate {
    
    
    func showImage(images: [String],index:Int) {
        
//        self.chatKeyBoard.keyboardUpforComment()
        
        let browser = WMPhotoBrowser()
        browser.dataSource = NSMutableArray.init(array: images)
        browser.downLoadNeeded = true
        browser.currentPhotoIndex = index
        self.present(browser, animated: true, completion: nil)
    }
    
    
    
    func replyAction(cellIndex: Int, index: Int, title:String) {
        
//        chatKeyBoard.isHidden = false
        
        commentIndex = cellIndex
        replyIndex = index
        titleText = title
        
//        self.chatKeyBoard.keyboardUpforComment()
    }
    
    
    
    func cellHeight(height: CGFloat, indexPath: IndexPath) {
        
    }
    
    
    //MARK: 评论
    func commentAction(index:Int, title:String) {
        
//        chatKeyBoard.isHidden = false
        
//        commentIndex = index
//        titleText = title
        
//        self.chatKeyBoard.keyboardUpforComment()
        
        let model = dataArray[index]
        
        AlertClass.setAlertView(msg: "是否删除该条消息", target: self, haveCancel: true) { (alert) in
            
            NetworkRequest.requestMethod(.post, URLString: url_friendCircle, parameters: ["id":model.id!,"method":"DELETE"], success: { (value, json) in
                
                
                
                if json["status"].stringValue == "SUCCESS" {
                    self.page = 1
                    self.getData()
                }else{
                    MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
                }
                
            }, failure: {
                
                
                
            })
        }
    }
    
    func uploadAvata(image:UIImage){
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        AlertClass.waiting("上传中")
        NetworkRequest.requestMethod(.upload, URLString: url_upload, parameters: nil , progress: { (progress) in
            
        }, constructingBodyWith: { (formData) in
            let curTime = getCurrentTime().getTimestamp()
            formData.appendPart(withFileData: imageData, name: "file", fileName: "\(curTime).jpeg", mimeType: "image/jpg/png/jpeg")
        }, success: { (value, json) in
            if json["status"].stringValue == "SUCCESS" {
                if let ret_data = json["ret_data"].dictionary {
                    let url = ret_data["url"]?.stringValue
                    
                    self.modifiedData(url: url!, imageData: imageData)
                    
                }
            }else{
                AlertClass.showErrorToat(withJson: json)
            }
            print("***************** 成功-----\(json)")
            
        }) {
            AlertClass.stop()
        }
        
        
        
    }
    
    func modifiedData(url:String,imageData:Data){
        let parm:[String : Any] = [
            "cover":url,
            "method":"PUT",
            ]
        
        AlertClass.waiting("正在更新封面")
        
        NetworkRequest.requestMethod(.post, URLString: url_signUp, parameters:parm , success: { (value, json) in
            AlertClass.stop()
            
            if json["status"].stringValue == "SUCCESS" {
                AlertClass.showMessageToat(withJson: json)
                CacheClass.setObject(url, forEnumKey: .cover)
                self.headView?.bannerImage.image = UIImage.init(data: imageData)
                self.headView?.tipLabel.text = ""
        
            }else{
                AlertClass.showErrorToat(withJson: json)
            }
        }) {
            AlertClass.stop()
        }
    }
}

extension FriendCircleViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate,TZImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let headImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        switch self.tag {
        case 1:
            break
        case 2:
            break

        case 3:
            uploadAvata(image: headImage!)
        default:
            break
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension FriendCircleViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model = dataArray[indexPath.row]
        
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
        
        let titleHeight = title.size(font: 14, width: ScreenW-80).height + 5
        
        var imageH = CGFloat(count) * (ScreenW-134)/3
        
        if imageCount > 6 {
            imageH += 20
        }else if imageCount > 3 && imageCount <= 6{
            imageH += 10
        }
        
//        var h:CGFloat = 0 //评论区高度
        
//        let array = commentArray[indexPath.row]
//
//        for title in array {
//
//            let height = title.size(font: 12, width: ScreenW-80).height
//
//            h += height
//        }
        
        

        
        let height = titleHeight + imageH + 70 //+ h
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataArray[indexPath.row]
        
        var imageCount = 0
        
        if let images = model.images as? [String] {
            imageCount = images.count
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? FriendCircleCell
        
        var count = imageCount/3
        let count2 = imageCount%3

        if count2 != 0 {
            count += 1
        }
        
        var imageH = CGFloat(count) * (ScreenW-134)/3
        
        if imageCount > 6 {
            imageH += 20
        }else if imageCount > 3 && imageCount <= 6{
            imageH += 10
        }

        cell?.collectionView.snp.remakeConstraints({ (make) in
            make.top.equalTo((cell?.titleLabel.snp.bottom)!).offset(8)
            make.left.equalTo((cell?.titleLabel)!)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(imageH)
        })
        
        cell?.delegate = self
//        cell?.dataArray = commentArray[indexPath.row]
        if let images = model.images as? [String] {
            cell?.images = images
        }
        
        cell?.nameLabel.setTitle(model.nickname, for: .normal)
        cell?.titleLabel.text = model.contents
        cell?.timeLabel.text = model.addtime
        cell?.avatarBtn.setBackgroundImageFor(.normal, with: URL.init(string: model.avatar ?? "")!, placeholderImage: UIImage.init(named: ""))
        
        cell?.selectionStyle = .none
        cell?.commentBtn.tag = indexPath.row
        cell?.cellIndex = indexPath.row

        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        
//        chatKeyBoard.keyboardDownForComment()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > StatusBarAddNavBarHeight {
            
            isNavBar = false
            
        }else{
            isNavBar = true
            
        }
        
//        if scrollView.contentOffset.y < 0 {
//            headView?.bannerImage.frame.size.height = 200 -  scrollView.contentOffset.y
//            headView?.bannerImage.frame.origin.y = scrollView.contentOffset.y
//        }
//
        self.navigationController?.navigationBar.isHidden = isNavBar
        
//        chatKeyBoard.keyboardDownForComment()
    }
}

extension FriendCircleViewController : ChatKeyBoardDelegate,ChatKeyBoardDataSource,FacePanelDelegate {
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
        
           
//        commentArray[commentIndex].append(text)
        
        let indexPath = NSIndexPath.init(row: commentIndex, section: 0) as IndexPath
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        
//        chatKeyBoard.keyboardDownForComment()
    }
    
}


