//
//  ReqAlarmList.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/26.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents

/// 报警历史列表
class ReqAlarmList: BaseReqModel<ReqAlarmList.Model> {
    
    /// 组织id
    var groupId = ""
    /// 页码
    var pageNo :Int?
    /// 每页条数
    var pageSize :Int?
    /// 开始时间（必填）
    var startTime: String?
    /// 结束时间（必填）
    var endTime :String?
    /// 报警等级
    var level :String?
    /// 处理状态 null 所有  0 未处理 1已处理
    var isHandle :Int?
    /// 告警类型 不传默认查四大类型 多个用,分割
    var alarmTypes = ""
    /// 车牌号
    var carLicense = ""
    /// 司机姓名
    var driverName = ""
    
    convenience init(groupId: String ,pageNo :Int ,pageSize :Int, startTime: String, endTime: String,carLicense: String,driverName:String ,isHandle: Int,level: String,alarmTypes: String) {

        
        self.init()
        self.groupId = groupId
        self.pageNo = pageNo
        self.pageSize = pageSize
        self.startTime = startTime
        self.endTime = endTime
        
        self.carLicense = carLicense
        self.driverName = driverName
        self.isHandle = isHandle == -1 ? nil : isHandle
        self.level = level == "" ? nil : level
        self.alarmTypes = alarmTypes 
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.alarmListUrl 
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "total" : 2,
                         "data"  : "",
                         "dataList":
                            [
                                ["level": 1,
                                 "alarmId" : "20",
                                 "alarmTypeId": 20,
                                 "alarmTypeName":"频繁变道预警",
                                 "carLicense": "苏A L9032",
                                 "driveName":"王岗",
                                 "processorName":"刘洋",
                                 "alarmStatus":"未处理",

                                 "startTime": 1533113216,
                                 "startAddress": "xxxx",
                                 "gpsLng": "116.9027",
                                 "gpsLat": "32.0727",
                                 "telephone": "12345678"],
                                ["level": 2,
                                 "alarmId" : "VeABNwpWMjmqSjJSk6Ctq7T4O451gMbr",
                                 "alarmTypeId": 10,
                                 "alarmTypeName":"急刹车",

                                 "carLicense": "苏B K00007",
                                 "driveName":"刘欢",
                                 "processorName":"刘洋",
                                 "alarmStatus":"已处理",
                                  "gpsLng": "117.9027",
                                 "gpsLat": "32.0727",
                                 "startTime": 1533113100,

                                 "startAddress": "xxxxx",
                                 "telephone": "12345678"],
                                ["level": 3,
                                 "alarmId" : "VeABNwpWMjmqSjJSk6Ctq7T4O451gMbr",
                                 "alarmTypeId": 10,
                                 "alarmTypeName":"碰撞预警",

                                 "carLicense": "苏B K23045",
                                  "driveName":"张萌",
                                  "processorName":"刘洋",
                                  "alarmStatus":"未处理",

                                 "gpsLng": "118.9027",
                                 "gpsLat": "32.0727",
                                 "startTime": 1533113100,
                                 "startAddress": "xxxxx",
                                 "telephone": "12345678"],
                                ["level": 2,
                                 "alarmId" : "VeABNwpWMjmqSjJSk6Ctq7T4O451gMbr",
                                 "alarmTypeId": 10,
                                 "alarmTypeName":"车道偏离报警",

                                 "carLicense": "苏B M9403",
                                 "driveName":"刘洋",
                                  "processorName":"刘洋",
                                  "alarmStatus":"未处理",

                                 "gpsLng": "118.9027",
                                 "gpsLat": "32.0727",
                                 "startTime": 1533113100,
                                 "startAddress": "xxxxx",
                                 "telephone": "12345678"],
                                ["level": 4,
                                 "alarmId" : "VeABNwpWMjmqSjJSk6Ctq7T4O451gMbr",
                                 "alarmTypeName":"超速告警",
                                 "alarmTypeId": 10,
                                 "carLicense": "苏A L95K2",
                                  "driveName":"赵杰",
                                  "processorName":"谢大哈",
                                  "alarmStatus":"已处理",
                                 "gpsLng": "118.9027",
                                 "gpsLat": "32.0727",
                                 "startTime": 1533113100,
                                 "startAddress": "xxxxx",
                                 "telephone": "12345678",
                                 "userName" : "谢大哈上司",
                                  "handleSpendTime":90061000]
                               
            ]]]
    }
    
}

extension ReqAlarmList {
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        
    }
    /// data
    class Data: HandyJSON {
        
        /// 报警编号
        var alarmId = ""
        /// 驾驶员编号
        var driverId: Int?
        /// 驾驶员姓名
        var driveName: String?
        /// 报警级别
        var level: Int?
        /// 报警类型
        var alarmTypeId: Int?
        /// 报警名字
        var alarmTypeName = ""
        ///报警状态    0 未处理   非0  已处理
        var handleStatus = ""
        ///处理人
        var userName = ""
        /// 处理时长
        var handleSpendTime: Double?
        /// 车牌号
        var carLicense = ""
        /// 报警时间
        var startTime = ""
        /// 报警地点
        var startAddress = ""
        /// 报警地点的精度
        var gpsLng = ""
        /// 报警地点的维度
        var gpsLat = ""

        
        /// 开始经度
        var startGpsLng = ""
        /// 开始纬度
        var startGpsLat = ""
        
        /// 手机号码
        var telephone = ""
        
        required init() {
            
        }
    }
}
