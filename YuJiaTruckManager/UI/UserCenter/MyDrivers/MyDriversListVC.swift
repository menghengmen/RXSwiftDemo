//
//  MyDriversListVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/20.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 我的司机-司机列表
class MyDriversListVC: BaseTableVC {
    
    // ui
    @IBOutlet private weak var addUserBtn: UIBarButtonItem!
    @IBOutlet private var searchTxf: UITextField!
    
    // MARK: - Override
    
    override func viewSetup() {
        super.viewSetup()
        
    }
    
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? MyDriversListVM {
            
            addUserBtn.rx.tap.asObservable()
                .bind(to: vm.didClickAddDriver)
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
    
    override func cellClass(from cellViewModel: TableViewCellViewModelProtocol?) -> TableCellCompatible.Type? {
        switch cellViewModel {
            
        case is MyDriversListCellVM:
            return MyDriversListCell.self
            
        default:
            return nil
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Constants.Text.indexTitleArr
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        var targetIndex = 0
        
        if let vm = viewModel as? MyDriversListVM {
            
            if title == "#" {
                targetIndex = vm.currnetPresentArray.count - 1
            } else {
                for (idx,aData) in vm.currnetPresentArray.enumerated() {
                    
                    if aData.0 < title {
                        
                    } else if aData.0 == title {
                        targetIndex = idx
                        break
                    } else if aData.0 > title {
                        
                        targetIndex = idx - 1
                        break
                    }
                }
            }
        }
        
        return targetIndex < 0 ? 0 : targetIndex
    }

    // 来指定section的viewModel对应的header view类型，返回空表示无header
    override func  sectionHeaderClass(from sectionViewModel: SectionViewModelProtocol?) -> SectionViewCompatible.Type? {
        switch sectionViewModel {
        case is MyDriversListSectionVM:
            return MyDriversListSectionHeadView.self
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if let vm = viewModel as? MyDriversListVM {
            
            let telAction = UITableViewRowAction(style: .normal, title: "拨打电话") { [weak vm] (_, idxP) in
                vm?.didClickCallTel.onNext(idxP)
            }
            telAction.backgroundColor = Constants.Color.blue
            
            let smsAction = UITableViewRowAction(style: .normal, title: "发送短信") { [weak vm] (_, idxP) in
                vm?.didClickMessage.onNext(idxP)
            }
            smsAction.backgroundColor = Constants.Color.yellow
            
            let deleteAction = UITableViewRowAction(style: .default, title: "删除") { [weak vm] (_, idxP) in
                vm?.didClickDelete.onNext(idxP)
            }
            
            deleteAction.backgroundColor = Constants.Color.red
            
            return [deleteAction, smsAction, telAction]
            
        } else {
            return nil
        }
        
    }
    
}
