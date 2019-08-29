//
//  ErrViewInfo+YuJiaTM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/13.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents

/// 扩展错误类型
extension YuDaoComponents.ErrViewInfo {
    
    /// 无数据，来自我的司机
    static var noDataFromDrivers: ErrViewInfo {
        return ErrViewInfo(type: .nodata, infoDic: ["detail" : "noDataFromDrivers"])
    }
    
    /// 无数据，来自管车助手
    static var noDataFromRemind: ErrViewInfo {
        return ErrViewInfo(type: .nodata, infoDic: ["detail" : "noDataFromRemind"])
    }
    
    /// 无数据，来自搜索，不显示图片
    static var noDataFromSearch: ErrViewInfo {
        return ErrViewInfo(type: .nodata, infoDic: ["detail" : "noDataFromSearch"])
    }
    
    /// 无数据，来自排行榜
    static var noDataFromRank: ErrViewInfo {
        return ErrViewInfo(type: .nodata, infoDic: ["detail" : "noDataFromRank"])
    }
    
    /// 无数据，来自gps车辆分组
    static var noDataFromGpsGroup: ErrViewInfo {
        return ErrViewInfo(type: .nodata, infoDic: ["detail" : "noDataFromGpsGroup"])
    }
    
}
