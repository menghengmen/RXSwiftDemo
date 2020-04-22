//
//  UserCenterVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents

/// 用户中心页
class UserCenterVC: BaseTableVC {
    
    // ui
    @IBOutlet private weak var settingsBarBtn: UIBarButtonItem!
    /// 智能语音
    var smartView: SmartVoiceView?
    
    override func viewSetup() {
        super.viewSetup()
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Constants.Color.orange], for: .selected)
        
    
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? UserCenterVM {
            settingsBarBtn.rx.tap.asObservable()
                .bind(to: vm.clickSettings)
                .disposed(by: disposeBag)
            
            vm.isShowSmartVoice.asDriver()
                .distinctUntilChanged()
                .drive(onNext: { [weak self] (value) in
                    self?.updateSmartVoiceShow(value)
                })
                .disposed(by: disposeBag)
        }
    }
    

    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is UserCenterUserCellVM:
            return UserCenterUserCell.self
        case is UserCenterRowCellVM:
            return UserCenterRowCell.self
        case is UserCenterLogoutCellVM:
            return UserCenterLogoutCell.self
            
        default:
            return nil
        }
    }
    
    override func sectionFooterClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return nil
    }
    
    override func sectionHeaderClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return nil
    }
    
    private func updateSmartVoiceShow(_ isShow: Bool) {
        
        if isShow {
            
            if smartView == nil {
                smartView  = SmartVoiceView.init(frame: CGRect(x:view.frame.size.width-50, y:view.frame.size.height-134, width:50, height:50))
                smartView?.clickAction = { [weak self] in
                    if let vm = self?.viewModel as? HomeVM {
                        vm.clickSmartVoice.onNext(())
                    }
                }
            }
            
            guard smartView != nil else {
                return
            }
            view.addSubview(smartView!)
        } else {
            smartView?.removeFromSuperview()
        }
        
    }
    
}
