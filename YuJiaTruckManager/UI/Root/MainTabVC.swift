//
//  MainTabVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YuDaoComponents
import MBProgressHUD

/// 根Tabbar VC
class MainTabVC: UITabBarController {
    
    var disposeBag = DisposeBag()
    
    /// 闪屏
//    private var flashVC: FlashPageVC?
    
    /// 当前最前面的页面
    var currnetViewController: UIViewController? {
        return (viewControllers?.yd.element(of: selectedIndex) as? UINavigationController)?.topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .white
        
        /// 加载默认页面
        loadViewControllers()
        
    }
    
    
    /// 加载vc
    private func loadViewControllers() {
        
        
        var vcAry = [UIViewController]()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /// 首页
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let homeVM = HomeVM()
        homeVC.viewModel = homeVM
        let homeNAV = BaseNAV(rootViewController: homeVC)
        vcAry.append(homeNAV)
        
        /// 历史
        let historyVC = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
        let historyVM = HistoryVM()
        historyVC.viewModel = historyVM
        let historyNAV = BaseNAV(rootViewController: historyVC)
        vcAry.append(historyNAV)
        
        /// 个人中心
        let userCenterVC = storyboard.instantiateViewController(withIdentifier: "UserCenterVC") as! UserCenterVC
        let userCenterVM = UserCenterVM()
        userCenterVC.viewModel = userCenterVM
        let userCenterNAV = BaseNAV(rootViewController: userCenterVC)
        vcAry.append(userCenterNAV)
        
        /// 工作台
        let workBenchVC = storyboard.instantiateViewController(withIdentifier: "WorkBenchVC") as! WorkBenchVC
        let vm = WorkBenchVM()
        workBenchVC.viewModel = vm
        let workBenchNav = BaseNAV(rootViewController: workBenchVC)
        vcAry.append(workBenchNav)
     
        
        
        viewControllers = vcAry
        
    }
    
    // MARK: - 自定义样式
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = currnetViewController {
            return vc.preferredStatusBarStyle
        }
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        if let vc = currnetViewController {
            return vc.prefersStatusBarHidden
        }
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = currnetViewController {
            return vc.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = currnetViewController {
            return vc.supportedInterfaceOrientations
        }
        return [.portrait]
    }
    
}

