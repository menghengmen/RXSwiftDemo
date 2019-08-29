//
//  UserCenterRowCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/24.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 用户中心cell类型
enum UserCenterRowType: String {
    
    case userManage = "用户管理"
    case alarm = "报警事件"
    case about = "关于我们"
    case moniter = "实时监控"
    case myDriver = "我的司机"
    case reminder = "管车助手"
    case vehicleGps = "GPS位置"
    case rankList = "排名统计"
    case myWaybill = "我的运单"
    
    /// 返回图片
    var iconImage: UIImage? {
        switch self {
        case .userManage:
            return UIImage(named: "icon_usermanage_normal")
        case .alarm:
            return UIImage(named: "icon_events")
        case .about:
            return UIImage(named: "icon_about")
        case .myDriver:
            return UIImage(named: "icon_mydrivers")
        case .moniter:
            return UIImage(named: "icon_monitor")
        case .reminder:
            return UIImage(named: "icon_asistant")
        case .vehicleGps:
            return UIImage(named: "icon_gps")
        case .rankList:
            return UIImage(named: "icon_rank")
        case .myWaybill:
            return UIImage(named: "icon_mywaybill")
        }
    }
}

/// 用户中心-行cell-viewmodel
class UserCenterRowCellVM: BaseCellVM {
    
    // to view
    /// 行类型
    let rowType = Variable<UserCenterRowType>(.userManage)
    
    init(rowType: UserCenterRowType) {
        super.init()
        
        self.rowType.value = rowType
    }
}

/// 用户中心-行cell-view
class UserCenterRowCell: BaseCell {
    
    @IBOutlet private weak var iconImv: UIImageView!
    @IBOutlet private weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "UserCenterRowCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserCenterRowCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "UserCenterRowCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 63
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? UserCenterRowCellVM {
            vm.rowType.asDriver()
                .map { $0.rawValue }
                .drive(titleLbl.rx.text)
                .disposed(by: disposeBag)
            
            vm.rowType.asDriver()
                .map { $0.iconImage }
                .drive(iconImv.rx.image)
                .disposed(by: disposeBag)
        }
        
        
    }
    
    
}
