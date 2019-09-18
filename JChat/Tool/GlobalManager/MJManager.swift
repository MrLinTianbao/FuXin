//
//  GlobalManager.swift
//  XLCustomer
//
//  Created by longma on 2019/1/3.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

typealias kSureCompletionHandler = () -> Void

public enum CustomerType : Int {
    
    case inService
    
    case outService
    
    case otherMember
    
}
class MJManager: NSObject {
    //MARK: ********************************************************  其他
    //MARK: -传进去字符串,生成二维码图片
    class func setupQRCodeImage(_ text: String, image: UIImage?) -> UIImage {
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        //将url加入二维码
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        //取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
            //生成清晰度更好的二维码
            let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: 300)
            //如果有一个头像的话，将头像加入二维码中心
            if var image = image {
                //给头像加一个白色圆边（如果没有这个需求直接忽略）
                image = circleImageWithImage(image, borderWidth: 50, borderColor: UIColor.white)
                //合成图片
                let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 100, height: 100)
                
                return newImage
            }
            
            return qrCodeImage
        }
        
        return UIImage()
    }
    //image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    class func syntheticImage(_ image: UIImage, iconImage:UIImage, width: CGFloat, height: CGFloat) -> UIImage{
        //开启图片上下文
        UIGraphicsBeginImageContext(image.size)
        //绘制背景图片
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let x = (image.size.width - width) * 0.5
        let y = (image.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回合成好的图片
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }
    //生成边框
    class func circleImageWithImage(_ sourceImage: UIImage, borderWidth: CGFloat, borderColor: UIColor) -> UIImage {
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        UIGraphicsGetCurrentContext()
        
        let radius = (sourceImage.size.width < sourceImage.size.height ? sourceImage.size.width:sourceImage.size.height) * 0.5
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: imageWidth * 0.5, y: imageHeight * 0.5), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    //MARK: - 生成高清的UIImage
    class func setupHighDefinitionUIImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion);
        bitmapRef.draw(bitmapImage, in: integral);
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }

  
    //MARK: ********************************************************  UI
    
    /// 中部弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 副标题
    ///   - completionBlock: 确定回调
    class func showAlert(title:String,message:String?,isExistCancel:Bool = false,completionBlock:@escaping kSureCompletionHandler){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { action in
            completionBlock()
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { action in
        })
        if isExistCancel {
            alertController.addAction(cancelAction)
        }
        alertController.addAction(okAction) //确定按钮
        MJManager.getTopVC()!.present(alertController, animated: true)
    }
   
    
    
    //MARK: ********************************************************  控制器
    // MARK: - 查找顶层控制器、
    // 获取顶层控制器 根据window
    @objc class func getTopVC() -> (UIViewController?) {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal{
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window?.rootViewController
        return getTopVC(withCurrentVC: vc)
    }
    ///根据控制器获取 顶层控制器
   class func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {
        if VC == nil {
            print("🌶： 找不到顶层控制器")
            return nil
        }
        if let presentVC = VC?.presentedViewController {
            //modal出来的 控制器
            return getTopVC(withCurrentVC: presentVC)
        }else if let tabVC = VC as? UITabBarController {
            // tabBar 的跟控制器
            if let selectVC = tabVC.selectedViewController {
                return getTopVC(withCurrentVC: selectVC)
            }
            return nil
        } else if let naiVC = VC as? UINavigationController {
            // 控制器是 nav
            return getTopVC(withCurrentVC:naiVC.visibleViewController)
        } else {
            // 返回顶控制器
            return VC
        }
    }
    
    /// 判断是否内部客服
    ///
    /// - Returns: Bool
    class func isInsideService(showToast:Bool = false) -> Bool{
        let flag = false
        let customer_type = CacheClass.stringForEnumKey(.customer_type) ?? ""
        let gid = CacheClass.stringForEnumKey(.groupid) ?? ""
        
        if gid == "5" && customer_type == "0" {//内部客服
           return true
        }
        if showToast {
            AlertClass.showToat(withStatus: "无权限")
        }

        return flag
    }
    class func customerType() -> CustomerType{
        let customer_type = CacheClass.stringForEnumKey(.customer_type) ?? ""
        let gid = CacheClass.stringForEnumKey(.groupid) ?? ""
        
        if gid == "5" && customer_type == "0" {//内部客服
            return .inService
        }else if gid == "5" && customer_type == "1" {//外部客服
            return .outService
        }else{
            return .otherMember
        }
    }
    
}
//MARK: ********************************************************  OC 调用方法
extension MJManager {
    /// 状态栏高度 + 导航栏高度
    @objc class func OCStatusBarAddNavBarHeight() -> CGFloat {
        return StatusBarHeight + NAVBarHeight
    }
    
    /// 屏幕宽度
    @objc class func OCScreenW() -> CGFloat {
        return ScreenW
    }
    
    /// 屏幕高度
    @objc class func OCScreenH() -> CGFloat {
        return ScreenH
    }
    /// 状态栏高度
    @objc class func OCStatusBarHeight() -> CGFloat {
        return StatusBarHeight
    }
    /// 导航栏高度
    @objc class func OCNAVBarHeight() -> CGFloat {
        return NAVBarHeight
    }
    
}
