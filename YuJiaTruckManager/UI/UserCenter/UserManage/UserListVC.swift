//
//  UserListVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户管理-列表页
class UserListVC: BaseTableVC {
    
    // ui
    @IBOutlet private weak var addUserBtn: UIBarButtonItem!
    // ui
    @IBOutlet private var searchTxf: UITextField!
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is UserListCellVM:
            return UserListCell.self
            
        default:
            return nil
        }
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? UserListVM {
            addUserBtn.rx.tap.asObservable()
                .bind(to: vm.clickaddUser)
                .disposed(by: disposeBag)
            ///搜索框
            searchTxf.rx.text.orEmpty.asObservable()
                .bind(to:  vm.searchText)
                .disposed(by: disposeBag)
            vm.searchText.asDriver()
                .drive(searchTxf.rx.text)
                .disposed(by: disposeBag)
            
            
        }
    }
    
    
    
//    /// 添加滑动编辑和删除
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        if let vm = viewModel as? UserListVM {
//
//            let editAction = UITableViewRowAction(style: .normal, title: "编辑") { [weak vm] (_, idxP) in
//                vm?.clickEdit.onNext(idxP)
//            }
//            editAction.backgroundColor = Constants.Color.orange
//
//            let deleteAction = UITableViewRowAction(style: .default, title: "删除") { [weak vm] (_, idxP) in
//                vm?.clickDelete.onNext(idxP)
//            }
//
//            deleteAction.backgroundColor = Constants.Color.red
//
//            return [deleteAction, editAction]
//
//        } else {
//            return nil
//        }
//
//    }
    
}
