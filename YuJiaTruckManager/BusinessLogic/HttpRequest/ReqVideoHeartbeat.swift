//
//  ReqVideoHeartbeat.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/30.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 开始播放
class ReqVideoHeartbeat: BaseReqModel<ReqVideoHeartbeat.Model> {
    
    /// 车辆id
    var vehicleId = ""
    /// 通道号
    var channel = ""
    /// 码流：0 主码流  1 子码流
    var type: LiveStreamType = .main
    /// sim卡号
    var simcard = ""
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.heartbeatUrl
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data": true
            ]]
    }
}

extension ReqVideoHeartbeat {
    /// 返回模型
    class Model: BaseRspModel {
        /// 心跳情况（ture：正常, false：结束）
        var data: Bool?
    }
    
}
