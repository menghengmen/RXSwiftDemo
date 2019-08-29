//
//  ReqGetAlarmCount.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/2.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 今日报警概况
class ReqGetAlarmCount: BaseReqModel<ReqGetAlarmCount.Model> {
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
        return Constants.Url.alarmCountUrl + "?startTime=\(startTime)&endTime=\(endTime)&groupId=\(groupId)"
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

extension ReqGetAlarmCount {
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        
        /// 总告警数
        var totalCount :Int?
        /// 已处理告警数
        var handleCount :Int?
        /// 未处理告警数
        var noHandleCount :Int?
        
        
        required init() {
        }
    }
}
