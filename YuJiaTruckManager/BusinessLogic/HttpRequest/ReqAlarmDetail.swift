//
//  ReqAlarmDetail.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/30.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 报警详情接口
class ReqAlarmDetail: BaseReqModel<ReqAlarmDetail.Model> {
    
   
    /// 报警编号id
    var alarmId = ""
    
    convenience init( alarmId: String) {
        self.init()
        self.alarmId = alarmId
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.alarmDetailUrl + "?alarmId=\(alarmId)"
    }
    
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":["level":"1",
                                 "alarmTypeId":"20",
                                 "vehicleId":"12344",
                                 "time":"2222",
                                 "driveName":"刘洋",
                                 "telephone":"13523890462",
                                 "groupName":"江苏驭道数据科技有限公司 ",
                                 "alarmTypeName" :"车道偏离预警",
                                 "lngAccuracy": "118.9027",
                                 "latAccuracy": "32.0727",
                                 "startTime"  : "1535593623849",
                                 "endTime"    : "1535593623849",
                                 "carLicense" : "苏A99999",
                                 "startAddress":"江苏省南京市栖霞区马群科技园",
                                 "gpses":[ ["lngAccuracy":118.9041340317156,
                                    "latAccuracy":32.07204991230401
                                    ],
                                           ["lngAccuracy":118.9341340317156,
                                            "latAccuracy":32.17204991230401
                                    ]
                            
                            
                            
                            ],
                                 "files":[["fileType":0,
                                           "fileossId":"https://vasm-demo-public.obs.cn-east-2.myhwclouds.com/demo_1.jpg"],
                                          ["fileType": 2,"channel": 1,
                                           "fileossId":"https://vasm-qa-public.obs.cn-east-2.myhwclouds.com/0eac2b96a6874c4f9367388f9677cb4e.mp4"]]]]]
        
    }
}

extension ReqAlarmDetail {
    
    /// 附件类型
    enum AttachType: Int, HandyJSONEnum {
        /// 图片
        case image = 0
        /// 视频
        case video = 2
    }
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    struct Data: HandyJSON {
        
        /// id
        var id: Int?
        /// 报警编号uuid
        var alarmId = ""
        /// 报警类型
        var alarmTypeId: Int?
        /// 报警来源
        var alarmSource: Int?
        /// 报警描述
        var alarmDesc = ""
        /// 车辆编号
        var vehicleId: String?
        /// 驾驶员编号
        var driverId: Int?
        /// 报警级别
        var level: Int?
        /// 报警名字
        var alarmTypeName: String?
        
        /// 报警开始时间
        var startTime: Int64?
        /// 报警开始gps经度
        var startGpsLng = ""
        /// 报警开始gps纬度
        var startGpsLat = ""
        /// 报警开始gps状态
        var startGpsStatus: Int?
        /// 报警开始gps高程
        var startAltitude: Double?
        /// 报警开始速度
        var startSpeed: Float?
        /// 报警开始角度
        var startAngle: Float?
        ///
        var startGpsLatAccuracy = ""
        ///
        var startGpsLngAccuracy = ""
        
        /// 报警结束时间
        var endTime: Int64?
        /// 报警结束gps经度
        var endGpsLng: Double?
        /// 报警结束gps纬度
        var endGpsLat: Double?
        /// 报警结束gps状态
        var endGpsStatus: Int?
        /// 报警结束gps高程
        var endAltitude: Float?
        /// 报警结束速度
        var endSpeed: Float?
        /// 报警结束角度
        var endAngle: Float?
        ///
        var endGpsLatAccuracy = ""
        ///
        var endGpsLngAccuracy = ""
        
        /// 平均速度
        var avgSpeed: Float?
        /// 超速限制速度
        var limitSpeed: Float?
        /// 最高速度
        var highSpeed: Float?
        
        /// 组编号
        var companyId: Int?
        /// 是否已处理
        var handle: Bool?
        /// 开始位置
        var startAddress = ""
        /// 结束位置
        var endAddress = ""
        /// 处理人编号
        var userId = ""
        /// 处理人用户名
        var userName = ""
        /// 处理时间
        var time = ""
        /// 处理方式
        var method = ""
        /// 处理方式
        var methodChinese = ""
        ///
        var desc = ""
        /// 处理状态
        var status = ""
        /// 处理状态
        var statusChinese = ""
        ///
        var textInfo = ""
        /// 处理时间
        var handleTime = ""
        ///
        var alarmDurationTime = ""
        
        /// 企业名称
        var groupName = ""
        /// 驾驶员名称
        var driveName = ""
        /// 手机号码
        var telephone = ""
        /// 企业id
        var groupId: Int?
        /// 企业类型
        var groupType = ""
        
        /// 车牌号
        var carLicense = ""
        /// 车牌颜色
        var plateColor = ""
        ///
        var driverIdCard = ""
        ///
        var driverLicense = ""
        ///
        var driverCardNo = ""
        ///
        var identifyNo = ""
        
        ///
        var gpsLat: Double?
        ///
        var gpsLng: Double?
        
        /// 附件列表
        var files = [File]()
        /// gps列表
        var gpses = [Gps]()
        
        ///
        var continueType = ""
        
        /// 获取所有图片或视频文件
        func getFiles(by type: AttachType) -> [File] {
            
            var results = [File]()
            
            for aFile in files {
                if aFile.fileType == type && aFile.fileossId?.count > 0{
                    results.append(aFile)
                }
            }
            
            return results
        }
        
    }
    
    /// files里的类型
    struct File: HandyJSON {
        
        /// 地址
        var fileossId: String?
        /// 报警编号uuid
        var alarmId = ""
        /// 0 图片，2视频 1 BIN文件
        var fileType: AttachType?
        /// 通道号
        var channel: Int?
        /// 附件创建时间
        var createTime: Int64?
        ///车辆编号
        var vehicleId: Int?
        
    }
    
    /// gpses里的类型
    struct Gps: HandyJSON {
        
        /// id
        var id = ""
        /// 车辆编号
        var vehicleId: Int?
        /// 时间
        var time: Int64?
        /// 驾驶员编号
        var driverId: Int?
        /// 状态
        var status: Int?
        /// 经度
        var lng = ""
        /// 纬度
        var lat = ""
        /// 精确经度
        var lngAccuracy = ""
        /// 精确纬度
        var latAccuracy = ""
        /// 高度
        var height: Float?
        /// 速度
        var speed: Float?
        /// 方向
        var direction: Float?
        /// 信号强度
        var wirelessstrength: Int?
        ///
        var gnns: Int?
        ///
        var mileage: Float?
        ///
        var driverName = ""
        /// 开始时间
        var startTime: Int64?
        /// 结束时间
        var endTime: Int64?
        /// 页数
        var pageNo: Int?
        /// 每页条数
        var pageSize: Int?
        /// 车牌号
        var carLicense = ""
        
        /// 取出坐标
        func getCoordinate() -> CLLocationCoordinate2D? {
            
            if let lat = latAccuracy.yd.double, let lng = lngAccuracy.yd.double {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            } else if let lat = lat.yd.double, let lng = lng.yd.double {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            
            return nil
        }
        
    }
    
}
