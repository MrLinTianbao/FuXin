//
//  MyUrlString.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import Foundation
import Localize_Swift

var host: String = "www.fuxin.in"

var socketPort: UInt16 = 58282

var urlStr : String {
    #if DEBUG
    return "https://" + host + "/?c=rest&a=v1&api="
    #else
    return "https://" + host + "/?c=rest&a=v1&api="
    #endif
    
}

//MARK: 注册
var url_signUp = urlStr + "User"
//MARK: 登录
var url_signIn = urlStr + "Login"
//MARK: 绑定IM
var url_bindIM = urlStr + "User.bindIM"
//MARK: 注册验证码
var url_signUpCode = urlStr + "Captcha.register"
//MARK: 忘记密码
var url_forgetPassword = urlStr + "User.restPassword"
//MARK: 忘记密码验证码
var url_forgetPwCode = urlStr + "Captcha.changePassword"
//MARK: 微信登录
var url_wechat = urlStr + "WeiXin.login"
//MARK: 绑定手机号码
var url_bindPhone = urlStr + "User.bindMobile"
//MARK: 获取个人资料的api
var url_getUserNews = urlStr + "User"
//MARK: 充值
var url_recharge = urlStr + "User.Recharge"
//MARK: 红包规则配置信息
var url_systemRed = urlStr + "SystemRed"
//MARK: 发红包
var url_sendRed = urlStr + "Red"
//MARK: 发送雷红包
var url_sendRayRed = urlStr + "RedThunder"
//MARK: 获取公告列表
var url_notice = urlStr + "advertising_management"
//MARK: 获取加好友验证
var url_addFriValidation = urlStr + "User.isAddingFriendCertification"
//MARK: 修改密码
var url_changePw = urlStr + "User.changePassword"
//MARK: 获取关于我们
var url_aboutUs = urlStr + "content_management_148"
//MARK: 订单支付查询
var url_PayStatus = urlStr + "Pays.query"
//MARK: 修改支付密码
var url_changePayPW = urlStr + "User.changePayPassword"
//MARK: 发有雷红包
var url_sendGroupRed = urlStr + "RedThunder"
//MARK: 我的客服列表
var url_myServiceList = urlStr + "Member_CustomerService"
//MARK: 获取用户账单流水
var url_billDetails = urlStr + "Member_AccountFlow"
//MARK: 提现申请
var url_withdrawDeposit = urlStr + "Withdrawals"
//MARK: 转账充值
var url_TransferRecharge = urlStr + "TransferRecharge"
//MARK: 获取付款二维码
var url_rechargeCode = urlStr + "System"
//MARK: 获取朋友圈列表,发布朋友圈
var url_friendCircle = urlStr + "CircleOfFriends"
//MARK: 获取交易记录
var url_invitationRecord = urlStr + "User.invitationRecord"
