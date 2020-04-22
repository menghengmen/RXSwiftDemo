//
//  ReqQueryVehiclesGps.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/28.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

 /// 查询某些车辆最新gps数据
class ReqQueryVehiclesGps: BaseReqModel<ReqQueryVehiclesGps.Model> {
    ///车辆id
    var vehicleIdList = [String]()
    /// 组织id
    var groupId = ""
    
    convenience init(vehicleIdList: [String], groupId: String) {
        self.init()
//        self.vehicleIdList = vehicleIdList.map { $0.yd.intValue }
        self.vehicleIdList = vehicleIdList
        self.groupId = groupId
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.queryVehicleGpsUrl
    }
}

extension ReqQueryVehiclesGps{
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [ReqQueryAllVehiclesGps.Data]()
        
    }
    
}
