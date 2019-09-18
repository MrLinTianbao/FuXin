//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class MineInfoSetVC: CTViewController {
    let dataArray = ["头像","昵称","ID","我的二维码","手机"]
    var headCell:MineInfoTbvCell?
    var nameCell:MineInfoTitleTbvCell?
    var idCell:DistributionRecordTbvCell?
    var codeCell:MineInfoTbvCell?
    var phoneCell:DistributionRecordTbvCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUIAppearance()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tbvData.reloadData()
    }
    func setUIAppearance(){
        self.title = "个人资料"
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
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
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        let temp_mediaType = UIImagePickerController.availableMediaTypes(for: picker.sourceType)
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        picker.modalTransitionStyle = .coverVertical
        present(picker, animated: true, completion: nil)
    }
    //MARK: **************************** 懒加载
    lazy var tbvData: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 63
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.KTheme.line
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
      
        
        return tableView
    }()
    
    
}
extension MineInfoSetVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let headImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        

        self.dismiss(animated: true) {
            self.uploadAvata(image: headImage!)
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
            "avatar":url,
            "method":"PUT",
            ]
        
        AlertClass.waiting("正在更新头像")
        
        NetworkRequest.requestMethod(.post, URLString: url_signUp, parameters:parm , success: { (value, json) in
            AlertClass.stop()

            if json["status"].stringValue == "SUCCESS" {
                AlertClass.showMessageToat(withJson: json)
                CacheClass.setObject(url, forEnumKey: .avatar)
                self.headCell?.imvIcon.image = UIImage.init(data: imageData)
                
                //上传到IM
                JMSGUser.updateMyAvatar(with: imageData, avatarFormat: "", completionHandler: { (resultObject, error) in
                    if error == nil {
                        JMSGUser.myInfo().thumbAvatarData({ (data, id, error) in
                            if let data = data {
                                let imageData = NSKeyedArchiver.archivedData(withRootObject: data)
                                UserDefaults.standard.set(imageData, forKey: kLastUserAvator)
                            } else {
                                UserDefaults.standard.removeObject(forKey: kLastUserAvator)
                            }
                        })
                    } else {
                    }
                })
                
                
            }else{
                AlertClass.showErrorToat(withJson: json)
            }
        }) {
            AlertClass.stop()
        }
    }
   
    
    
}
extension MineInfoSetVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var simCell = UITableViewCell()
        if indexPath.section == 0 && indexPath.row == 0 {
            if headCell == nil{
                headCell = (Bundle.main.loadNibNamed("MineInfoTbvCell", owner: self, options: nil)?.last as! MineInfoTbvCell)
            }
            headCell?.labTitle.text = dataArray[indexPath.row]
            headCell?.labTitle.font = UIFont.systemFont(ofSize: 16)
            headCell?.imvIconW.constant = 60
            headCell?.imvIconH.constant = 60
            headCell?.imvIcon.setUrlImage(with: (CacheClass.stringForEnumKey(.avatar) ?? ""), placeholder: chatDefaultHead)
            headCell?.imvIcon.setCornerRadius(5)
            simCell = headCell!
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            if nameCell == nil{
                nameCell = (Bundle.main.loadNibNamed("MineInfoTitleTbvCell", owner: self, options: nil)?.last as! MineInfoTitleTbvCell)
                nameCell?.labTitle.text = dataArray[indexPath.row]
            }
            nameCell?.labSubTitle.text = CacheClass.stringForEnumKey(.nickname)
            simCell = nameCell!
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            if idCell == nil{
                idCell = (Bundle.main.loadNibNamed("DistributionRecordTbvCell", owner: self, options: nil)?.last as! DistributionRecordTbvCell)
                idCell?.labSubTitle.textColor = UIColor.KTheme.shallowGray
                idCell?.labTitle.text = dataArray[indexPath.row]
            }
            idCell?.labSubTitle.text = CacheClass.stringForEnumKey(.username)
            simCell = idCell!
        }
        if indexPath.section == 0 && indexPath.row == 3 {
            if codeCell == nil{
                codeCell = (Bundle.main.loadNibNamed("MineInfoTbvCell", owner: self, options: nil)?.last as! MineInfoTbvCell)
            }
            codeCell?.labTitle.text = dataArray[indexPath.row]
            simCell = codeCell!
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            if phoneCell == nil{
                phoneCell = (Bundle.main.loadNibNamed("DistributionRecordTbvCell", owner: self, options: nil)?.last as! DistributionRecordTbvCell)
                phoneCell?.labTitle.text = dataArray[indexPath.row]
                phoneCell?.labSubTitle.textColor = UIColor.KTheme.shallowGray
            }
             phoneCell?.labSubTitle.text = (CacheClass.stringForEnumKey(.mobile_code) ?? "") + " " + (CacheClass.stringForEnumKey(.mobile) ?? "")
            simCell = phoneCell!
        }
        return simCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 108
        }else{
            return 56
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            self.pushViewController(targetStr: "ChangeUserNameVC")
        }
        if indexPath.row == 3 {
            self.pushViewController(targetStr: "UserQRCodeVC")
        }
        if indexPath.row == 0 {
            
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
        
        
        
    }
    
}
