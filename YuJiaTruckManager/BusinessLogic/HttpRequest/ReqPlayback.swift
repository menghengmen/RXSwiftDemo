//
//  ReqPlayback.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/28.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 轨迹回放
class ReqPlayback: BaseReqModel<ReqPlayback.Model> {
    ///车辆id
    var vehicleId = ""
    /// 开始时间(yyyy-MM-dd HH:mm:ss)
    var startTime: String = ""
    /// 结束时间(yyyy-MM-dd HH:mm:ss)
    var endTime: String = ""
    
    convenience init(vehicleId: String,startTime: String, endTime: String) {
        self.init()
        self.vehicleId = vehicleId
        self.startTime = startTime
        self.endTime = endTime
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.vehiclePlaybackUrl + "?vehicleId=\(vehicleId)&startTime=\(startTime)&endTime=\(endTime)"
    }
    

    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "the method is success",
                         "dataList": [
                            ["lngAccuracy":"118.903013",
                             "latAccuracy":"32.072643",
                             "speed":"110",
                             "time":"1547258400000",
                             "direction":0,
                             "mileage":10000],
                            ["lngAccuracy":"118.90287",
                             "latAccuracy":"32.073775",
                             "speed":"111",
                             "time":"1547259000000",
                             "direction":20,
                             "mileage":10100],
                            ["lngAccuracy":"118.905313",
                             "latAccuracy":"32.073301",
                             "speed":"112",
                             "time":"1547259600000",
                             "mileage":10200],
                            ["lngAccuracy":"118.90896",
                             "latAccuracy":"32.072949",
                             "speed":"113",
                             "time":"1547260200000",
                             "direction":45,
                             "mileage":10300],
                            ["lngAccuracy":"118.910577",
                             "latAccuracy":"32.07298",
                             "speed":"114",
                             "time":"1547260800000",
                             "direction":90,
                             "mileage":10400],
                            ["lngAccuracy":"118.910559",
                             "latAccuracy":"32.076773",
                             "speed":"115",
                             "time":"1547261400000",
                             "direction":135,
                             "mileage":10500],
                            ["lngAccuracy":"118.910415",
                             "latAccuracy":"32.078808",
                             "speed":"116",
                             "time":"1547262600000",
                             "direction":180,
                             "mileage":10600],
                            ["lngAccuracy":"118.903157",
                             "latAccuracy":"32.078043",
                             "speed":"117",
                             "time":"1547264400000",
                             "direction":225,
                             "mileage":10700],
                            ["lngAccuracy":"118.90366",
                             "latAccuracy":"32.081225",
                             "speed":"118",
                             "time":"1547265000000",
                             "mileage":10800],
                            ["lngAccuracy":"118.898791",
                             "latAccuracy":"32.087298",
                             "speed":"119",
                             "time":"1547267400000",
                             "direction":270,
                             "mileage":10900]
            ]]]
        
    }

}

extension ReqPlayback{
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
        
        /// 车牌号
        var carLicense = ""
        /// 经度
        var lng = ""
        /// 精确经度
        var lngAccuracy = ""
        /// 纬度
        var lat = ""
        /// 精确纬度
        var latAccuracy = ""
        /// 高度
        var height = ""
        /// 速度
        var speed = ""
        /// 方向
        var direction: Int?
        /// 时间（毫秒）
        var time = ""
        /// 里程
        var mileage: Int?
        
        required init() {
            
        }
        
        /// 取出坐标点
        func getCoordinate() -> CLLocationCoordinate2D? {
            if let lat = latAccuracy.yd.double, let lng = lngAccuracy.yd.double {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            
            return nil
        }
        
        /// 取出时间
        func getDate() -> Date? {
          return time.yd.int64?.yd.dateByMs()
        }
    }
    
}
