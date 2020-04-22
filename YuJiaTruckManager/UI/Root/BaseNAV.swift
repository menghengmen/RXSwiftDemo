//
//  BaseNAV.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation

/// Nav Controller基类
class BaseNAV: UINavigationController {
    
    // MARK: - 自定义样式
    
    /// 导航栏样式
    enum NavBarStyle {
        /// 默认（白底黑字）
        case normal
        /// 透明（透明底白字）
        case translucent
        /// 透明黑字
        case translucentWithBlackTint
    }
    
    /// 导航栏样式
    var barStyle: NavBarStyle {
        get {
            return currentBarStyle
        }
        set {
            if newValue != currentBarStyle {
                currentBarStyle = newValue
            }
        }
    }
    
    /// 导航栏样式
    private var currentBarStyle = NavBarStyle.normal {
        didSet {
            switch currentBarStyle {
            case .normal:
                
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = UIImage()
                navigationBar.barTintColor = .white
                navigationBar.tintColor = .white
                navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.Color.mainText]
            case .translucent:
                
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
                navigationBar.barTintColor = .white
                navigationBar.tintColor = UIColor.white
                navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            case .translucentWithBlackTint:
                
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
                navigationBar.barTintColor = .white
                navigationBar.tintColor = Constants.Color.mainText
                navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.Color.mainText]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = true
        currentBarStyle = .normal
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = topViewController {
            return vc.preferredStatusBarStyle
        }
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        if let vc = topViewController {
            return vc.prefersStatusBarHidden
        }
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = topViewController {
            return vc.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = topViewController {
            return vc.supportedInterfaceOrientations
        }
        return [.portrait]
    }
}

extension BaseNAV: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count == 1 {
            return false
        } else  {
            return true
        }
        
    }
    
}
