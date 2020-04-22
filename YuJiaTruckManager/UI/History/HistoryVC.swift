//
//  HistoryVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/23.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import UIKit
import YuDaoComponents
import BlocksKit
import MJRefresh

/// 历史页
class HistoryVC: BaseTableVC {
    
    // MARK: - Property
    
    @IBOutlet private weak var filterBarBtn: UIBarButtonItem!
    /// 智能语音
    var smartView: SmartVoiceView?
    
    // MARK: - Override
    
    override func viewSetup() {
        super.viewSetup()
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Constants.Color.orange], for: .selected)
        navBarStyle = .normal
        showNavShadowsLineWhenScroll = true
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? HistoryVM {
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
    
    // MARK: - Private
    
    @IBAction private func clickFilterBarButton() {
        
        if let vm = viewModel as? HistoryVM {
            let sheet = UIAlertController(title: "筛选", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            sheet.addAction(UIAlertAction(title: "昨日", style: .default, handler: {  [weak vm] (_) in
                MobClick.event("index_filter_yesterday")
                vm?.didChangeType.onNext(.yestoday)
            }))
            sheet.addAction(UIAlertAction(title: "本月", style: .default, handler: {  [weak vm] (_) in
                MobClick.event("index_filter_cur_month")

                vm?.didChangeType.onNext(.thisMonth)
            }))
            sheet.addAction(UIAlertAction(title: "上月", style: .default, handler: {  [weak vm] (_) in
                MobClick.event("index_filter_last_month")
                vm?.didChangeType.onNext(.lastMonth)
            }))
            sheet.addAction(UIAlertAction(title: "自定义", style: .default, handler: {  [weak self] (_) in
                MobClick.event("index_filter_custom_time")
                self?.showDatePicker()
            }))
            
            sheet.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
            
            present(sheet, animated: true, completion: nil)
            
        }
  
    }
    
    private func showDatePicker() {
        
      
        if let vm = viewModel as? HistoryVM {
            
            let pickerView = HistoryPickerView.init(
                frame: CGRect(x: 0, y:view.frame.size.height , width:  view.frame.size.width, height: 0),
                startDate: vm.currentType.value?.startDate ?? Date(),
                endDate: vm.currentType.value?.endDate ?? Date())
            
            let rootVC = UIApplication.shared.delegate as! AppDelegate
            rootVC.window?.addSubview(pickerView)
            pickerView.show()
            
            pickerView.selectDateBlock = {[weak vm] beginDate,endDate in
                vm?.didChangeType.onNext(HistoryDataType(startDate: beginDate, endDate: endDate))
            }
            
            pickerView.backAction = { [weak self] in
                self?.clickFilterBarButton()
            }
            
        }
        
        
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
