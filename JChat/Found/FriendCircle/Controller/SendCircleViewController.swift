//
//  SendCircleViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/26.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit
import TZImagePickerController

class SendCircleViewController: CTViewController {
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let cellId = "imageCell"
    
    fileprivate let addImage = UIImage.init(named: "add")
    
    fileprivate var dataArray = [UIImage]()
    
    var sendBlock : (()->Void)?
    
    fileprivate var assets = [Any]() //选中图片
    
    var imageCount = 0 //图片数量
    var imageUrls = [String]() //图片链接
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataArray.append(addImage!)
        
        makeConstraint()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    

    //MARK: 设置约束
    fileprivate func makeConstraint() {
        
        textView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "FirendCircleImageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(36)
            make.width.equalTo(64)
            make.height.equalTo(32)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.greaterThanOrEqualTo(10)
            make.height.equalTo(sendBtn)
            make.centerY.equalTo(sendBtn)
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(cancelBtn.snp.bottom).offset(42)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(30)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(textView).offset(5)
            make.width.greaterThanOrEqualTo(10)
            make.height.greaterThanOrEqualTo(10)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(24)
            make.left.right.equalTo(textView)
            make.bottom.equalToSuperview().offset(20)
        }
        
    }
    
    //MARK: 取消
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController()
    }
    
    //MARK: 发送
    @IBAction func sendAction(_ sender: UIButton) {
        
        if textView.text == "" && dataArray.count == 1 && dataArray.last == addImage {
            
            MBProgressHUD_JChat.show(text: "请选择发布内容", view: self.view)
            return
        }
        
        var images = dataArray
        
        if images.last == addImage {
            images.removeLast()
        }
        
        self.view.endEditing(true)
        
        if images.count == 0 {
            modifiedData()
        }else{
            uploadAvata(images: images)
        }
        
        
        
        
//        sendBlock?(dataArray,textView.text)
//        self.navigationController?.popViewController()
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
        
        let imagePickerVC = TZImagePickerController.init(maxImagesCount: 9, delegate: self)
        
        imagePickerVC?.allowPickingVideo = false
        imagePickerVC?.selectedAssets = NSMutableArray.init(array: self.assets)
        imagePickerVC?.showSelectedIndex = true
        imagePickerVC?.isSelectOriginalPhoto = true
        
        //通过block或代理得到用户选择的照片
        imagePickerVC?.didFinishPickingPhotosHandle = {(images,assets,flag) in
            
            self.assets = assets!
            
            self.dataArray = images!
            if self.dataArray.count < 9 {
                self.dataArray.append(self.addImage!)
            }
            
            self.collectionView.reloadData()
        }
        
        
        self.present(imagePickerVC!, animated: true, completion: nil)
    }
    
    //MARK:上传图片
    func uploadAvata(images:[UIImage]){
        
        
        
        let image = images[imageCount]
            
        
            
            AlertClass.waiting("正在上传图片")
            NetworkRequest.requestMethod(.upload, URLString: url_upload, parameters: nil , progress: { (progress) in
                
            }, constructingBodyWith: { (formData) in
                
                guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                    AlertClass.stop()
                    self.imageCount = 0
                    self.imageUrls.removeAll()
                    return
                }
                
                
                let curTime = getCurrentTime().getTimestamp()
                formData.appendPart(withFileData: imageData, name: "file", fileName: "\(curTime).jpeg", mimeType: "image/jpg/png/jpeg")
                
                
                
            }, success: { (value, json) in
                
                
                
               
                
                if json["status"].stringValue == "SUCCESS" {
                    if let ret_data = json["ret_data"].dictionary {
                        let url = ret_data["url"]?.stringValue
                        
                         self.imageCount += 1
                        
                        self.imageUrls.append(url ?? "")
                        
                        if self.imageCount == images.count {
  
                            AlertClass.stop()
                            self.imageCount = 0
                            self.modifiedData(url: self.imageUrls.joined(separator: ","), images: images)
                            self.imageUrls.removeAll()
                        }else{
                            self.uploadAvata(images: images)
                        }
                        
                        
                    }
                }else{
                    
                    AlertClass.stop()
                    self.imageUrls.removeAll()
                    AlertClass.showErrorToat(withJson: json)
                    self.imageCount = 0
                }
                print("***************** 成功-----\(json)")
                
            }) {
                
                self.imageCount = 0
                self.imageUrls.removeAll()
                AlertClass.stop()
            }
        
        
 
        
        
        
    }
    
    //MARK: 发布朋友圈
    func modifiedData(url:String?="",images:[UIImage]?=[UIImage]()){
        let parm:[String : Any] = [
            "contents":textView.text,
            "images":url!
            ]

        AlertClass.waiting("正在发布")

        NetworkRequest.requestMethod(.post, URLString: url_friendCircle, parameters:parm , success: { (value, json) in
            AlertClass.stop()

            if json["status"].stringValue == "SUCCESS" {

                AlertClass.showMessageToat(withJson: json)


                self.sendBlock!()
                self.navigationController?.popViewController()

            }else{
                AlertClass.showErrorToat(withJson: json)
            }
        }) {
            AlertClass.stop()
        }
    }

}

extension SendCircleViewController : UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text == "" {
            tipLabel.isHidden = false
        }else{
            tipLabel.isHidden = true
        }
        
        self.view.layoutIfNeeded()
        
        var height = textView.text.size(font: 16, width: ScreenW-64).height
        if height > 150 {
            height = 150
        }
        
        textView.snp.remakeConstraints { (make) in
            make.top.equalTo(cancelBtn.snp.bottom).offset(42)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? FirendCircleImageCell
        
        cell?.imageView.image = dataArray[indexPath.row]
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        self.view.endEditing(true)
        
        if dataArray[indexPath.row] == addImage! {
            let selectPhotoVC = SelectPhotoViewController()
            selectPhotoVC.modalPresentationStyle = .overCurrentContext
            selectPhotoVC.photoBlock = {(title) in
                
                if title == "从手机相册选择" {
                    
                    self.selectFromAlbum()
                    
                }else if title == "拍摄" {
                    
                    self.present(self.imagePicker, animated: true, completion: nil)
                    
//                    let config = VideoRecordConfig.defaultConfigure()
//                    let recordVC = FriendCircleTakePhotoVC.init(configure: config!)
//                    let recordVC = FriendCircleTakePhotoVC()
//                    let nav = CTNavigationController.init(rootViewController: recordVC)
//                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
                
            }
            self.present(selectPhotoVC, animated: false, completion: nil)
        }else{
            
            var array = dataArray
            
            if dataArray.last == addImage {
                array.removeLast()
            }
            
            let imagePickerVC = TZImagePickerController.init(selectedAssets: NSMutableArray.init(array: assets), selectedPhotos: NSMutableArray.init(array: dataArray), index: indexPath.item)
            imagePickerVC?.allowPickingVideo = false
            imagePickerVC?.selectedAssets = NSMutableArray.init(array: assets)
            imagePickerVC?.showSelectedIndex = true
            imagePickerVC?.maxImagesCount = 9
            imagePickerVC?.isSelectOriginalPhoto = true
            
            //通过block或代理得到用户选择的照片
            imagePickerVC?.didFinishPickingPhotosHandle = {(images,assets,flag) in
                
                self.assets = assets!
                self.dataArray = images!
                if self.dataArray.count < 9 && self.dataArray.last != self.addImage! {
                    self.dataArray.append(self.addImage!)
                }
                self.collectionView.reloadData()
            }
            
            self.present(imagePickerVC!, animated: true, completion: nil)
            
//            let browser = WMPhotoBrowser()
//            browser.dataSource = NSMutableArray.init(array: array)
//            browser.downLoadNeeded = true
//            browser.currentPhotoIndex = indexPath.row
//            self.present(browser, animated: true, completion: nil)
        }

        
        
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: (ScreenW-84)/3, height: (ScreenW-84)/3)
    }
}

extension SendCircleViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate,TZImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let headImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        dataArray.insert(headImage!, at: 0)
    
        
        collectionView.reloadData()
        
        
        self.dismiss(animated: true, completion: nil)
    }
}
