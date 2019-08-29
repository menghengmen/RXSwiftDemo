//
//  ReqGetAllVehiclesGroup.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/1/4.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 查询企业下所有车辆列表
class ReqGetAllVehiclesGroup: BaseReqModel<ReqGetAllVehiclesGroup.Model> {
    ///组织id
    var groupId = ""
    
    convenience init(groupId: String) {
        self.init()
        self.groupId = groupId
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.queryAllVehicleGroupUrl + "?groupId=\(groupId)"
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["carLicense": "苏A01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "苏B56QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "浙V01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "鲁A01QQ5",
                                 "status" : "0"
                                
                                ],
                                ["carLicense": "豫I01QQ5",
                                 "status" : "0"
                                
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "1"
                                ],
                                ["carLicense": "苏K01QQ5",
                                 "status" : "2"
                                ],
                                ["carLicense": "浙P01QQ5",
                                 "status" : "3"
                                ]
                               
                                
            ]]]
    }
}

extension ReqGetAllVehiclesGroup{
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        
    }
    /// data
    struct Data: HandyJSON ,Hashable {
       
        ///车辆id
        var vehicleId = ""
        /// 车牌号
        var carLicense = ""
      
        /// 0 车钥匙开且无报警,1车钥匙开且报警,2车钥匙关,3离线
        var status: ReqQueryAllVehiclesGps.VehicleStatus?
        
         init() {
            
        }
    }
    
}
