import UIKit



class CTTabBarController: UITabBarController , UITabBarControllerDelegate {
    
    deinit {
        print("MainTabBarController销毁")
    }
    //MARK: --life cyle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tabBarController?.hidesBottomBarWhenPushed = true
        initBaseLayout()
        setTabBarAppearance()
        self.delegate = self
        
    }
    
   
    /**
     *  更多TabBar自定义设置：比如：tabBarItem 的选中和不选中文字和背景图片属性、tabbar 背景图片属性
     */
    func setTabBarAppearance(){
        
        //barItem
        let barItem = UITabBarItem.appearance()
        
        // 设置字体颜色
        barItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.KTheme.black], for: .normal)//未选中
        
        barItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.KTheme.deepOrange], for: .selected)//选中
     
        //UITabBar
        //设置背景图片
        self.tabBar.backgroundColor = UIColor.white
//        self.tabBar.isTranslucent = false
        //去除 TabBar 自带的顶部阴影
//        self.tabBar.shadowImage = UIImage.init()
//        self.tabBar.backgroundImage = UIImage.init()
//
//        self.tabBar.layer.shadowColor = UIColor.lightGray.cgColor
//        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
//        self.tabBar.layer.shadowOpacity = 0.3
    }
    
    //MARK: - prinvate methods
    //添加视图
    func initBaseLayout(){
        //主页
        let homeVC = MineHomeVC()
        
        let homeNav = CTNavigationController(rootViewController: homeVC)
        let image1 = UIImage.init(named: "me_unselect")?.withRenderingMode(.alwaysOriginal)
        let image1_s = UIImage(named: "me_select")?.withRenderingMode(.alwaysOriginal)
        let item1:UITabBarItem = UITabBarItem(title: "首页", image: image1, selectedImage: image1_s)
        item1.tag = 0
        homeNav.tabBarItem = item1
        homeVC.title = "我"
        
        //沟通
        let consultVC = FoundViewController()
        let consultNav = CTNavigationController(rootViewController: consultVC)
        let image2 = UIImage(named: "found_unselect")?.withRenderingMode(.alwaysOriginal)
        let image2_s = UIImage(named: "found_select")?.withRenderingMode(.alwaysOriginal)
        let item2:UITabBarItem = UITabBarItem(title: "咨询", image: image2, selectedImage: image2_s)
        item2.tag = 1
        consultNav.tabBarItem = item2
        consultVC.title = "会话列表"
        
      
        
        let tabArray = [homeNav,consultNav]
        self.viewControllers = tabArray

        
    }
  
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //获取选中的item
        
    }
    
    //MARK: -- UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        return true
    }
}

