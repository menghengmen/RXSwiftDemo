//
//  HistoryExamineCell.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/25.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import RxSwift
import RxCocoa

/// 历史统计-第三方考核cell
class HistoryExamineCellVM: BaseCellVM {
    
    /// 考核数据结构
    struct ExamineData {
        /// 车辆在线率不合格
        var online: Int?
        /// 离线位移
        var offlineMove: Int?
        /// 疑似异地经营
        var offsite: Int?
        /// 持续超速
        var speed: Int?
        /// 疲劳驾驶
        var tired: Int?
        /// 2到5点禁行
        var frobidDrive: Int?
        /// 数据异常
        var dataError: Int?
        
        /// 取出最大值
        var maxValue: Int {
            
            var result = 0
            if let value = online {
                result = result > value ? result : value
            }
            if let value = offlineMove {
                result = result > value ? result : value
            }
            if let value = offsite {
                result = result > value ? result : value
            }
            if let value = speed {
                result = result > value ? result : value
            }
            if let value = tired {
                result = result > value ? result : value
            }
            if let value = frobidDrive {
                result = result > value ? result : value
            }
            if let value = dataError {
                result = result > value ? result : value
            }
            
            return result
        }
    }
    
    /// 考核数据
    let examineData = Variable<ExamineData?>(nil)
    
    /// 当前数据类型，默认昨天
    let currentType = Variable<HistoryDataType?>(nil)
    
    init(type: HistoryDataType?) {
        super.init()
        
    }
}

/// 历史统计-第三方考核cell
class HistoryExamineCell: BaseCell {
    
    // ui
    @IBOutlet private weak var chartsContainerView: UIView!
    
    @IBOutlet private weak var onlineBar: HorizontalBarItemView!
    @IBOutlet private weak var offlineMoveBar: HorizontalBarItemView!
    @IBOutlet private weak var offsiteBar: HorizontalBarItemView!
    @IBOutlet private weak var speedBar: HorizontalBarItemView!
    @IBOutlet private weak var tiredBar: HorizontalBarItemView!
    @IBOutlet private weak var frobidDriveBar: HorizontalBarItemView!
    @IBOutlet private weak var dataErrorBar: HorizontalBarItemView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        onlineBar.title = "车辆在线率不合格"
        offlineMoveBar.title = "离线位移"
        offsiteBar.title = "疑似异地经营"
        speedBar.title = "持续超速"
        tiredBar.title = "疲劳驾驶"
        frobidDriveBar.title = "2到5点禁行"
        dataErrorBar.title = "数据异常"
        
    }
    
    /// 返回一个新建实例
    open override class func createInstance(with viewModel: TableViewCellViewModelProtocol) -> UITableViewCell {
        return UINib(nibName: "HistoryExamineCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HistoryExamineCell
    }
    
    /// 返回重用ID
    open override class func reuseID(with viewModel: TableViewCellViewModelProtocol) -> String {
        return "HistoryExamineCell"
    }
    
    /// 返回高度
    open override class func height(with viewModel: TableViewCellViewModelProtocol, tableSize: CGSize) -> CGFloat {
        return 380
    }
    
    /// 更新视图，子类重写时需要先调用super方法
    open override func updateView(with viewModel: TableViewCellViewModelProtocol) {
        super.updateView(with: viewModel)
        
        if let vm = viewModel as? HistoryExamineCellVM {
            
            vm.examineData.asDriver()
                .drive(onNext: { [weak self] (data) in
                    
                    let max = data?.maxValue ?? 0
                    
                    self?.onlineBar.reload(value: data?.online ?? 0, max: max)
                    self?.offlineMoveBar.reload(value: data?.offlineMove ?? 0, max: max)
                    self?.offsiteBar.reload(value: data?.offsite ?? 0, max: max)
                    self?.speedBar.reload(value: data?.speed ?? 0, max: max)
                    self?.tiredBar.reload(value: data?.tired ?? 0, max: max)
                    self?.frobidDriveBar.reload(value: data?.frobidDrive ?? 0, max: max)
                    self?.dataErrorBar.reload(value: data?.dataError ?? 0, max: max)
                })
                .disposed(by: disposeBag)
            
        }
        
    }
    
    
}


