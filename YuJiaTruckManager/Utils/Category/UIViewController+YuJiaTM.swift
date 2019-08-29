//
//  UIViewController+YuJiaTM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import UIKit
import YuDaoComponents
import MBProgressHUD
import RxSwift
import RxCocoa
import SnapKit
import BlocksKit
import IQKeyboardManagerSwift

// MARK: - 弹框等的统一

/// tag
fileprivate enum yjtm_AlertTag: Int {
    case toast = 76898001
    case customToast = 768928002
    case loading = 76898003
    case errView = 76898004
}

extension UIViewController {
    
    public func showToast(_ message: String) {
        _ = yjtm_showAlert(AlertMessage(message: message, alertType: AlertMessage.AlertType.toast))
    }
    
    /// 统一展示弹框
    func yjtm_showAlert(_ message: AlertMessage) -> Observable<(AlertMessage, Int)> {
        
        if message.alertType == .toast {
            
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .text
            hud.tag = yjtm_AlertTag.toast.rawValue
            hud.bezelView.color = .black
            hud.label.textColor = .white
            hud.label.text = message.message
            hud.offset.y = UIScreen.main.bounds.size.height / 4
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: true, afterDelay: 2.0)
            
        } else if message.alertType == .alert {
            
            let alert = UIAlertController(title: message.title, message: message.message, preferredStyle: .alert)
            
            let result = PublishSubject<(AlertMessage, Int)>()
            
            alert.addAction(UIAlertAction(title: message.cancelButtonTitle, style: .cancel, handler: { (_) in
                result.onNext((message, 0))
            }))
            if let okButton = message.okButtonTitle {
                alert.addAction(UIAlertAction(title: okButton, style: .default, handler: { (_) in
                    result.onNext((message, 1))
                }))
            }
            
            present(alert, animated: true, completion: nil)
            
            return result
            
            
        } else if message.alertType == .custom {
            
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.margin = 0
            hud.minSize = CGSize(width: 250, height: 70)
            hud.mode = .customView
            hud.tag = yjtm_AlertTag.customToast.rawValue
            hud.bezelView.addSubview(successToastView(text: message.message))
            
            hud.hide(animated: true, afterDelay: 2.0)
        }
        
        return .empty()
    }
    
    /// 弹出等待框
    func yjtm_showLoading(withText text: String?) {
        mLog("【等待框】：yjtm_showLoading")
        yjtm_hideLoading()
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.margin = 0
        hud.tag = yjtm_AlertTag.loading.rawValue
        hud.mode = .customView
        hud.minSize = CGSize(width: 120, height: 140)
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = mColor(0x000000, 0.6)
        hud.bezelView.addSubview(loadingCustomView(text: text ?? "加载中"))
    }
    
    /// 收起等待框
    func yjtm_hideLoading() {
        mLog("【等待框】：yjtm_hideLoading")
        if let hud = view.viewWithTag(yjtm_AlertTag.loading.rawValue) as? MBProgressHUD {
            hud.hide(animated: true)
        }
    }
    
    /// 展示错误提示
    func yjtm_showErrView(_ info: ErrViewInfo) -> Observable<ErrViewInfo> {
        
        yjtm_hideErrView()
        
        let result = PublishSubject<ErrViewInfo>()
        var errView: UIView? = nil
      
        
        if info.type == .network {
            errView = netErrView() {
                result.onNext(info)
            }
        } else if info.type == .nodata {
            errView = noDataView(info: info)
        } 
        
        guard errView != nil else {
            return result
        }
        
        errView?.tag = yjtm_AlertTag.errView.rawValue
        
        view.addSubview(errView!)
        errView!.snp.makeConstraints { (maker) in
            if info == .noDataFromRemind || info == .noDataFromSearch {
                maker.top.equalTo(self.topLayoutGuide.snp.bottom).offset(180)
//                maker.top.equalToSuperview().offset(240)
            } else if info == .noDataFromDrivers {
                maker.top.equalTo(self.topLayoutGuide.snp.bottom).offset(160)
//                top.equalToSuperview().offset(200)
            } else if info == .noDataFromRank {
                maker.top.equalTo(self.topLayoutGuide.snp.bottom).offset(70)
            } else if info == .noDataFromGpsGroup {
                maker.top.equalTo(self.topLayoutGuide.snp.bottom).offset(70)
            } else {
                maker.top.equalToSuperview().offset(0)
            }
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        
        return result
    }
    
    /// 移除错误提示
    func yjtm_hideErrView() {
        if let errView = view.viewWithTag(yjtm_AlertTag.errView.rawValue) {
            errView.removeFromSuperview()
        }
    }
    
    /// 自定义等待框
    private func loadingCustomView(text: String) -> UIView {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 140))
        
        /// 背景
        let bgImv = UIImageView(image: UIImage(named: "bg_disabled"))
        containerView.addSubview(bgImv)
        bgImv.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        /// 动画
        let loadingView = UIImageView(image: nil)
        containerView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.width.equalTo(60)
            maker.height.equalTo(90)
            maker.centerX.equalToSuperview()
        }
        
        var imageAry = [UIImage]()
        for i in 0...39 {
            if let anImage = UIImage(named: "loading_\(i)") {
                imageAry.append(anImage)
            }
        }
        
        loadingView.animationImages = imageAry
        loadingView.animationDuration = 2
        loadingView.animationRepeatCount = 1000
        loadingView.startAnimating()
        
        /// 文字
        let loadingText = UILabel()
        containerView.addSubview(loadingText)
        
        loadingText.snp.makeConstraints { (maker) in
            maker.top.equalTo(loadingView.snp.bottom).offset(2)
            maker.centerX.equalToSuperview()
        }
        
        loadingText.textColor = Constants.Color.mainText
        loadingText.font = Constants.Font.contentText
        loadingText.text = text
        
        return containerView
    }
    
    /// 带打钩的toast
    private func successToastView(text: String?) -> UIView {
        
        let successView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
        
        /// 背景
        let bgImv = UIImageView(image: UIImage(named: "bg_roundBorder_o"))
        successView.addSubview(bgImv)
        bgImv.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        /// 图片和文字的容器
        let containerView = UIView()
        
        /// 文字
        let loadingText = UILabel()
        containerView.addSubview(loadingText)
        
        loadingText.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        loadingText.textColor = Constants.Color.contentText
        loadingText.font = Constants.Font.noticeText
        loadingText.text = text
        loadingText.numberOfLines = 3
        
        /// 打钩图片
        let iconImv = UIImageView(image: UIImage(named: "icon_good"))
        containerView.addSubview(iconImv)
        
        iconImv.snp.makeConstraints { (maker) in
            maker.width.equalTo(22)
            maker.height.equalTo(14)
            maker.left.equalTo(loadingText.snp.right).offset(16)
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        
        successView.addSubview(containerView)
        containerView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.left.greaterThanOrEqualToSuperview().offset(10)
        }
        
        return successView
        
    }
    
    /// 网络错误view
    private func netErrView(clickBlock: (() -> Void)?) -> UIView {
        
        let errView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        errView.backgroundColor = Constants.Color.grayBg
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        
        /// 图标
        let iconImv = UIImageView(image: UIImage(named: "holder_netErr"))
        containerView.addSubview(iconImv)
        iconImv.snp.makeConstraints { (maker) in
            maker.width.equalTo(30)
            maker.height.equalTo(30)
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        /// 文字
        let textLbl = UILabel()
        containerView.addSubview(textLbl)
        textLbl.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)
            maker.top.equalTo(iconImv.snp.bottom).offset(12)
        }
        textLbl.text = "加载失败，请检查网络"
        textLbl.textAlignment = .center
        textLbl.font = Constants.Font.contentText
        textLbl.textColor = Constants.Color.contentText
        
        /// 重新加载按钮
        let button = UIButton()
        containerView.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.width.equalTo(86)
            maker.height.equalTo(28)
            maker.top.equalTo(textLbl.snp.bottom).offset(16)
            maker.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        button.setBackgroundImage(UIImage(named: "bg_roundBorder_g"), for: .normal)
        button.setTitleColor(Constants.Color.lightText, for: .normal)
        button.setTitle("重新加载", for: .normal)
        button.titleLabel?.font = Constants.Font.smallText
        button.bk_(whenTapped: {
            clickBlock?()
        })
        
        errView.addSubview(containerView)
        containerView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.left.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)
        }
        
        return errView
    }
    
    /// 没有数据页面(带图片)
    private func noDataView(info: ErrViewInfo) -> UIView {
        
        let noDataView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        noDataView.backgroundColor = .white
        
        let iconImv = UIImageView()
        let textLbl = UILabel()

        if info  == .noDataFromRemind {
            iconImv.image = UIImage(named: "holder_noRemind")
            textLbl.text = "您的备忘录空空如也"

        } else if info == .noDataFromSearch {
            iconImv.image = nil
            textLbl.text = "暂无数据，请您重新搜索！"
        } else if info == .noDataFromDrivers {
            iconImv.image = UIImage(named: "holder_noDrivers")
            textLbl.text = "邀请司机加入您的车队吧！"
        } else if info == .noDataFromRank {
            iconImv.image = UIImage(named: "holder_noRank")
            textLbl.text = "暂无排名"
        } else if info == .noDataFromGpsGroup {
            iconImv.image = UIImage(named: "holder_noGroup")
            textLbl.text = "暂无分组"
        } else {
            iconImv.image = UIImage(named: "holder_noAlarm")
            textLbl.text = "您的车队具有优秀的驾驶行为习惯，继续加油！"
        }
        noDataView.addSubview(iconImv)
        iconImv.snp.makeConstraints { (maker) in
            if iconImv.image == nil {
                maker.width.equalTo(0)
                maker.height.equalTo(0)
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview().offset(-22)
            } else {
                maker.width.equalTo(91)
                maker.height.equalTo(91)
                maker.center.equalToSuperview()
            }
        }
       
        noDataView.addSubview(textLbl)
        textLbl.snp.makeConstraints { (maker) in
            maker.top.equalTo(iconImv.snp.bottom).offset(22)
            maker.left.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)
        }
        textLbl.textAlignment = .center
        textLbl.font = Constants.Font.contentText
        textLbl.textColor = Constants.Color.lightText
        
        return noDataView
    }
    
}

/// 收起键盘
extension UIViewController {
    
    @IBAction func yjtm_closeKeyboard() {
        IQKeyboardManager.shared.resignFirstResponder()
    }
}
