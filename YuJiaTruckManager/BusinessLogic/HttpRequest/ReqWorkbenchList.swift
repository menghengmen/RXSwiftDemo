//
//  ReqWorkbenchList.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2019/7/8.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

class ReqWorkbenchList: BaseReqModel<ReqWorkbenchList.Model> {
   
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["storeName": "店铺老王",
                                 "tel" : "17909000033",
                                 "storeAddress":"杭州市文三西路",
                                 "createTime" :"2017-09-03",
                                 "userName":"孟哈哈"
                                ]
                              
                                
            ]]]
    }
}

extension ReqWorkbenchList {
    
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
        /// 返回查找的字符串
        var data = ""
    }
    /// data
    class Data: HandyJSON {
        /// 门店名称
        var storeName = ""
        /// 门店电话
        var tel = ""
        /// 门店地址
        var storeAddress = ""
        /// 创建时间
        var createTime = ""
        /// 商户名称
        var userName = ""
        
        
        required init() {
            
        }
    }
}
