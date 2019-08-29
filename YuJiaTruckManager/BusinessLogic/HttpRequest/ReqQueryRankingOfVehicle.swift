//
//  ReqQueryRankingOfVehicle.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/27.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import HandyJSON
import YuDaoComponents

/// 搜索车辆排名
class ReqQueryRankingOfVehicle: BaseReqModel<ReqQueryRankingOfVehicle.Model> {
    
    /// 开始时间yyyyMMdd
    var startTime = ""
    /// 结束时间yyyyMMdd
    var endTime = ""
    ///  组织机构Id
    var groupId = ""
    /// 页码
    var pageNo = ""
    /// 页码大小
    var pageSize  = "10"
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.queryRankingOfVehicle  + "?groupId=\(groupId)&pageNo=\(pageNo)&pageSize=\(pageSize)&startTime=\(startTime)&endTime=\(endTime)"
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":[
                            ["carLicense": "xxxxx",
                             "alarmCount":"40"],
                            ["carLicense": "yyyyyy",
                             "alarmCount":"60"]
            ]]]
    }
}

extension ReqQueryRankingOfVehicle {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
        
        /// 车辆id
        var vehicleId = ""
        /// 车牌号
        var carLicense = ""
        /// 报警数量
        var alarmCount: Double?
        
        required init() {
        }
    }
    
}
