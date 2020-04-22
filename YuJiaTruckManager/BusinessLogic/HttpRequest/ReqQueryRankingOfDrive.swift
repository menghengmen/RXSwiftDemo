//
//  ReqQueryRankingOfDrive.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/12/27.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation
import HandyJSON
import YuDaoComponents

/// 搜索司机排名
class ReqQueryRankingOfDrive: BaseReqModel<ReqQueryRankingOfDrive.Model> {
    
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
        return Constants.Url.queryRankingOfDrive  + "?groupId=\(groupId)&pageNo=\(pageNo)&pageSize=\(pageSize)&startTime=\(startTime)&endTime=\(endTime)"
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":[
                            ["driverName": "xxxxx",
                             "alarmCount":"40"],
                            ["driverName": "yyyyyy",
                             "alarmCount":"60"]
            ]]]
    }
}

extension ReqQueryRankingOfDrive {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
        
        /// 司机id
        var driverId = ""
        /// 司机姓名
        var driverName = ""
        /// 报警数量
        var alarmCount: Double?
        
        required init() {
        }
    }
    
}
