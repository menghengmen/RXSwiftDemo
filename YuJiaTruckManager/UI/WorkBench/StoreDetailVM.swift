//
//  StoreDetailVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/7/29.
//  Copyright © 2019 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

class StoreDetailVM: BaseTableVM {
   override init() {
        super.init()
        let  dict = ["门店名称":"门店001","审核状态":"审核通过","门店状态":"营业中","所在城市":"杭州市西湖区"]
        let baseSection = BaseSectionVM()
//        for data in dict {
//          let cellVM = StoreDetailCommonCellVM()
//          cellVM.title.value = data.key
//          cellVM.subTitle.value = data.value
//            if (data.key == "门店名称"){
//                cellVM.hiddenClickBtn.value = false
//                cellVM.imageName.value = "tab_workbench"
//
//            }
//
//          baseSection.cellViewModels.append(cellVM)
//        }
        let cellNameVM = StoreInputCellVM(title: "门店名称", subTitle: "请输入门店名称")
        let cellAddressVM = StoreInputCellVM(title: "门店地址", subTitle: "请输入门店地址")
        let cellPhoneVM = StoreInputCellVM(title: "门店电话", subTitle: "请输入门店电话")
        let cellTypeVM = StoreInputCellVM(title: "经营品类", subTitle: "请选择经营品类")
        let imageCellVM = StoreCommonImageCellVM()

        baseSection.cellViewModels.append(cellNameVM)
        baseSection.cellViewModels.append(cellAddressVM)
        baseSection.cellViewModels.append(cellPhoneVM)
        baseSection.cellViewModels.append(cellTypeVM)
        baseSection.cellViewModels.append(imageCellVM)
 
        dataSource.value = [baseSection]
    }
}
