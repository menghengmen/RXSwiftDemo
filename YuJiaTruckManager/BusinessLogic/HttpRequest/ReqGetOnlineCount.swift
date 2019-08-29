//
//  ReqGetOnlineCount.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/28.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 今日概况上线插卡总数
class ReqGetOnlineCount: BaseReqModel<ReqGetOnlineCount.Model> {
    /// 开始时间(yyyy-MM-dd HH:mm:ss)
    var startTime = ""
    /// 结束时间(yyyy-MM-dd HH:mm:ss)
    var endTime = ""
    /// z组织机构id
    var groupId = ""
    
    
    convenience init(startTime: String, endTime: String ,groupId :String) {
        self.init()
        self.startTime = startTime
        self.endTime = endTime
        self.groupId = groupId
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.onlineCountUrl + "?startTime=\(startTime)&endTime=\(endTime)&groupId=\(groupId)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":
                            [
                                "totalCount": "23246",
                                "handleCount" :"23123",
                                "noHandleCount" :"123",
                                "badDriving" : "30",
                                "securityActive" : 30,
                                "illegalAlarm" : 300,
                                "accidentAlarm" : 500,
                                "vehicleOnlineCount" : "10",
                                "vehicleCount" :"100",
                                "driverIcCount" : "5",
                                "driverCount" : "23"
                                
            ]]]
        
    }
    
}

extension ReqGetOnlineCount {
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {

        /// 在线车辆
        var vehicleOnlineCount = ""
        /// 总车辆
        var vehicleCount = ""
        /// 插卡人数
        var driverIcCount = ""
        /// 总人数
        var driverCount = ""
        
        required init() {
        }
    }
}
