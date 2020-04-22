//
//  PrivacyPolicyVM.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/11/5.
//  Copyright © 2018 mh Technology. All rights reserved.
//

import Foundation

/// 隐私策略
class PrivacyPolicyVM: BaseWebVM {
    
    override init() {
        super.init()
        navTitle.value = "驭驾车管家隐私政策"
        urlStr.value = Constants.Url.privacyPolicyUrl
    }
    
}
