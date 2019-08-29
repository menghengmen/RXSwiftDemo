//
//  HomeVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/22.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import MJRefresh

/// 首页
class HomeVC: BaseTableVC {
    
    // MARK: - Property
    
    /// 智能语音
    var smartView: SmartVoiceView?
    
    // MARK: - Override
    
    override func viewSetup() {
        super.viewSetup()
     
        navBarStyle = .normal
        showNavShadowsLineWhenScroll = true
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Constants.Color.orange], for: .selected)
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? HomeVM {

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
        case is HistoryStateCellVM:
            return HistoryStateCell.self
        case is HistoryExamineCellVM:
            return HistoryExamineCell.self
        case is HistoryTrendCellVM:
            return HistoryTrendCell.self
        
        default:
            return nil
        }
    }
    
    override func customRefreshHeaderClass() -> MJRefreshHeader.Type {
        return MJRefreshStateHeader.self
    }
    
    override func sectionFooterClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return nil
    }
    
    override func sectionHeaderClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return nil
    }
    
    // MARK: - Private Method
    
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
