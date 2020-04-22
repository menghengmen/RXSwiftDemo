//
//  ReqUpdateMenos.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/27.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import HandyJSON
import YuDaoComponents
/// 更新待办事项
class ReqUpdateMenos: BaseReqModel<BaseRspModel> {
    /// 必传
    var id = ""
    /// 用户id 必传
    var userId  = ""
    /// 修改待办事项具体内容时 需要传
    var content:String?
    /// 换图片时需要传
    var picture1:String?
    /// 标记点亮或者取消时需要传
    var tag:Int?
    /// 手动标识过期时需要传(1 表示过期)
    var status:Int?
    /// 手动标识过期时需要传当前时间
    var expireTime:Int64?
    /// 设置提醒时间需要传递
    var remindTime:Int64?
    
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.updateMemosUrl
    }
   
    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "the method is success",
                         "data":nil]]
        
    }

}
