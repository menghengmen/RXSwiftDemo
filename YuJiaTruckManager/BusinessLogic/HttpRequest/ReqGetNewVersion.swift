//
//  ReqGetNewVersion.swift
//  YuJiaTruckManager
//
//  Created by 哈哈 on 2018/11/7.
//  Copyright © 2018年 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import UIKit
import YuDaoComponents
import HandyJSON
/// 检查新版本
class ReqGetNewVersion: BaseReqModel<ReqGetNewVersion.Model> {
    // currentVersion 当前内部版本号
    var currentVersion = ""
    
    convenience init(currentVersion: String) {
        self.init()
        self.currentVersion = currentVersion
    }
    
    override func method() -> HttpRequestMethod {
        return .GET
    }
    
    override func url() -> String {
        return Constants.Url.checkNewVersion + "?currentVersion=\(currentVersion)&module=mobile-captain"
    }

    override func mockDic() -> [String : Any]? {
        return ["Demo": ["status": 0,
                         "description": "aaabbb",
                         "data":
                            [
//                                "version": "2.0.0",
//                                "versionDesc" :"优化部分bug",
//                                "isUpdate" :"0",
//                                "address" : ""
                                
                                
            ]]]
        
    }

}

extension ReqGetNewVersion{
    
    /// 返回模型
    class Model: BaseRspModel {
        var data: Data?
    }
    /// data
    class Data: HandyJSON {
        ///版本号
        var version = ""
        // 版本描述
        var versionDesc = ""
        // 是否强制更新，0：不强制，1：强制
        var isUpdate = ""
        /// 版本地址
        var address = ""
        // 创建时间
        var createTime = ""
        /// module 模块名 驭驾车队长App 约定为mobile-captain    驭驾护航 约定为 mobile    
        var module = ""
        /// ios /Android
        var type = ""
        
        required init() {
            
        }
        
        /// 是否需要强制更新
        func mNeedForceUpdate() -> Bool {
            return isUpdate == "1"
        }
    }
    
}
