//
//  String+Extend.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    /**
     获取文本范围
     */
    public func size(font : CGFloat ,  width:CGFloat) -> CGSize{
        let size = NSString.init(string: self).boundingRect(with: .init(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: font)], context: nil).size
        return CGSize.init(width: size.width + 10, height: size.height + 10)
    }
    
    public func size(font : CGFloat ,  height :CGFloat) -> CGSize{
        let size = NSString.init(string: self).boundingRect(with: .init(width: CGFloat.greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: font)], context: nil).size
        return CGSize.init(width: size.width + 10, height: size.height + 10)
    }
    
    //MARK: 字体样式
    public func setTextFont(isBold:Bool?=false,color:UIColor?=UIColor.black,fontSize:CGFloat,ranStr:String) -> NSAttributedString {
        
        var font : UIFont!
        
        //是否加粗
        if isBold! {
            font = UIFont.boldSystemFont(ofSize: RATIO(maxNum: fontSize))
        }else{
            font = UIFont.systemFont(ofSize: RATIO(maxNum: fontSize))
        }
        
        let str = NSMutableAttributedString.init(string: self)
        let range = (self as NSString).range(of: ranStr)
        str.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        str.addAttribute(NSAttributedString.Key.foregroundColor, value: color!, range: range)
        return str
    }
    
    //MARK: 时间戳转时间
    public func getDate() -> String {
        
        let date = Date.init(timeIntervalSince1970: Double(self)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // HH:mm:ss
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    
    //MARK: 时间转时间戳
    public func getTimestamp() -> Double {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        let last = formatter.date(from: self)
        let timeStamp = last?.timeIntervalSince1970
        
        return timeStamp ?? 0
    }
    
    //MARK: 获取时间单位
    func getTimeUint(type:TimeType) -> String {
        
        let timeTamp = self.getTimestamp()
        
        let date = Date.init(timeIntervalSince1970: timeTamp)
        let formatter = DateFormatter()
        
        switch type {
        case .year:
          formatter.dateFormat = "yyyy"
        case .month:
           formatter.dateFormat = "MM"
        case .day:
            formatter.dateFormat = "dd"
        case .hours:
            formatter.dateFormat = "HH"
        case .minutes:
            formatter.dateFormat = "mm"
        case .seconds:
            formatter.dateFormat = "ss"
        }
        
        
        
        let dateString = formatter.string(from: date)
        
        return dateString
    }
}

extension String {
    //MARK: ********************************************************  字符串操作
    func mj_date(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    func mj_stringConvertToDateBy(format:String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        let last = formatter.date(from: self)
        let timeStamp = last?.timeIntervalSince1970
        
        return timeStamp ?? 0
    }
    /// 截取字符串
    ///
    /// - Returns: String
    func mj_stringBy(previousString:String,laterString:String) -> String? {
        let start = self.range(of: previousString)
        let end = self.range(of: laterString)
        
        let index = (start?.upperBound.encodedOffset)!
        let length = (end?.lowerBound.encodedOffset)! - index
        let subStr = self.slicing(from: index, length: length)
        
        return subStr
        
    }
    /*
     *去掉所有空格
     */
    var mj_removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    /// json 字符串转字典
    ///
    /// - Returns: 字典
    func mj_stringConvertToDictionary() -> [String : Any]? {
        
        let jsonData: Data? = data(using: .utf8)
        var dic: [String : Any]? = nil
        if let jsonData = jsonData {
            
            dic = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String : Any]
            
        }
        
        return dic
    }
}
