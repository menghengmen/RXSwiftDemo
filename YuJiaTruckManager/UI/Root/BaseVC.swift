//
//  BaseVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import MBProgressHUD


// MARK: - View Model

/// ViewController view model 基类
class BaseVM: BaseViewControllerViewModel {
    
}

// MARK: - View Controller

/// ViewController基类
class BaseVC: BaseViewController {
    
    // MARK: - Life Cycle
    override func viewSetup() {
        super.viewSetup()
        
        /// 自定义back按钮
        if navigationController?.viewControllers.count > 1 {
            let backItem = UIBarButtonItem(image: UIImage(named: "arrow_navBack"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickBackNavItem))
            navigationItem.leftBarButtonItem = backItem
        }
        
        navBarStyle = .translucentWithBlackTint
        
    }
    
    @objc private func clickBackNavItem() {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        MobClick.beginLogPageView("\(self)")
        (navigationController as? BaseNAV)?.barStyle = navBarStyle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("\(self)")
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
    
    
}
