//
//  MJTbvColorHeadView.swift
//  XLCustomer
//
//  Created by longma on 2019/1/8.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

protocol RecorderTakeToolViewDelegate: class {
     func onTakePhotoBtnClicked()
     func onBackBtnClicked()
    
     func onDoneBtnClicked()
     func onReturnBtnClicked()
     func onRecordTypeBtnClicked()
     func onBtnRecordStartClicked()
    
}

class RecorderTakeToolView: UIView {
    weak var delegate:RecorderTakeToolViewDelegate?
    let btn_W:CGFloat = 60
    @IBOutlet weak var viewDoneBg: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnReturn: UIButton!
    @IBOutlet weak var btnCameraFront: UIButton!
    @IBOutlet weak var btnTakePhoto: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    //是否前置
    var _cameraFront:Bool = false
    
    @IBOutlet weak var btnStartRecord: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnCameraFront.addTarget(self, action: #selector(onCameraFrontBtnClicked), for: .touchUpInside)
        btnTakePhoto.addTarget(self, action: #selector(onTakePhotoBtnClicked), for: .touchUpInside)
        btnBack.addTarget(self, action: #selector(onBackBtnClicked), for: .touchUpInside)

        btnDone.addTarget(self, action: #selector(onDoneBtnClicked), for: .touchUpInside)
        btnReturn.addTarget(self, action: #selector(onReturnBtnClicked), for: .touchUpInside)
        btnStartRecord.addTarget(self, action: #selector(onBtnRecordStartClicked), for: .touchUpInside)
        viewDoneBg.isHidden = true
        btnStartRecord.isHidden = true

        self.setUIAppearance()

        
    }
    @objc func onBtnRecordStartClicked(){
        self.delegate?.onBtnRecordStartClicked()
    }
    func setUIAppearance(){
        
        self.addSubview(pageTitleView)
        self.setButtonAppearance()
        
    }
    func setButtonAppearance(){
        let titleArray = ["拍照","录像"]
        
        let btn_H:CGFloat = pageTitleView.height
        var b_x = ScreenW/2 - btn_W / 2
        for i in 0..<2 {
            let button = UIButton(frame: CGRect.zero)
            
            button.frame = CGRect(x: b_x, y: 0, width: btn_W, height: btn_H)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.backgroundColor = UIColor.clear
            button.setTitle(titleArray[i], for: .normal)
            button.setTitleColor(UIColor.KTheme.deepOrange, for: .selected)//设置默认颜色
            button.setTitleColor(UIColor.white, for: .normal) //设置选中颜色
            button.addTarget(self, action: #selector(self.titleBtnClick), for: .touchUpInside)
            button.tag = 100 + i
            pageTitleView.addSubview(button)
            if i == 0 {
                button.isSelected = true
                self.tempBtn = button
            }
            b_x = btn_W + b_x
        }
    }
    lazy var pageTitleView: UIScrollView = {
        
        let scrollView = UIScrollView ()
        scrollView.frame = CGRect.init(x: 0, y: 0, width: ScreenW, height: 50)
        scrollView.backgroundColor = UIColor.clear
        scrollView.contentSize = CGSize.init(width: ScreenW * 2 , height: 50)
        scrollView.isScrollEnabled = false
        return scrollView
        
    }()
    lazy var tempBtn : UIButton = {
        let btn = UIButton()
        return btn
    }()
    @objc func titleBtnClick(sender:UIButton){

        if self.tempBtn != sender {
            self.tempBtn.isSelected = !self.tempBtn.isSelected
            sender.isSelected = true
            self.tempBtn = sender
            
            //偏移
            let tag = sender.tag - 100
            let rightOffset = CGPoint(x: CGFloat(tag) * btn_W, y: 0)
            pageTitleView.setContentOffset(rightOffset, animated: true)
            
            self.delegate?.onRecordTypeBtnClicked()
            
            if tag == 0 {
                btnTakePhoto.isHidden = false
                btnStartRecord.isHidden = true
            }else{
                btnTakePhoto.isHidden =  true
                btnStartRecord.isHidden = false
            }
        }
        
       
        
    }
    
    
    @objc func onDoneBtnClicked(_ sender:UIButton){
        self.delegate?.onDoneBtnClicked()
    }
    @objc func onReturnBtnClicked(_ sender:UIButton){
        viewDoneBg.isHidden = true
        self.delegate?.onReturnBtnClicked()
    }
    
    
    @objc func onTakePhotoBtnClicked(_ sender:UIButton){
        viewDoneBg.isHidden = false

        self.delegate?.onTakePhotoBtnClicked()
    }
    @objc func onBackBtnClicked(_ sender:UIButton){
        self.delegate?.onBackBtnClicked()
    }
    @objc func onCameraFrontBtnClicked(_ sender:UIButton){
        _cameraFront = !_cameraFront
        
//        TXUGCRecord.shareInstance()?.switchCamera(_cameraFront)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
   
   
    
    
    
    
}
