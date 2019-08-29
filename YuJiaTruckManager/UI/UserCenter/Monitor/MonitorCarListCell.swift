//
//  MonitorCarListCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/27.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 告警详情-告警信息cell
class MonitorCarListCellVM: BaseCellVM {
    
    /// 车牌
    let carLicence = Variable<String?>(nil)
    /// 车辆id
    let vehicleId  = Variable<String?>(nil)
    /// 在线状态
    let onLineStar = Variable<String?>(nil)
    init(data :ReqGetCanSendCommandVehicles.Data) {
        super.init()
        carLicence.value = data.carLicense
        vehicleId.value = data.vehicleId
        onLineStar.value = data.onlineStatus

    }
    init(data :ReqSearchtCanSendCommandVehicles.Data) {
        super.init()
        carLicence.value = data.carLicense
        vehicleId.value = data.vehicleId
        onLineStar.value = data.onlineStatus

    }
}


/// 告警详情-告警信息cell
class MonitorCarListCell: BaseCell {
    
    @IBOutlet private weak var carLicenceLbl: UILabel!
    
    @IBOutlet var stateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "MonitorCarListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MonitorCarListCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "MonitorCarListCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 60
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? MonitorCarListCellVM {
            
            vm.carLicence.asDriver()
                .replaceEmpty("--")
                .drive(carLicenceLbl.rx.text)
                .disposed(by: disposeBag)
            vm.onLineStar.asDriver()
                .filter{ $0 != "1"}
                .map{ _ in return 0.5 }
                .drive(carLicenceLbl.rx.alpha)
                .disposed(by: disposeBag)
            
            vm.onLineStar.asDriver()
                .map{ $0 == "1"  }
                .drive(stateLabel.rx.isHidden)
                .disposed(by: disposeBag)
            
            
        }
        
        
    }
    
    
    
    
}

