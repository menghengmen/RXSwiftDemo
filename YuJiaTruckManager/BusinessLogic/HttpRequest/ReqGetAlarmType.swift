//
//  ReqGetAlarmType.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/10/29.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

class ReqGetAlarmType: BaseReqModel<ReqGetAlarmType.Model> {
  
    
    convenience  init(groupId :String) {
        self.init()
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.alarmTypeUrl
    }
    
    override func mockDic() -> [String : Any]?{
        return ["Demo": ["status": 0,
                         "description": "success",
                         "dataList":
                            [   ["alarmTypeName": "事故报警",
                                 "alarmTypeList" : [["alarmId":30,
                                    "alarmName":"碰撞预警"],[ "alarmId":30,
                                "alarmName":"侧翻预警"]]
                                ],
                                ["alarmTypeName": "违规报警",
                                 "alarmTypeList" : [["alarmId":30,
                                                      "alarmName":"超速报警"],[ "alarmId":30,
                                                                                    "alarmName":"超时疲劳驾驶"],[ "alarmId":30,
                                                                                                                        "alarmName":"当天累计驾驶超时"],[ "alarmId":30,
                                                                                                                                                                  "alarmName":"车辆非法位移"],[ "alarmId":30,
                                                                                                                                                                                                      "alarmName":"凌晨2时至5时行车报警"]]
                                ],
                                ["alarmTypeName": "安全报警",
                                 "alarmTypeList" : [["alarmId":30,
                                                      "alarmName":"前向碰撞报警"],["alarmId":30,
                                                                                         "alarmName":"车道偏离报警"],["alarmId":30,
                                                                                                                            "alarmName":"车距过近报警"],["alarmId":30,
                                                                                                                                                               "alarmName":"行人碰撞预警"],["alarmId":30,
                                                                                                                                                                                                  "alarmName":"疲劳驾驶报警"],["alarmId":30,
                                                                                                                                                                                                                                     "alarmName":"接打电话报警"],["alarmId":30,
                                                                                                                                                                                                                                                                        "alarmName":"抽烟报警"]]
                                ]
                              
                               
                              
            ]]]
    }
}

extension ReqGetAlarmType {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        /// 返回查找的字符串
        var data = ""
    }
    /// data
    class Data: HandyJSON {
        
        /// 报警大类名字
        var alarmTypeName = ""
        /// 报警小类
        var alarmTypeList = [AlarmTypeListes]()
        
        
       required init() {
            
        }
    }
    /// 报警小类
    struct AlarmTypeListes: HandyJSON, Hashable {
        
        
        /// 报警类型id
        var alarmId = ""
        /// 报警名字
        var alarmName = ""
       
        init() {
            
        }
        
        
    }


}
