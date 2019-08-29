//
//  ReqGetVehicleGps.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/30.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 查询车辆GPS
class ReqGetVehicleGps: BaseReqModel<ReqGetVehicleGps.Model> {
    
    /// 车辆id
    var vehicleId = ""
    
    convenience init(vehicleId: String) {
        self.init()
        self.vehicleId = vehicleId
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.getVehicleGpsUrl  + "?vehicleId=\(vehicleId)"
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":
                            ["vehicleId": "300007",
                             "time": "1542968117000",
                             "driverId": "200322",
                             "status": "262147",
                             "lng": "124712593",
                             "lat": "21819996",
                             "lngAccuracy": "118.9041340317156",
                             "latAccuracy": "32.17204991230401",
                             "height": "100",
                             "speed": "-5",
                             "direction": "160",
                             "wirelessstrength": "",
                             "gnns": "16",
                             "mileage": "200200",
                             "driverName": "人脸识别测试勿删"
                                
            ]
            ]]
    }
}

extension ReqGetVehicleGps {
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        /// 车辆Id
        var vehicleId: String?
        /// 时间戳
        var time: String?
        /// 司机id
        var driverId: String?
        /// 司机姓名
        var driverName: String?
        /// 状态
        var status: String?
        ///
        var lng: String?
        ///
        var lat: String?
        /// 转换后的坐标
        var lngAccuracy: String?
        /// 转换后的坐标
        var latAccuracy: String?
        /// 高度
        var height: String?
        /// 速度
        var speed: String?
        /// 方向
        var direction: String?
        ///
        var wirelessstrength: String?
        ///
        var gnns: String?
        ///
        var mileage: String?
        
        
        required init() {
        }
    }
    
}
