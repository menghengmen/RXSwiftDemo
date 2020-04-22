//
//  BaseWebVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/5.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import MBProgressHUD
import WebKit

// MARK: - View Model

/// ViewController view model 基类
class BaseWebVM: BaseWebViewControllerViewModel {
    
}

// MARK: - View Controller

/// ViewController基类
class BaseWebVC: YuDaoComponents.BaseWebViewController {
    
    // MARK: - Life Cycle
    override func viewSetup() {
        super.viewSetup()
        
        navBarStyle = .translucentWithBlackTint
        
        /// 自定义back按钮
        if navigationController?.viewControllers.count > 1 {
            let backItem = UIBarButtonItem(image: UIImage(named: "arrow_navBack"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickBackNavItem))
            navigationItem.leftBarButtonItem = backItem
        }
        
        webView?.uiDelegate = self
        
    }
    
    @objc private func clickBackNavItem() {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (navigationController as? BaseNAV)?.barStyle = navBarStyle
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
    
    override func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        (self.viewModel as? BaseWebVM)?.showMessage.onNext(AlertMessage(message: message, alertType: .alert))
        completionHandler()
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
