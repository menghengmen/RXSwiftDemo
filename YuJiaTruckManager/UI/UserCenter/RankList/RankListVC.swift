//
//  RankListVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/24.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import MJRefresh

/// 排名统计页
class RankListVC: BaseTableVC {
    
    // MARK: - Property
    
    @IBOutlet private weak var typeSegment: UISegmentedControl!
    @IBOutlet private weak var filterBtn: UIBarButtonItem!
    
    // MARK: - Override
    override func viewSetup() {
        super.viewSetup()
        
        // 分段控制器
        typeSegment.tintColor = .white
        typeSegment.setWidth(130, forSegmentAt: 0)
        typeSegment.setWidth(130, forSegmentAt: 1)
        typeSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Constants.Color.mainText, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)], for: UIControl.State.selected)
        typeSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Constants.Color.mainText, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], for: UIControl.State.normal)
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? RankListVM {
            
            vm.currentType.asDriver()
                .map { $0 == .driver ? 0 : 1 }
                .drive(typeSegment.rx.selectedSegmentIndex)
                .disposed(by: disposeBag)
            
            typeSegment.rx.selectedSegmentIndex.asObservable()
                .map { $0 == 0 ? RankListVM.RankType.driver : RankListVM.RankType.vehicle }
                .bind(to: vm.currentType)
                .disposed(by: disposeBag)
            
        }
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is RankListCellVM:
            return RankListCell.self
            
        default:
            return nil
        }
    }
    
    override func customRefreshHeaderClass() -> MJRefreshHeader.Type {
        return MJRefreshStateHeader.self
    }
    
    override func sectionHeaderClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        return RankListSectionHeaderView.self
    }
    
    override func customRefreshFooterClass() -> MJRefreshFooter.Type {
        return BaseTableFooter.self
    }
    
    // MARK: - Private
    /// 点击过滤器
    @IBAction private func clickFilterBtn() {
        
        if let vm = viewModel as? RankListVM {
            
            let pickerView = HistoryPickerView.init(
                frame: CGRect(x: 0, y:view.frame.size.height , width:  view.frame.size.width, height: 0),
                startDate: vm.startTime.value,
                endDate: vm.endTime.value)
            
            let rootVC = UIApplication.shared.delegate as! AppDelegate
            rootVC.window?.addSubview(pickerView)
            pickerView.show()
            
            pickerView.selectDateBlock = {[weak vm] (beginDate,endDate) in
                MobClick.event("rank_set_time")
                vm?.startTime.value = beginDate
                vm?.endTime.value = endDate
            }
            
        }
    }
    
}

