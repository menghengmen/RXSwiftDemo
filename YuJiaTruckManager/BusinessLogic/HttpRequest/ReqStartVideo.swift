//
//  ReqStartVideo.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/30.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON

/// 直播码流类型
enum LiveStreamType: String, HandyJSONEnum {
    /// 主码流
    case main = "0"
    /// 子码流
    case sub = "1"
    
    func typeName() -> String {
        return self == .main ? "主码流" : "子码流"
    }
    
    static var allTypes: [LiveStreamType] {
        return [.main, .sub]
    }
}


/// 开始播放
class ReqStartVideo: BaseReqModel<ReqStartVideo.Model> {
    
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
        return Constants.Url.startVideoUrl
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":"http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8"
            ]]
    }
}

extension ReqStartVideo {
    /// 返回模型
    class Model: BaseRspModel {
        /// 播放地址
        var data: String?
    }
    
}
