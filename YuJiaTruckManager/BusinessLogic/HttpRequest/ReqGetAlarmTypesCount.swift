//
//  ReqGetAlarmTypesCount.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/28.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 今日概况四大类型告警总数
class ReqGetAlarmTypesCount: BaseReqModel<ReqGetAlarmTypesCount.Model> {
    
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
        return Constants.Url.alarmTypeCountUrl + "?startTime=\(startTime)&endTime=\(endTime)&groupId=\(groupId)"
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

extension ReqGetAlarmTypesCount {
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        /// 不良驾驶
        var badDriving :Int?
        /// 主动安全
        var securityActive :Int?
        /// 违规
        var illegalAlarm :Int?
        /// 事故
        var accidentAlarm :Int?
        
        
        required init() {
        }
    }
}
