//
//  RootVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 mh Technology. All rights reserved.
//


import Foundation
import UIKit
import RxCocoa
import RxSwift
import YuDaoComponents
import IQKeyboardManagerSwift
import Photos
import AssetsLibrary

// MARK: - View Model

///  根页面
class RootVM: BaseVM {
    
    /// 顶部页面打开路由
    let topOpenRouter = PublishSubject<RouterInfo>()
    
    override init() {
        super.init()
        
        /// 监听弹出登录页
        MessageCenter.shared.needLogin.asObservable()
            .filter { $0 }
            .map({ (_) -> RouterInfo in
                return (Router.Global.needLogin, nil)
            })
            .bind(to: openRouter)
            .disposed(by: disposeBag)
       

        
        didConfirmAlert.asObservable()
            .filter {
                $0.0.message == Constants.Text.tokenInvalidMessage
            }
            .map { (_) -> Void in
            }
            .bind(to: MessageCenter.shared.didLogout)
            .disposed(by: disposeBag)
        
        /// 在其他设备上登录
        MessageCenter.shared.needTokenInvalid.asObservable()
            .map({ (_) -> AlertMessage in
                return AlertMessage(message: Constants.Text.tokenInvalidMessage, alertType: .alert, title: nil, cancelButtonTitle: "确定", okButtonTitle: nil)
            })
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        didConfirmAlert.asObservable()
            .filter {
                $0.0.message == Constants.Text.tokenInvalidMessage
            }
            .map { (_) -> Void in
            }
            .bind(to: MessageCenter.shared.didLogout)
            .disposed(by: disposeBag)
        
        /// 版本更新，如果需要弹出登录，就等登陆完
        let newVersion = Observable.combineLatest(MessageCenter.shared.needUpdateVersion.asObservable(), MessageCenter.shared.needLogin.asObservable())
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        // 不需要登录
        newVersion
            .filter { $1 == false }
            .map({ [weak self] (data) -> AlertMessage in
                self?.alertInfo(from: data.0) ?? AlertMessage()
            })
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        // 需要登录
        Observable.combineLatest(MessageCenter.shared.didLogin.asObservable(),newVersion
            .filter { $1 == true }) { (_,value) -> ReqGetNewVersion.Data in
                return value.0
            }
            .map({ [weak self] (data) -> AlertMessage in
                self?.alertInfo(from: data) ?? AlertMessage()
            })
            .delay(1.0, scheduler: MainScheduler.asyncInstance)
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        didConfirmAlert.asObservable()
            .filter ({ (value) -> Bool in
                if value.0.title == Constants.Text.newVersionMessage {
                    if value.0.infoDic?["force"] as? Bool == true {
                        return true
                    } else {
                        return value.1 == 1
                    }
                }
                return false
           })
            .map { Void in }
            .bind(to: MessageCenter.shared.needGoAppStore)
            .disposed(by: disposeBag)
        
        /// 打开提醒
        MessageCenter.shared.needShowClock
            .map({ (value) -> AlertMessage in
                return AlertMessage(message: value.content, alertType: .alert, title: nil, cancelButtonTitle: "取消", okButtonTitle: "确定")
            })
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        didConfirmAlert.asObservable()
            .filter {
                return $0.0.message?.hasPrefix(Constants.Text.remindPushPrefix) == true && $0.1 == 1
            }
            .map { (_) -> RouterInfo in
                (Router.UserCenter.reminder, nil)
            }
            .bind(to: topOpenRouter)
            .disposed(by: disposeBag)
        
    }
   
    private func alertInfo(from data: ReqGetNewVersion.Data) -> AlertMessage {
        var info = AlertMessage(message: data.versionDesc, alertType: .alert, title: Constants.Text.newVersionMessage)
        
        if data.mNeedForceUpdate() == true {
            info.cancelButtonTitle = "确定"
            info.okButtonTitle = nil
            info.infoDic = ["force": true]
        } else {
            info.cancelButtonTitle = "取消"
            info.okButtonTitle = "确定"
            info.infoDic = ["force": false]
        }
        return info
    }
    
    
}

// MARK: - View Controller

///  根页面
class RootVC: BaseVC {
    
    /// 根 tab bar vc
    var mainTabVC: MainTabVC?
    
    override func viewSetup() {
        super.viewSetup()
        
        viewModel = RootVM()
        
        loadViewControllers()
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? RootVM {
            /// 打开路由
            if let topVM = (mainTabVC?.currnetViewController as? BaseViewController)?.viewModel {
                vm.topOpenRouter.asObservable()
                    .bind(to: topVM.openRouter)
                    .disposed(by: disposeBag)
            }
        }
        
        /// 需要跳转app store
        MessageCenter.shared.needGoAppStore
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak wApp = UIApplication.shared] (_) in
                if let url = URL(string: Constants.Url.appStoreUrl) {
                    wApp?.openURL(url)
                }
            })
            .disposed(by: disposeBag)
        
        /// 打电话
        MessageCenter.shared.needCallTelephone
            .asDriver(onErrorJustReturn:"")
            .drive(onNext: { [weak self] (value) in
                self?.openTel(value)
            })
            .disposed(by: disposeBag)
       /// 发短信
        MessageCenter.shared.needSendMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] (value) in
                self?.sendMessage(value)
            })
            .disposed(by: disposeBag)
        /// 选择图片
        MessageCenter.shared.needShowImagePick
            .asDriver (onErrorJustReturn: ())
            .drive(onNext: { [weak self] () in
                self?.showPickImage()
            })
            .disposed(by: disposeBag)
        
        /// 跳转到提醒
        MessageCenter.shared.needShowClock
            .asDriver(onErrorJustReturn: RemindClockInfo())
            .drive(onNext: { [weak self] (value) in
                self?.showRemind(value)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    // MARK: - Private
    
    /// 显示打开图片选择
    private func showPickImage() {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "相机", style: UIAlertAction.Style.default, handler: { [weak self] (_) in
            self?.openCamera()
        }))
        sheet.addAction(UIAlertAction(title: "相册", style: UIAlertAction.Style.default, handler: { [weak self] (_) in
            self?.openPhoto()
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (_) in
        }))
        present(sheet, animated: true, completion: nil)
        
    }
    
    /// 打开相机
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            _ = showAlert(AlertMessage(message: "此设备不支持相机!", alertType: .toast))
            return
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        if authStatus == .restricted || authStatus == .denied {
            _ =  showAlert(AlertMessage(message: "请在设置-隐私-相机中允许访问相机", alertType: .toast))
            return
        }
        
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
    
    /// 打开图片
    private func openPhoto() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            _ = showAlert(AlertMessage(message: "此设备不支持相册", alertType: .toast))
            return
        }
        
        let library:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if(library == PHAuthorizationStatus.denied || library == PHAuthorizationStatus.restricted){
            _ =  showAlert(AlertMessage(message: "请在设置-隐私-相机中允许访问相册", alertType: .toast))
            return
        }
        
        let controller = UIImagePickerController()
        controller.sourceType = .savedPhotosAlbum
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
    
    
    
    /// 拨打电话
    private func openTel(_ tel: String) {
        
        guard tel.count > 0 else {
            return
        }
        
        if let url = URL(string: "tel://" + tel.replacingOccurrences(of: " ", with: "")) {
            DispatchQueue.main.async {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    /// 发短信
    private func sendMessage(_ tel :String) {
        guard tel.count > 0 else {
            return
        }
        
        if let url = URL(string: "sms://" + tel.replacingOccurrences(of: " ", with: "")) {
            DispatchQueue.main.async {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /// 跳转提醒
    private func showRemind(_ info: RemindClockInfo) {
        
        (tabBarController as? MainTabVC)?.selectedIndex = 2
        ((tabBarController as? MainTabVC)?.currnetViewController as? BaseVC)?.viewModel?.openRouter.onNext((Router.UserCenter.reminder,nil))
    }
    
    private func loadViewControllers() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 根 tab bar vc
        let mainTab = storyboard.instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
        
        mainTab.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainTab.view.frame = view.bounds
        
        addChild(mainTab)
        mainTab.didMove(toParent: self)
        
        view.addSubview(mainTab.view)
        
        mainTabVC = mainTab
        
        // 闪屏 vc
        let flashVC = storyboard.instantiateViewController(withIdentifier: "FlashPageVC") as! FlashPageVC
        
        let flashVM = FlashPageVM()
        flashVC.viewModel = flashVM
        
        flashVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        flashVC.view.frame = view.bounds
        
        addChild(flashVC)
        flashVC.didMove(toParent: self)
        
        view.addSubview(flashVC.view)
        
    }
    
    
  
    
    
    // MARK: - 自定义样式
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = mainTabVC {
            return vc.preferredStatusBarStyle
        }
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        if let vc = mainTabVC {
            return vc.prefersStatusBarHidden
        }
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = mainTabVC {
            return vc.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = mainTabVC {
            return vc.supportedInterfaceOrientations
        }
        return [.portrait]
    }
    
}

extension RootVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage  {
            MessageCenter.shared.didFinishPickImage.onNext(selectedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
}
