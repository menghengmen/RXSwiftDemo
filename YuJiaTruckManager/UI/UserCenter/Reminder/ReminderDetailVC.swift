//
//  ReminderDetailVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import SimpleImageViewer

/// 管车助手-详情
class ReminderDetailVC: BaseTableVC {
    
    // ui
    var deleteMenosBtn = UIBarButtonItem(image: UIImage(named: "icon_delete"), style: .plain, target: nil, action: nil)
    var shareMenos = UIBarButtonItem(image: UIImage(named: "icon_share"), style: .plain, target: nil, action: nil)
    var addMenoBtn = UIBarButtonItem(image: UIImage(named: "icon_save"), style: .plain, target: nil, action: nil)
    
    var isShowNavBarButtons: Bool = false {
        didSet {
            navigationItem.rightBarButtonItems = isShowNavBarButtons ? [addMenoBtn, shareMenos, deleteMenosBtn] : nil
        }
    }
    
    /// 要分享的图片
    let shareImage = Variable<UIImage?>(nil)
    
    override func viewSetup() {
        super.viewSetup()
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? ReminderDetailVM {
            
            vm.type.asDriver()
                .drive(onNext: { [weak self] (value) in
                    
                    guard let sSelf = self else {
                        return
                    }
                    
                    switch value {
                    case .addMenos:
                        sSelf.navigationItem.rightBarButtonItems = [sSelf.addMenoBtn]
                    case .editMenos:
                        sSelf.navigationItem.rightBarButtonItems = [sSelf.addMenoBtn, sSelf.shareMenos, sSelf.deleteMenosBtn]
                    case .lookMenos:
                        sSelf.navigationItem.rightBarButtonItems = [sSelf.deleteMenosBtn]
                    }
                })
                .disposed(by: disposeBag)
            
            addMenoBtn.rx.tap.asObservable()
                .bind(to: vm.didClickAddMenos)
                .disposed(by: disposeBag)
            deleteMenosBtn.rx.tap.asObservable()
                .bind(to: vm.didClickDeleteMenos)
                .disposed(by: disposeBag)
            shareMenos.rx.tap.asObservable()
                .map({ [weak self] (_) -> UIImage? in
                    self?.shareImage.value = self?.screenShot()
                    return self?.shareImage.value
                })
                .bind(to: vm.didClickShareMenos)
                .disposed(by: disposeBag)
           
            vm.isEnableAddMenos.asDriver()
                .drive(addMenoBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
           vm.didClickImage.asDriver(onErrorJustReturn: nil)
                .drive(onNext: { [weak self] (img) in
                    self?.showImage(img)
                })
                .disposed(by: disposeBag)
            
            vm.didClickShareMenos.asDriver(onErrorJustReturn: nil)
                .drive(onNext: { [weak self] (image) in
                    self?.shareMenos(image)
                })
                .disposed(by: disposeBag)
            
        }
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
        case is BigTitleCellVM:
            return BigTitleCell.self
        case is ReminderDetailTimeCellVM:
            return ReminderDetailTimeCell.self
        case is ReminderDetailContentCellVM:
            return ReminderDetailContentCell.self
        case is ReminderDetailImageCellVM:
            return ReminderDetailImageCell.self
        case is ReminderDetailButtonCellVM:
            return ReminderDetailButtonCell.self
            
        default:
            return nil
        }
    }
    
    /// z截图
    private func screenShot() -> UIImage {
        UIGraphicsBeginImageContext(UIScreen.main.bounds.size)
        UIApplication.shared.windows[0].layer.render(in: (UIGraphicsGetCurrentContext() ?? nil)!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// 内部分享
    private func shareMenos(_ image: UIImage?) {
        guard let img = image else {
            return
        }
        let items = [img ] as [Any]
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
        //去除一些不需要的图标选项
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.airDrop]
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            
        }
        present(activityVC, animated: true, completion: { () -> Void in
            
        })
        
    }
    
    private func showImage(_ image: UIImage?) {
        
        guard let img = image else {
            return
        }
        
        let configuration = ImageViewerConfiguration { config in
            config.image = img
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
        
    }
}

