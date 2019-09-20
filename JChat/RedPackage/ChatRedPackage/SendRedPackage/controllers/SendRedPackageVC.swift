//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class SendRedPackageVC: CTViewController {
    
    var gid = "" //群id
    
    var rewardAmount = "" //奖励金额
    
    fileprivate let cellId = "rayCell"
    
    fileprivate var  raySum = 10 //雷总数
    
    fileprivate var rayArray = [String]() //选中的雷数组
    
    fileprivate var collectionView : UICollectionView!
    
    var redBlock : ((String,String,String,String)->Void)?
    
    fileprivate var redType = "1" //红包类型
    fileprivate var rayCount = 1 //7包雷数量
    fileprivate var rayCount2 = 3 //9包雷数量
    
    @IBOutlet weak var view9: UIView!
    @IBOutlet weak var view7: UIView!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    
    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var btnConfirm: MJButton!
    @IBOutlet weak var tfMoney: MJUITextField!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var tfTips: MJUITextField!
    
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var vewLei: UIView!
    
    @IBOutlet weak var tipLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    @objc func textValueChanged(){
        btnConfirm.isClickEnabled = !(tfMoney.isEmpty)
        
        tfTips.text = String(Float(self.tfMoney.text!) ?? 0) + "/" +  self.rayArray.joined(separator: "")
        
        labMoney.text = "¥ " + String(Float(tfMoney.text!) ?? 0)
        
        if labMoney.text == "¥ " {
            labMoney.text = "¥ 0.00"
        }
    }
    @objc func onConfirmBtnClicked(){
        
        if Float(tfMoney.text!) ?? 0 < 10 {
            MBProgressHUD_JChat.show(text: "红包金额不能少于10", view: self.view)
            return
        }
        
        if Float(tfMoney.text!) ?? 0 > 500 {
            MBProgressHUD_JChat.show(text: "红包金额不能大于500", view: self.view)
            return
        }
        
        if redType == "0" {
            
            if self.rayArray.count != rayCount {
                MBProgressHUD_JChat.show(text: "埋雷尾数数量必须与雷数相同", view: self.view)
                return
            }
            
        }else if redType == "1" {
            
            if self.rayArray.count != rayCount2 {
                MBProgressHUD_JChat.show(text: "埋雷尾数数量必须与雷数相同", view: self.view)
                return
            }
        }
        
        let pay_pass = CacheClass.boolForEnumKey(.pay_pass) ?? false
        if !pay_pass {
            
            AlertClass.setAlertView(msg: "你还没有设置支付密码", target: self, actionTitle: "去设置", cancelTitle:"取消", haveCancel: true) { (alert) in
                
                self.navigationController?.pushViewController(ForgetPayPasswardVC())
            }
            
            return
        }
        
//        let money = CGFloat(Float(tfMoney.text!) ?? 0) - CGFloat(Float(self.tipLabel.text ?? "0") ?? 0)
        
        var amount = self.tfMoney.text!
        //优惠计算
        if let reward = Float(self.rewardAmount) {
            
            if let money = Float(self.tfMoney.text!) {
                amount = String(format: "%.2f", (money - money * reward/100))
            }
        }
        
        
        KAlertPayPawView.showAlertPayPawView(money: CGFloat(amount.double() ?? 0), type: nil, completion: { (paw,alertView) in
            if self.tfTips.text == "" {
                self.tfTips.text = self.tfTips.placeholder
            }
            
            
            
            let passwordStr = RSA.encryptString(paw, publicKey: publicKey)
            
            let rayNumber = self.redType == "0" ? self.rayCount : self.rayCount2
            
            self.rayArray.sort { (a1, a2) -> Bool in
                
                return a1 < a2
            }
            
            let ray_sum = self.rayArray.joined(separator: ",")
            
            let tipText = String(Int(self.tfMoney.text!) ?? 0) + "/" +  self.rayArray.joined(separator: "")
            
            AlertClass.waiting("正在支付")
            self.view.endEditing(true)
            
            
            
            NetworkRequest.requestMethod(.post, URLString: url_sendRayRed, parameters: ["amount":Float(self.tfMoney.text!) ?? 0,"blessing":tipText,"pay_pass":passwordStr ?? "","type":self.redType,"number":"\(rayNumber)","mantissa":ray_sum,"group_id":self.gid,"send_user_id":"\(JMSGUser.myInfo().uid)","send_nickname":JMSGUser.myInfo().username], success: { (value, json) in
                
                AlertClass.stop()
                    
                if json["status"].stringValue == "SUCCESS" {
                    
                    alertView.dismiss()
                    self.sendRed(redUid: json["ret_data"]["id"].stringValue)
                    
                }else{
                    
                    SVProgressHUD.showError(withStatus: json["error"].stringValue)
                    
                }
                
                
            }) {
                
                AlertClass.stop()
            }
            
            alertView.dismiss()
            
            

        })
        
    }
    override func actionLeftItemClick() {
        self.dismiss(animated: true, completion: nil)
        
    }
    func setUIAppearance(){
        self.title = "发红包"
        self.view.backgroundColor = UIColor.KTheme.scroll
        
        getSystemRed()
        
        self.setNavLeftItem(title: "取消")
        
        tfMoney.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        tfTips.addTarget(self, action: #selector(self.textValueChanged), for: .editingChanged)
        btnConfirm.addTarget(self, action: #selector(self.onConfirmBtnClicked), for: .touchUpInside)


        self.setButtonUI(sender: btn7,tag:100+7)
        self.setButtonUI(sender: btn9,tag:100+9)
        self.setButtonUI(sender: btn3,tag:100+3)
        self.setButtonUI(sender: btn4,tag:100+4)
        self.setButtonUI(sender: btn5,tag:100+5)
        self.setButtonUI(sender: btn6,tag:100+6)
        self.setButtonUI(sender: btn1,tag:100+1)
        self.setButtonUI(sender: btn2,tag:100+2)
        
        btn7.isSelected = false
        btn9.isSelected = true
        
        btn1.isSelected = true
        btn2.isSelected = false
        
        btn3.isSelected = true
        btn4.isSelected = false
        btn5.isSelected = false
        btn6.isSelected = false
        
        btn7.addTarget(self, action: #selector(self.onOneRowBtnClicked), for: .touchUpInside)
        btn9.addTarget(self, action: #selector(self.onOneRowBtnClicked), for: .touchUpInside)

        btn3.addTarget(self, action: #selector(self.onTwoRowBtnClicked), for: .touchUpInside)
        btn4.addTarget(self, action: #selector(self.onTwoRowBtnClicked), for: .touchUpInside)
        btn5.addTarget(self, action: #selector(self.onTwoRowBtnClicked), for: .touchUpInside)
        btn6.addTarget(self, action: #selector(self.onTwoRowBtnClicked), for: .touchUpInside)

        btn1.addTarget(self, action: #selector(self.onSingleRowBtnClicked(_:)), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(self.onSingleRowBtnClicked(_:)), for: .touchUpInside)
        
      
        let w = ScreenW - 28*2
        let h = vewLei.height
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: .init(x: 0, y: 0, width: w, height: h), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register( UINib.init(nibName: "RayCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        vewLei.addSubview(collectionView)
        
        
//        for i in 0..<10 {
//            let button = UIButton ()
//            button.setTitle("\(i)", for: .normal)
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//            button.setTitleColor(UIColor.init(hexString: "#E97C95"), for: .selected)
//            button.backgroundColor = UIColor.white
//            button.setTitleColor(UIColor.init(hexString: "#C9C9C9"), for: .normal)
//            button.tag = 200+i
//            button.frame = CGRect.init(x: CGFloat(i) * w, y: 0, width: w, height: h)
//            button.addTarget(self, action: #selector(self.onTreeRowBtnClicked), for: .touchUpInside)
//
//            vewLei.addSubview(button)
//            if i == 0 || i == 3 || i == 7 {
//                button.isSelected = true
//            }
//        }
        
    }
    @objc func onTreeRowBtnClicked(_ sender:UIButton){
       
        sender.isSelected = !sender.isSelected
        
        
    }
    @objc func onTwoRowBtnClicked(_ sender:UIButton){
        btn3.isSelected = false
        btn4.isSelected = false
        btn5.isSelected = false
        btn6.isSelected = false
        
        sender.isSelected = true
        
        rayCount2 = sender.tag - 100
        
        self.rayArray.removeAll()
        self.collectionView.reloadData()
        
    }
    
    @objc func onOneRowBtnClicked(_ sender:UIButton){
        btn7.isSelected = false
        btn9.isSelected = false
        
        sender.isSelected = true
        
        self.rayArray.removeAll()
        self.collectionView.reloadData()

    }
    
    @objc func onSingleRowBtnClicked(_ sender:UIButton){
        
        btn1.isSelected = false
        btn2.isSelected = false
        
        sender.isSelected = true
        
        rayCount = sender.tag - 100
        
        self.rayArray.removeAll()
        self.collectionView.reloadData()
    }
    
    func setButtonUI(sender:UIButton,tag:Int){
        sender.tag = tag
        let orgImg = UIImage.imageWithColor(UIColor.KTheme.deepOrange)
        let whiteImg = UIImage.imageWithColor(UIColor.white)
        sender.setTitleColor(UIColor.init(hexString: "#E97C95"), for: .normal)
        sender.setBackgroundImage(whiteImg, for: .normal)
        sender.setTitleColor(UIColor.white, for: .selected)
        sender.setBackgroundImage(orgImg, for: .selected)
    }
    
    //MARK: 获取红包规则
    fileprivate func getSystemRed() {
        
        NetworkRequest.requestMethod(.get, URLString: url_systemRed, parameters: nil, success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let gifts = json["ret_data"]["outsourcing_gifts"].string {
                    self.tipLabel.text = "\(gifts)%的优惠"
                    self.rewardAmount = gifts
                }
                
                
            }
            
        }) {
            
            
        }
    }
    
    //MARK: 发红包
    fileprivate func sendRed(redUid:String) {
        
        var tipStr = self.tfTips.text?.trimed()
        
        if tipStr == "" {
            tipStr = tfTips.placeholder
        }
        
        let hb_number = self.redType == "1" ? "9" : "7"
        
        self.redBlock?(self.tfMoney.text!,String(Int(self.tfMoney.text!) ?? 0) + "/" +  self.rayArray.joined(separator: ""), redUid, hb_number)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    //MARK: 7包
    @IBAction func sevenPackage(_ sender: UIButton) {
        
        self.redType = "0"
        view7.isHidden = false
        view9.isHidden = true
        
        
    }
    
    //MARK: 9包
    @IBAction func nightPackage(_ sender: UIButton) {
        
        self.redType = "1"
        view7.isHidden = true
        view9.isHidden = false
        
        
    }
    
    
}

extension SendRedPackageVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return raySum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? RayCell
        
        cell?.rayBtn.setTitle("\(indexPath.row)", for: .normal)
        
        if rayArray.count == 0 {
            cell?.isSelect = false
            cell?.rayBtn.setTitleColor(UIColor.KTheme.shallowGray, for: .normal)
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! RayCell
        
        
    if self.redType == "1" {
        if self.rayArray.count >= rayCount2 && !cell.isSelect {
            MBProgressHUD_JChat.show(text: "最多只能埋\(rayCount2)个雷", view: self.view)
            return
        }
    }else{
        if self.rayArray.count >= rayCount && !cell.isSelect {
            MBProgressHUD_JChat.show(text: "最多只能埋\(rayCount)个雷", view: self.view)
            return
        }
    }
    
        
        cell.isSelect = !cell.isSelect
        
        if cell.isSelect {
            cell.rayBtn.setTitleColor(UIColor.init(hexString: "#E97C95"), for: .normal)
            rayArray.append("\(indexPath.row)")
        }else{
            cell.rayBtn.setTitleColor(UIColor.KTheme.shallowGray, for: .normal)
            if let index = rayArray.index(of: "\(indexPath.row)") {
                rayArray.remove(at: index)
            }
        }
        
        self.rayArray.sort { (a1, a2) -> Bool in
            
            return a1 < a2
        }
        
        if self.rayArray.count == 0 {
            tfTips.text = ""
        }else{
            tfTips.text = String(Int(self.tfMoney.text!) ?? 0) + "/" +  self.rayArray.joined(separator: "")
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let w = (ScreenW - 28*2)/CGFloat(raySum)
        let h = vewLei.height
        
        return CGSize.init(width: w, height: h)
    }
    
}
