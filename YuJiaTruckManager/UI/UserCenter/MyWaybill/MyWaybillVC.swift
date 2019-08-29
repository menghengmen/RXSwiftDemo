//
//  MyWaybillVC.swift
//  YuJiaTruckManager
//
//  Created by mh on 2019/1/7.
//  Copyright © 2019 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import WebViewJavascriptBridge

/// 我的运单
class MyWaybillVC: BaseWebVC {
    
    /// js bridge
    private var bridge: WebViewJavascriptBridge?
    
    override func viewSetup() {
        super.viewSetup()
        
        navBarStyle = .translucentWithBlackTint
        
        
        
        WebViewJavascriptBridge.enableLogging()
        
        if let webview = self.webView {
            self.bridge = WebViewJavascriptBridge(forWebView: webview)
            self.bridge?.setWebViewDelegate(self)
        }
        
        self.bridge?.registerHandler("getWayBills", handler: { (data, responseCallback) in
            responseCallback?(["userId":"123"])
//            mLog("【WebViewJavascriptBridge】收到：\(data)")
        })
    }

    
    
    
}
