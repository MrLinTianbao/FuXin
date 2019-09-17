//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class TransferAccountsVC: CTViewController {
    let addImage = UIImage.init(named: "上传截图按钮")
    var dataArray = [UIImage]()
    var selectedAssets =  [Any]()
    let maxImagesCount =  9
    
    var payType = "0" //支付类型
    
    fileprivate var v = TransferAccountsHeadView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLocalData()
        self.setUIAppearance()
        getRechargeCode()
    }
    
    func setLocalData(){
        dataArray.append(addImage!)
    }
    func setUIAppearance(){
        
        tipsLabel.textColor = UIColor.red
        
        self.view.addSubview(tipsLabel)
        self.view.addSubview(btnConfrim)
        self.view.addSubview(clvData)

        self.view.backgroundColor = UIColor.KTheme.scroll
        
        tipsLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-26)
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
            make.height.greaterThanOrEqualTo(10)
        }
        
        btnConfrim.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(tipsLabel.snp.top).offset(-10)
            make.left.right.equalTo(tipsLabel)
            make.height.equalTo(50)
        }

        clvData.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(btnConfrim.snp.top)
        }
        
        self.title = "转账充值"
        
    }
//    //MARK: 从相册选择
//    fileprivate func selectFromAlbum() {
//
//        let imagePickerVC = TZImagePickerController.init(maxImagesCount: maxImagesCount, delegate: nil)
//        imagePickerVC?.allowPickingVideo = false
//        imagePickerVC?.selectedAssets = NSMutableArray.init(array: selectedAssets)
//
//        //通过block或代理得到用户选择的照片
//        imagePickerVC?.didFinishPickingPhotosHandle = {(images,assets,flag) in
//
//            self.selectedAssets = assets!
//            self.dataArray = images!
//            if self.dataArray.count < self.maxImagesCount {
//                self.dataArray.append(self.addImage!)
//            }
//
//            self.clvData.reloadData()
//        }
//
//        self.present(imagePickerVC!, animated: true, completion: nil)
//    }
    
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
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        let temp_mediaType = UIImagePickerController.availableMediaTypes(for: picker.sourceType)
        picker.mediaTypes = temp_mediaType!
        picker.allowsEditing = true
        picker.modalTransitionStyle = .coverVertical
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: **************************** 懒加载
    lazy var btnConfrim: MJButton = {
        
        let button = MJButton ()
        button.isClickEnabled = true
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
      
        button.addTarget(self, action: #selector(clickBtn1), for: .touchUpInside)
        
        return button
    }()
    
    lazy var tipsLabel : UILabel = {
        
        let label = UILabel()
        label.text = "温馨提示:可充值马币或充值人民币，充值时间每天9:00-01:00，充值请先联系客服配置收款二维码。"
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    @objc func clickBtn1(_ sender:UIButton){
        
        if v.tfMoney.text == "" {
            
            MBProgressHUD_JChat.show(text: "请输入金额", view: self.view)
            return
        }
        
        if Int(v.tfMoney.text!) == nil {
            MBProgressHUD_JChat.show(text: "请输入正确的金额", view: self.view)
            return
        }
        
        if Int(v.tfMoney.text!) ?? 0 < 50  {
            MBProgressHUD_JChat.show(text: "充值金额不能少于50", view: self.view)
            return
        }
        
        var images = dataArray
        
        if images.last == addImage {
            images.removeLast()
        }
        
        if images.count == 0 {
            MBProgressHUD_JChat.show(text: "请选择图片进行验证", view: self.view)
            return
        }
        
        uploadAvata(image: dataArray.last!)
        
    }
    
    //MARK: 获取付款二维码
    fileprivate func getRechargeCode() {
        
        NetworkRequest.requestMethod(.get, URLString: url_rechargeCode, parameters: nil, success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                self.v.imvIcon.setUrlImage(with: json["ret_data"]["receivables_qrcode"].stringValue, placeholder: UIImage.init(named: ""))
            }
            
        }) {
            
            
        }
    }
  
    
    lazy var clvData: UICollectionView = {
        let space:CGFloat = 15.0
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: space, right: space)
        layout.minimumInteritemSpacing = space //列与列之间的间距
        layout.minimumLineSpacing = space //行与行之间的间距
        let width = (ScreenW - space*4)/3
        layout.itemSize = CGSize.init(width: width, height: width)
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.KTheme.scroll
        collectionView.delegate = self;
        collectionView.dataSource = self;
        let cell = UINib.init(nibName: "KSampleClvCell", bundle: nil)
        collectionView.register(cell, forCellWithReuseIdentifier: "KSampleClvCell")
        
        let secionHead = UINib.init(nibName: "TransferAccountsHeadView", bundle: nil)
        collectionView.register(secionHead, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TransferAccountsHeadView")

        //420
        
        return collectionView
    }()

    
}
extension TransferAccountsVC: UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KSampleClvCell", for: indexPath) as! KSampleClvCell
        cell.imvIcon.image = dataArray[indexPath.row]
        cell.imvIcon.contentMode = .scaleAspectFill
        cell.imvIcon.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        self.view.endEditing(true)
        
//        if dataArray[indexPath.row] == addImage! {
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
//        }else{
//
//            var array = dataArray
//
//            if dataArray.last == addImage {
//                array.removeLast()
//            }
//
//            let imagePickerVC = TZImagePickerController.init(selectedAssets: NSMutableArray.init(array: selectedAssets), selectedPhotos: NSMutableArray.init(array: array), index: indexPath.item)
//            imagePickerVC?.allowPickingVideo = false
//            imagePickerVC?.selectedAssets = NSMutableArray.init(array: selectedAssets)
//            imagePickerVC?.showSelectedIndex = true
//            imagePickerVC?.maxImagesCount = maxImagesCount
//            imagePickerVC?.isSelectOriginalPhoto = true
//
//            //通过block或代理得到用户选择的照片
//            imagePickerVC?.didFinishPickingPhotosHandle = {(images,assets,flag) in
//
//                self.selectedAssets = assets!
//                self.dataArray = images!
//                if self.dataArray.count < self.maxImagesCount {
//                    self.dataArray.append(self.addImage!)
//                }
//                self.clvData.reloadData()
//            }
//
//            self.present(imagePickerVC!, animated: true, completion: nil)
//
//
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        
        if kind == UICollectionView.elementKindSectionHeader
        {
            v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TransferAccountsHeadView", for: indexPath)as! TransferAccountsHeadView
            v.labName.text = CacheClass.stringForEnumKey(.nickname)
            v.labID.text = String(JMSGUser.myInfo().uid)
        }
        
        return v
    }
    /* sectionHeadView 尺寸*/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        
        return CGSize(width: ScreenW, height: 420)
    }
}

extension TransferAccountsVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let headImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        
        self.dataArray = [headImage!]
        clvData.reloadData()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func uploadAvata(image:UIImage){
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        AlertClass.waiting("正在上传截图")
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
            "voucher":url,
            "amount":v.tfMoney.text!,
            ]
        
        AlertClass.waiting("正在充值")
        
        NetworkRequest.requestMethod(.post, URLString: url_TransferRecharge, parameters:parm , success: { (value, json) in
            AlertClass.stop()
            
            if json["status"].stringValue == "SUCCESS" {
                
                AlertClass.showMessageToat(withJson: json)
                
                
                
                
            }else{
                AlertClass.showErrorToat(withJson: json)
            }
        }) {
            AlertClass.stop()
        }
    }
}
