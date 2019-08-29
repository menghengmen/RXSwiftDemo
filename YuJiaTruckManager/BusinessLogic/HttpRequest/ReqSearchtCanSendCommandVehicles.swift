//
//  ReqSearchtCanSendCommandVehicles.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/30.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents


///  搜索可以查看实时监控的车
class ReqSearchtCanSendCommandVehicles: BaseReqModel<ReqSearchtCanSendCommandVehicles.Model> {
    
    ///  组织机构Id
    var groupId = ""
    ///  关键字
    var carLicense = ""
    ///
    var pageNo = ""
    ///
    var pageSize  = ""
    
    convenience init(groupId: String ,carLicense: String ) {
        self.init()
        self.groupId = groupId
        self.carLicense = carLicense
        pageNo = "1"
        pageSize = "10"
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.searchCanSendCommandVehiclesUrl  + "?groupId=\(groupId)&carLicense=\(carLicense)&pageNo=\(pageNo)&pageSize=\(pageSize)"
    }
}

extension ReqSearchtCanSendCommandVehicles {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
        
        var fieldCondition = ""
        /// 车牌号
        var carLicense = ""
        /// 颜色
        var plateColor:Int?
        ///  状态 1 标识可以看  0或者NULL标识不可以看
        var onlineStatus = ""
        
        /// 创建时间
        var createTime:Int64?
        /// 更新时间
        var updateTime:Int64?
        ///
        var groupId = ""
        ///
        var groupName = ""
        ///
        var driveId = ""
        /// 车辆id
        var vehicleId = ""
        
        required init() {
        }
    }
    
}
