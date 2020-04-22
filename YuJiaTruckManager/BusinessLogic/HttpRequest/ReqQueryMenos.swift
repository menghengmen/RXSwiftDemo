//
//  ReqQueryMenos.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/27.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 待办事项（模糊查询）
class ReqQueryMenos: BaseReqModel<ReqQueryMenos.Model> {
   
    /// 用户id
    var userId = ""
    /// 关键字 不传值即查所有  传值即模糊查询
    var keyword = ""
    
    convenience init(userId: String ,keyword: String ) {
        self.init()
        self.userId = userId
        self.keyword = keyword
        
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.queryMemosUrl  + "?userId=\(userId)&keyword=\(keyword)"
    }
    override func mockDic() -> [String : Any]? {
        
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "dataList":
                            [
                                ["content": "带一根管子",
                                 "remindTime" : "1543235458000",
                                 "picture1" : "https://vasm-qa-public.obs.cn-east-2.myhwclouds.com/530d4bde49c64a73a5809db7bc26b23a.jpg"
                                ],
                                ["content": "带一些图纸",
                                 "remindTime" : "1543149058000",
                                 "tag" : 0
                                ],
                                ["content": "下午三点开需求评审会议",
                                 "remindTime" : "1543127458000",
                                 "tag" : 1
                                ],
                                ["content": "明天出差到上海",
                                 "remindTime" : "1543033858000"
                                ],
                                
                                ["content": "晚上坐高铁回南京",
                                 "remindTime" : "1378345265700"]
                                
            ]]]
    }
}

extension ReqQueryMenos {
    /// 返回模型
    class Model: BaseRspModel {
        var dataList = [Data]()
    }
    /// data
    class Data: HandyJSON {
        
        var fieldCondition = ""
        /// 待办事项Id
        var id = ""
        /// 用户Id
        var userId:Int?
        /// 内容
        var content = ""
        /// 图片
        var picture1 = ""
        /// 标记是否点亮  0 未点亮  1点亮
        var tag:Int?
        /// 状态 0  正常   1 过期
        var status:Int?
        /// 创建时间
        var createTime:Int64?
        /// 待办事项更新时间
        var updateTime:Int64?
        /// 过期时间
        var expireTime:Int64?
        /// 提醒时间
        var remindTime:Int64?
        
        required init() {
        }
    }
    
}
