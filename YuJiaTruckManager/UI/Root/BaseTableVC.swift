//
//  BaseTableVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import MBProgressHUD
import MJRefresh

// MARK: - View Model

/// Table ViewController view model 基类
class BaseTableVM: BaseTableViewControllerViewModel {
    
    
    
}

// MARK: - View Controller

/// Table ViewController基类
class BaseTableVC: BaseTableViewController {
    
    // MARK: - Private Property
    
    // MARK: - Life Cycle
    
    override func viewSetup() {
        super.viewSetup()
        
        tableView?.backgroundColor = .clear
        navBarStyle = .translucentWithBlackTint
        
        /// 自定义back按钮
        if navigationController?.viewControllers.count > 1 {
            let backItem = UIBarButtonItem(image: UIImage(named: "arrow_navBack"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickBackNavItem))
            navigationItem.leftBarButtonItem = backItem
        }
        
    }
    
    @objc private func clickBackNavItem() {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 导航栏适配
        (navigationController as? BaseNAV)?.barStyle = navBarStyle
        
        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .automatic
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }
    }
    
    // MARK: - 弹框
    
    override func showAlert(_ message: AlertMessage) -> Observable<(AlertMessage, Int)> {
        
        return yjtm_showAlert(message)
    }
    
    override func showLoading(withText text: String?) {
        yjtm_showLoading(withText:text)
    }
    
    override func hideLoading() {
        yjtm_hideLoading()
    }
    
    override func showErrView(_ info: ErrViewInfo) -> Observable<ErrViewInfo> {
        return yjtm_showErrView(info)
    }
    
    override func hideErrView() {
        yjtm_hideErrView()
    }
    
    // MARK: - 自定义样式
    var navBarStyle: BaseNAV.NavBarStyle = .normal
    /// 滑动时显示导航栏阴影
    var showNavShadowsLineWhenScroll = false
    /// 阴影调整
    private func adjustShadowLine() {
        
        let originInsetY = -(tableView?.mj_inset.top ?? 0)
//        mLog("【adjustShadowLine】：originInsetY:\(originInsetY), offsetY:\(tableView?.contentOffset.y)")
        if showNavShadowsLineWhenScroll && tableView?.contentOffset.y > originInsetY {
            if navigationController?.navigationBar.shadowImage != nil {
                navigationController?.navigationBar.shadowImage = nil
            }
        } else{
            if navigationController?.navigationBar.shadowImage == nil {
                navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        switch navBarStyle {
        case .normal, .translucentWithBlackTint:
            return .default
        case .translucent:
            return .lightContent
            
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard showNavShadowsLineWhenScroll else {
            return
        }
        
        adjustShadowLine()
    }
    
}

// MARK: - Table Footer

/// table footer 基类
class BaseTableFooter: MJRefreshAutoNormalFooter {
    
    override func prepare() {
        super.prepare()
        isAutomaticallyRefresh = false
    }
}


