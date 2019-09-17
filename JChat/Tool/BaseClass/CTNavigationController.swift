//
//  CTNavigationController.swift
//  CityTube
//
//  Created by DUONIU_MAC on 2019/6/5.
//  Copyright © 2019年 DUONIU_MAC. All rights reserved.
//

import UIKit
import RTRootNavigationController

class CTNavigationController: RTRootNavigationController {
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //若要修改导航栏相关属性须加这句代码
        self.useSystemBackBarButtonItem = true
    }
    

    

}
