//
//  ReqGetCanSendCommandVehicles.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/30.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 实时监控 top可以查看实时监控的车
class ReqGetCanSendCommandVehicles: BaseReqModel<ReqGetCanSendCommandVehicles.Model> {
    
    ///  组织机构Id
    var groupId = ""
    ///   要多少条
    var pageSize = ""
    
    convenience init(groupId: String ,pageSize: String ) {
        self.init()
        self.groupId = groupId
        self.pageSize = pageSize
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.getCanSendCommandVehiclesUrl  + "?groupId=\(groupId)&pageSize=\(pageSize)"
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["carLicense": "苏AB8F86",
                                 "onlineStatus" : "1",
                                 "vehicleId"  : "310827"
                                ],
                                ["carLicense": "苏ABOP02",
                                 "onlineStatus" : "1",
                                 "vehicleId"  : "3332222"
                                ],
                                ["carLicense": "苏ABLM9C",
                                 "onlineStatus" : "0"
                                ],
                                ["carLicense": "苏ABLM9C",
                                 "onlineStatus" : nil
                                ],
                                ["carLicense": "苏ABLM9D",
                                 "onlineStatus" : nil]
            ]]]
    }
}

extension ReqGetCanSendCommandVehicles {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
      
        var fieldCondition = ""
        /// 车牌号
        var carLicense = ""
        /// 颜色
        var plateColor:Int?
        ///  状态 1 标识可以看  0或者NULL标识不可以看
        var onlineStatus = ""
        
        /// 创建时间
        var createTime:Int64?
        /// 更新时间
        var updateTime:Int64?
        ///
        var groupId = ""
        ///
        var groupName = ""
        ///
        var driveId = ""
        /// 车辆id
        var vehicleId = ""
        
        required init() {
        }
    }
    
}
