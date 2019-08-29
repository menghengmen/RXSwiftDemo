//
//  ReqAlarmTrend.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/2.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 报警趋势
class ReqAlarmTrend: BaseReqModel<ReqAlarmTrend.Model> {
   
    /// 开始时间--时间戳（毫秒级）
    var startTime: Int64 = 0
    /// 结束时间--时间戳（毫秒级）
    var endTime: Int64 = 0
    ///组织id
    var groupId = ""
    
    convenience init(startTime: Int64, endTime: Int64 ,groupId :String) {
        self.init()
        self.startTime = startTime
        self.endTime = endTime
        self.groupId = groupId
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.alarmTrendUrl
    }
    
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["time": "1541001600000",
                                 "totalCount" : "1200"
                                ],
                                ["time": "1541088000000",
                                 "totalCount" : "1400"
                                ],
                                ["time": "1541174400000",
                                 "totalCount" : "120"
                                ],
                                ["time": "1541260800000",
                                 "totalCount" : "240"
                                ],
                                ["time": "1541347200000",
                                 "totalCount" : "45"],
                                ["time": "1541433600000",
                                 "totalCount" : "4544"],
                                ["time": "1541520000000",
                                "totalCount" : "450"],
                                ["time": "1541606400000",
                                 "totalCount" : "120"
                                ],
                                ["time": "1541692800000",
                                 "totalCount" : "120"
                                ],
                                ["time": "1541779200000",
                                 "totalCount" : "12033"
                                ],
                                ["time": "1541865600000",
                                    "totalCount" : "20"
                                ],
                                ["time": "1541952000000",
                                 "totalCount" : "12022"
                                ],
                                ["time": "1542038400000",
                                 "totalCount" : "1230"
                                ],
                                ["time": "1542124800000",
                                 "totalCount" : "12"
                                ],
                                ["time": "1542211200000",
                                 "totalCount" : "120233"
                                ],
                                ["time": "1542297600000",
                                 "totalCount" : "12033"
                                ],
                                ["time": "1542384000000",
                                 "totalCount" : "12044"
                                ],
                                ["time": "1542470400000",
                                 "totalCount" : "1044"
                                ],
                                ["time": "1542556800000",
                                 "totalCount" : "1244"
                                ],
                                ["time": "1542643200000",
                                 "totalCount" : "144"
                                ],
                                ["time": "1542729600000",
                                 "totalCount" : "12044"
                                ],
                                ["time": "1542816000000",
                                 "totalCount" : "1044"
                                ],
                                ["time": "1542902400000",
                                 "totalCount" : "144"
                                ]
                                
            ]]]
    }
}

extension ReqAlarmTrend{
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        /// 返回查找的字符串
        var data = ""
    }
    /// data
    class Data: HandyJSON {
        
        /// 时间戳（毫秒级）
        var time:Int64?
        /// 告警数
        var totalCount:Int?
       
        required init() {
            
        }
    }
    
    
}
