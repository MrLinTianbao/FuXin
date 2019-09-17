//
//  JCSearchView.swift
//  JChat
//
//  Created by deng on 2017/3/22.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

@objc public protocol JCSearchControllerDelegate: NSObjectProtocol {
    @objc optional func didEndEditing(_ searchBar: UISearchBar)
}

class JCSearchController: UISearchController {
    
    weak var searchControllerDelegate: JCSearchControllerDelegate?
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let frame = searchBar.frame
        if frame.origin.y > 0 && frame.origin.y < 20  {
            
        
                searchBar.frame = CGRect(x:8, y:10, width: frame.size.width-16, height: 35)
            
        } else {
            
                
                searchBar.frame = CGRect(x:8, y: 10, width: frame.size.width-16, height: 35)
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.masksToBounds = true
        
        let frame = searchBar.frame
        if frame.origin.y > 0 && frame.origin.y < 20  {
            
            
                
                searchBar.frame = CGRect(x:8, y: 10, width: frame.size.width-16, height: 35)
            
            
            
        } else {
            
           
                
                searchBar.frame = CGRect(x:8, y: 10, width: frame.size.width-16, height: 35)
            
        }
    }
    
    private func _init() {
        automaticallyAdjustsScrollViewInsets = false
        dimsBackgroundDuringPresentation = false
        hidesNavigationBarDuringPresentation = true
        
        
        searchBar.setImage(UIImage.init(named: "search"), for: .search, state: .normal)
            
            searchBar.frame = CGRect(x: 8, y: 10, width: UIScreen.main.bounds.size.width-16, height: 35)
        
        
        
        
        if #available(iOS 11.0, *) {
            searchBar.setPositionAdjustment(UIOffset(horizontal: (ScreenW-100)/2, vertical: 3), for: .search)
            searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 5, vertical: 3)
        }
        
        searchBar.barStyle = .default
        searchBar.backgroundColor = .white
        searchBar.barTintColor = .white
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "搜索"
        //        searchBar.setImage(UIImage.loadImage("搜索")?.withRenderingMode(.alwaysOriginal), for: UISearchBarIcon.search, state: UIControlState.normal)
        
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.masksToBounds = true
        searchBar.layer.cornerRadius=5;
        searchBar.clipsToBounds=true
        
        searchBar.setSearchFieldBackgroundImage(UIImage.createImage(color: .white, size: CGSize(width: UIScreen.main.bounds.size.width-16, height: 35)), for: .normal)
    }
    
}

extension JCSearchController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchBar.setPositionAdjustment(UIOffset(horizontal: (ScreenW-100)/2, vertical: 3), for: .search)
        
        searchControllerDelegate?.didEndEditing?(searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.setPositionAdjustment(UIOffset(horizontal: 0, vertical: 3), for: .search)
        
        searchBar.showsCancelButton = true
        for view in (searchBar.subviews.first?.subviews)! {
            if view is UIButton {
                let cancelButton = view as! UIButton
                cancelButton.setTitleColor(UIColor(netHex: 0x2dd0cf), for: .normal)
                if #available(iOS 11.0, *) {
                    cancelButton.titleEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
                }
                break
            }
        }
    }
}



