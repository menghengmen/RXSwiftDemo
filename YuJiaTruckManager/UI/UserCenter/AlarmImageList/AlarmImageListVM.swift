//
//  AlarmImageListVM.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/5.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警图片/视频列表页
class AlarmImageListVM: BaseTableVM {
    
    /// 类型，初始化时设置
    let type: ReqAlarmDetail.AttachType
    /// 数据
    let dataAry = Variable<[ReqAlarmDetail.File]>([])
    
    /// 点击图片事件
    let clickImage = PublishSubject<UIImage?>()
    
    init(type: ReqAlarmDetail.AttachType, dataAry: [ReqAlarmDetail.File]) {
        
        self.type = type
        
        super.init()
        
        self.dataAry.value = dataAry
        
        self.dataAry.asObservable()
            .map { [weak self] (value) -> [BaseSectionVM]? in
                return self?.viewModel(from: value)
            }
            .bind(to: dataSource)
            .disposed(by: disposeBag)
    }
    
    private func viewModel(from datas: [ReqAlarmDetail.File]) -> [BaseSectionVM]? {
        
        let section = BaseSectionVM()
        
        section.cellViewModels.append(BigTitleCellVM(title: type == .video ? "查看视频" : "查看图片"))
        
        for aData in datas {
            let cellVM = AlarmImageListCellVM(type: type)
            cellVM.fileUrl.value = aData.fileossId ?? ""
            
            cellVM.clickImage.asObservable()
                .bind(to: clickImage)
                .disposed(by: cellVM.disposeBag)
            
            section.cellViewModels.append(cellVM)
        }
        
        return [section]
    }
    
}

