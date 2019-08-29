//
//  ReqGetVehicleChannel.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/30.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON


/// 查询车辆播放通道
class ReqGetVehicleChannel: BaseReqModel<ReqGetVehicleChannel.Model> {
    
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
        return Constants.Url.getVehicleChannelUrl  + "?vehicleId=\(vehicleId)"
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":
                                ["simCardNo": "13000060006",
                                 "channelOperation": "3,4,6,7,8,9,10,2,14,5,11,12,15,1,16,13"
                                ]
            ]]
    }
}

extension ReqGetVehicleChannel {
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        /// sim卡号
        var simCardNo = ""
        /// 通道号，逗号区分
        var channelOperation = ""
        
        /// 所有通道
        func allChannels() -> [String] {
            return channelOperation.components(separatedBy: ",")
        }
        
        required init() {
        }
    }
    
}
