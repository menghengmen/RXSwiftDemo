//
//  ReminderListVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa
import MJRefresh

/// 管车助手-列表
class ReminderListVC: BaseTableVC {
    
    // ui
    @IBOutlet private weak var searchInputTxf: UITextField!
    @IBOutlet private weak var typeSegment: UISegmentedControl!
    @IBOutlet private weak var addBtn: UIBarButtonItem!
    
    
    
    override func viewSetup() {
        super.viewSetup()
        
        // 分段控制器
        typeSegment.tintColor = .white
        typeSegment.setWidth(90, forSegmentAt: 0)
        typeSegment.setWidth(70, forSegmentAt: 1)
        typeSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : mColor(0xF36700), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)], for: UIControl.State.selected)
        typeSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : mColor(0x333333), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], for: UIControl.State.normal)
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        
        if let vm = viewModel as? ReminderListVM {
            
            addBtn.rx.tap.asObservable()
                .bind(to: vm.didClickAddButton)
                .disposed(by: disposeBag)
            
            vm.currentType.asDriver()
                .map { $0.rawValue }
                .drive(typeSegment.rx.selectedSegmentIndex)
                .disposed(by: disposeBag)
            
            typeSegment.rx.selectedSegmentIndex.asObservable()
                .map { ReminderListDataType(rawValue: $0) ?? .todo }
                .bind(to: vm.currentType)
                .disposed(by: disposeBag)
            
            vm.searchText.asDriver()
                .drive(searchInputTxf.rx.text)
                .disposed(by: disposeBag)
            
            searchInputTxf.rx.text.asObservable()
                .bind(to: vm.searchText)
                .disposed(by: disposeBag)
            
        }
        
    }
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is ReminderListCellVM:
            return ReminderListCell.self
            
        default:
            return nil
        }
    }
    
    override func customRefreshHeaderClass() -> MJRefreshHeader.Type {
        return MJRefreshStateHeader.self
    }
    
    override func customRefreshFooterClass() -> MJRefreshFooter.Type {
        return BaseTableFooter.self
    }
   
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if let vm = viewModel as? ReminderListVM {
            
            let starAction = UITableViewRowAction(style: .normal, title: "标记过期") { [weak vm] (_, idxP) in
                vm?.didMarkExpired.onNext(idxP)
            }
            starAction.backgroundColor = Constants.Color.yellow
            
            let deleteAction = UITableViewRowAction(style: .default, title: "删除") { [weak vm] (_, idxP) in
                vm?.didClickDelete.onNext(idxP)
            }
            
            deleteAction.backgroundColor = Constants.Color.red
            
            return  vm.currentType.value == .todo ? [starAction, deleteAction] : [deleteAction]
        
        } else {
            return nil
        }
        
    }
    
}
