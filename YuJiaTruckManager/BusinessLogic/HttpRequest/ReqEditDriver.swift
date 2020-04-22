//
//  ReqEditDriver.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/26.
//  Copyright © 2018年 mh Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON

/// 编辑司机
class ReqEditDriver: BaseReqModel<ReqEditDriver.Model> {
    /// 手机号
    var tel = ""
    /// 名称
    var name = ""
    /// 用户id
    var userId = ""
    /// id 查询列表时返回的Id
    var id = ""
    
    convenience init(tel: String,name :String ,id :String) {
        self.init()
        self.tel = tel
        self.name = name
        self.id = id
        self.userId = DataCenter.shared.userInfo.value?.userId ?? ""
    }
    
    override func method() -> HttpRequestMethod {
        return .POST
    }
    
    override func url() -> String {
        return Constants.Url.editDriverUrl
    }
    
}

extension ReqEditDriver {
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        
        /// true表示添加成功，false表示添加失败
        var success: Bool  = false
        required init() {
        }
    }
    
}

