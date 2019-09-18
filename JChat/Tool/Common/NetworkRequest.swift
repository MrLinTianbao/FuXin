//
//  NetworkRequest.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import Alamofire

class NetworkRequest: NSObject {

    internal static var manager : AFHTTPSessionManager {
        
        ///设置网络请求超时时间
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        
        let manager = AFHTTPSessionManager.init(sessionConfiguration: configuration)
        
        //数据格式
        manager.responseSerializer.acceptableContentTypes = NSSet.init(objects: ["text/html","application/json","text/json","text/javascript"]) as? Set<String>
        manager.requestSerializer.setValue(CacheClass.stringForEnumKey(.token) ?? "", forHTTPHeaderField: "Authentication") //请求头
        return manager
    }
    
    
    
    
    // MARK: - 网络请求
    /// 网络请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - URLString: url
    ///   - parameters: 参数
    ///   - success: 请求成功回调
    ///   - failure: 请求失败回调
    static func requestMethod(_ method:RequestMethod, URLString:String , parameters : [String:Any]?,progress:((Progress) -> Swift.Void)? = nil,constructingBodyWith block: ((AFMultipartFormData) -> Swift.Void)? = nil, success :(([String:Any] , JSON) -> Void)? ,failure:(() -> Void)? ) {
        MyLog(parameters)
        MyLog(manager.requestSerializer.httpRequestHeaders)
        requestMethod(method,URLString:URLString, parameters: parameters,progress:progress,constructingBodyWith:block ,success: { (response, responseObject) in
            MyLog(response)
            MyLog(responseObject)
            
            if let value = responseObject as? [String:Any] {
                MyLog(value)
                let json = JSON.init(value)
                
                if let token = json["token"].string {
                    CacheClass.setObject(token, forEnumKey: .token)
                }
                
                
                success?(value ,json)
            }else {
                failure?()
            }
            
            
        }) { (task, error) in
            
            MyLog(task?.response)
            MyLog("网络请求失败")
            let aError = error as NSError
            MyLog("Error : \(aError)")
            failure?()
            
            
            switch aError.code {
            case -1009 :
                currentViewController()?.showErrorAlert(title: global_networkError)
            case -1001 :
                currentViewController()?.showErrorAlert(title: global_networkTimedOut)
                
            default:
                
                if aError.localizedDescription.contains("401") {
                    currentViewController()?.signInAgain()
                }else{
                    currentViewController()?.showErrorAlert(msg:aError.localizedDescription)
                }
                
                break
            }
        }
        
    }
    
    
    // MARK: 网络请求(私有方法)
    fileprivate static func requestMethod(_ method:RequestMethod, URLString:String , parameters : [String:Any]? ,progress:((Progress) -> Swift.Void)?,constructingBodyWith block: ((AFMultipartFormData) -> Swift.Void)?, success :((URLResponse?, Any?) -> Void)? ,failure:((URLSessionDataTask?,Error) -> Void)? ) {
        
        switch method {
        case .post:
            manager.post(URLString, parameters: parameters, progress: progress, success: { (task, responseObject) in
                success?(task.response,responseObject)
            }, failure: { (task, aError) in
                failure?(task,aError)
            })
        case .get:
            manager.get(URLString, parameters: parameters, progress: progress, success: { (task, responseObject) in
                success?(task.response,responseObject)
            }, failure: { (task, aError) in
                
                //                let string = NSString.init(data: ((aError as NSError).userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]) as! Data, encoding: String.Encoding.utf8.rawValue)
                failure?(task,aError)
            })
            
        case .upload:
            let request = AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST", urlString: URLString, parameters: parameters, constructingBodyWith: block, error: nil)
            request.setValue(CacheClass.stringForEnumKey(.token) ?? "", forHTTPHeaderField: "Authentication")
            let uploadTask = self.manager.uploadTask(withStreamedRequest: request as URLRequest, progress: {
                (uploadProgress) in
                progress?(uploadProgress)
            }) { (response, object, error) in
                
                if object != nil {
                    success?(response,object)
                }
                if error != nil {
                    failure?(nil,error!)
                }
                
            }
            uploadTask.resume()
        }
        
    }
    
    //MARK: - 获取当前屏幕顶层显示控制器
    /// 获取当前屏幕顶层显示控制器
    ///
    /// - Returns: viewController
    static func currentViewController() -> UIViewController?{
        let keyWindow = UIApplication.shared.keyWindow
        var currentVc = keyWindow?.rootViewController
        if currentVc?.presentedViewController != nil {
            currentVc = currentVc?.presentedViewController
        }
        if let vc = currentVc as? UINavigationController {
            currentVc = vc.visibleViewController
        }else if let vc = currentVc as? UITabBarController {
            currentVc = vc.selectedViewController
        }
        
        return currentVc
    }
    
    //MARK: - 照片上传
    ///
    /// - Parameters:
    ///   - urlString: 服务器地址
    ///   - params: ["flag":"","userId":""] - flag,userId 为必传参数
    ///        flag - 666 信息上传多张  －999 服务单上传  －000 头像上传
    ///   - data: image转换成Data
    ///   - name: fileName
    ///   - success:
    ///   - failture:
    static func upLoadImageRequest(urlString : String, data: [Data],success : (([String : Any],JSON)->())?, failture : (()->Void)?){
        //        KSVPshowWithStatus(text:" 正在上传... ")
        
        
        
        //        MBProgressHUD_JChat.showMessage(message: "正在上传...", toView: view)
        //
        let headers = ["content-type":"multipart/form-data","Authentication":CacheClass.stringForEnumKey(.token) ?? ""]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                //666多张图片上传
                //                let flag = params["flag"]
                //                let userId = params["userId"]
                
                //                multipartFormData.append((flag?.data(using: String.Encoding.utf8)!)!, withName: "flag")
                //                multipartFormData.append( (userId?.data(using: String.Encoding.utf8)!)!, withName: "userId")
                
                for i in 0..<data.count {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMddHHmmss"
                    let fileNamex = "\(formatter.string(from: Date())).png"
                    multipartFormData.append(data[i], withName: "file", fileName: fileNamex, mimeType: "image/jpg/png/jpeg")
                }
        },
            to: urlString,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value as? [String: AnyObject]{
                            let json = JSON(value)
                            success?(value,json)
                            
                            if let token = json["token"].string {
                                CacheClass.setObject(token, forEnumKey: .token)
                            }
                           
                        }
                    }
                case .failure(let error):
                    
                    MyLog(error.localizedDescription)
                }
        }
        )
    }
    
    
}
