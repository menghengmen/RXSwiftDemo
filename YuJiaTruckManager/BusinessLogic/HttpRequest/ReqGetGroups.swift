//
//  ReqGetGroups.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/27.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 查看gps分组
class ReqGetGroups: BaseReqModel<ReqGetGroups.Model> {
    ///组织id
    var groupId = ""
    /// 用户id
    var userId = ""
    
    convenience init(groupId: String, userId: String) {
        self.init()
        self.groupId = groupId
        self.userId = userId
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.getGroupsListUrl + "?groupId=\(groupId)&userId=\(userId)"
    }
    
    override func mockDic() -> [String : Any]?{
        return ["Demo": ["status": 0,
                         "description": "success",
                         "dataList":
                            [   ["gpsGropName": "危险车组",
                                 "gpsGropId":"110",
                                 "vehicleDtoList" : [["vehicleId":1,
                                                     "carLicense":"苏A01QQ5"],[ "vehicleId":2,
                                                                                   "carLicense":"苏N01QQ5"]]
                                ],
                                ["gpsGropName": "特殊车组",
                                 "gpsGropId":"120",

                                 "vehicleDtoList" : [["vehicleId":3,
                                                      "carLicense":"苏M01QQ5"],[ "vehicleId":4, "carLicense":"苏A034Q5", "status": 0],[ "vehicleId":5, "carLicense":"苏x01QQ5", "status": 1],[ "vehicleId":6,
                                                                                                                                                                 "carLicense":"苏A01Q34", "status": 1],[ "vehicleId":7,
                                                                                                                                                                                             "carLicense":"苏B01Q34", "status": 0],[ "vehicleId":8,
                                                                                                                                                                                                                         "carLicense":"苏G01Q34", "status": 1],[ "vehicleId":9,
                                                                                                                                                                                                                                                     "carLicense":"苏F01Q34", "status": 1],[ "vehicleId":10,
                                                                                                                                                                                                                                                                                 "carLicense":"苏H01Q34", "status": 1],[ "vehicleId":11,
                                                                                                                                                                                                     "carLicense":"苏A03456", "status": 1]]
                                ],
                                ["gpsGropName": "易爆车组",
                                 "gpsGropId":"119",

                                 "vehicleDtoList" : [["vehicleId":12,
                                                     "carLicense":"苏A0VNQ5"],["vehicleId":13,
                                                                                        "carLicense":"苏ABM5Q5"],["vehicleId":14,
                                                                                                                                                                                                                                                                                                                      "carLicense":"苏CBG4Q5"]]
                                ]
                                
                                
                                
            ]]]
    }
    
}

extension ReqGetGroups {
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
       
    }
    /// data
    struct Data: HandyJSON {
        /// 分组名字
        var gpsGropName = ""
        /// 分组id
        var gpsGroupId = ""
        /// 分组下的车辆
        var vehicleDtoList = [CarData]()

    }

    /// 分组下的车辆
    struct CarData: HandyJSON, Hashable {
        
        /// id
        var vehicleId = ""
        /// 车牌号
        var carLicense = ""
        /// 状态: 1：正常，0：车辆作废或删除
        var status: Int?
    }

}
