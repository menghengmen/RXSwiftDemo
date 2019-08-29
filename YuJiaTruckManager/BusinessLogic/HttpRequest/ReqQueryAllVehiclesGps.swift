//
//  ReqQueryAllVehiclesGps.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/12/27.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 查询所有车辆最新gps数据
class ReqQueryAllVehiclesGps: BaseReqModel<ReqQueryAllVehiclesGps.Model> {
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
        return Constants.Url.queryAllVehicleGpsUrl + "?groupId=\(groupId)"
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["carLicense": "苏A01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.782313",
                                 "latAccuracy" : "32.244980"
                                ],
                                ["carLicense": "苏B56QQ5",
                                 "status" : "0",
                                 "lngAccuracy" :"118.850687",
                                 "latAccuracy" :"32.156428"
                                ],
                                ["carLicense": "浙V01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.763893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "鲁A01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "117.763893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "豫I01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.163893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.263893",
                                 "latAccuracy" : "32.340623"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.463893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.563893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.663893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.663893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "沪M01QQ5",
                                 "status" : "1",
                                 "lngAccuracy" : "118.213893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "苏k01QQ5",
                                 "status" : "2",
                                 "lngAccuracy" : "118.723893",
                                 "latAccuracy" : "32.240623"
                                ],
                                ["carLicense": "浙P01QQ5",
                                 "status" : "3",
                                 "lngAccuracy" : "118.733893",
                                 "latAccuracy" : "36.240623"
                                ],
                                ["carLicense": "苏G01QQ5",
                                 "status" : "3",
                                 "lngAccuracy" : "118.743893",
                                 "latAccuracy" : "35.240623"
                                ],
                                ["carLicense": "苏C01QQ5",
                                 "status" : "2",
                                 "lngAccuracy" : "118.753893",
                                 "latAccuracy" : "34.240623"
                                ],
                                ["carLicense": "苏B01QQ5",
                                 "status" : "1",
                                 "lngAccuracy" : "118.793893",
                                 "latAccuracy" : "33.240623"
                                ],
                                ["carLicense": "苏D01QQ5",
                                 "status" : "0",
                                 "lngAccuracy" : "118.203893",
                                 "latAccuracy" : "32.240623"
                                ]
                                
            ]]]
    }
}

extension ReqQueryAllVehiclesGps {
    
    /// 车辆状态
    enum VehicleStatus: String, HandyJSONEnum {
        /// 车钥匙开且无报警
        case normal = "2"
        /// 车钥匙开且报警
        case alarming = "1"
        /// 车钥匙关
        case shutdown = "3"
        /// 离线
        case offline = "4"
    }
   
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
       
    }
    /// data
    struct Data: HandyJSON, Hashable {
        
        ///车辆id
        var vehicleId = ""
        /// 车牌号
        var carLicense = ""
        /// 机构名字
        var groupName = ""
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
        var direction = ""
        /// 0 车钥匙开且无报警,1车钥匙开且报警,2车钥匙关,3离线
        var status: VehicleStatus?
        
        init() {
            
        }
        
        /// 取出坐标点
        func getCoordinate() -> CLLocationCoordinate2D? {
            guard let lat = latAccuracy.yd.double, let lng = lngAccuracy.yd.double else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
    
}
