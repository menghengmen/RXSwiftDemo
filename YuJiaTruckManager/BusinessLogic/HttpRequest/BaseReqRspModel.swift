//
//  BaseReqRspModel.swift
//  YuJiaTruckManager
//
//  Created by mh on 2018/10/19.
//  Copyright © 2018 Jiangsu Yu Dao Data Technology. All rights reserved.
//

import Foundation
import YuDaoComponents
import HandyJSON
import RxSwift

/// 数据请求类
public class DataRequest<T: HttpResponseModelProtocol>: HttpDataRequest<T> {
    
    /// 回收袋
    var disposeBag = DisposeBag()
    
    /// 请求参数
    var reqParamObj: BaseReqModel<T>?
    
    public override var additionalHeaders: [String : String]? {
        
        return commonHeader()
        
    }
    
    override init() {
        super.init()
        
        /// 处理收到其他终端登录的问题
        addResponseProcess()
            .disposed(by: disposeBag)
    }
    
    /// 发送请求
    ///
    /// - Parameter mockKey: 伪造数据的key
    func send(mockKey: String? = nil) {
        
        /// 是否为演示账号
        var isDemo = false
        
        if  let aReq = reqParamObj as? ReqCheckUserExists {
            isDemo = aReq.tel == Constants.DemoAccount.phoneNumber
        } else if let aReqP = reqParamObj as? ReqSendCode {
            isDemo = aReqP.tel ==  Constants.DemoAccount.phoneNumber
        } else if let aReq = reqParamObj as? ReqLogin {
            if  aReq.loginType == "2" {
                isDemo = aReq.tel == Constants.DemoAccount.phoneNumber &&
                    aReq.verifyCode == Constants.DemoAccount.verifyCode
            } else {
                isDemo = aReq.name == Constants.DemoAccount.phoneNumber &&
                    aReq.passwd == Constants.DemoAccount.verifyCode
            }
           
        }
        else if UserDefaultsManager.shared.account ==   Constants.DemoAccount.phoneNumber {
            isDemo = true
        }
        
        if isDemo {
            // 演示账号
            HttpRequestSender.shared.sendMockRequest(self, infoDic: reqParamObj?.getMockInfo(by: "Demo"))
        } else if let key = mockKey {
            // 其他假数据
            HttpRequestSender.shared.sendMockRequest(self, infoDic: reqParamObj?.getMockInfo(by: key))
        } else {
            // 真实请求
            HttpRequestSender.shared.sendDataRequest(self)
        }
        
    }
    
    /// 定制Reuqest，在最终生成的URLRequest基础上修改，替换一个新的
    override public func customRequestEdit(request: URLRequest?) -> URLRequest? {
        if let body = reqParamObj?.customHttpBody(), var urlReq = request {
            urlReq.httpBody = body
            return urlReq
        }
        return nil
    }
}


extension HttpRequest {
    
    /// 通用头部
    func commonHeader() -> [String : String]? {
        
        var addHeader = [String : String]()
        
        if let token = DataCenter.shared.userInfo.value?.token {
            addHeader["Authorization"] = token
        }
        let infoDictionary = Bundle.main.infoDictionary
        let appVersion: String = (infoDictionary? ["CFBundleShortVersionString"]as? String ) ?? ""
        addHeader["Cookie"] = "platform=ios;ver=\(appVersion);"
        return addHeader
        
    }
    
    /// 通用返回处理
    func addResponseProcess() -> Disposable {
        
        /// 处理收到其他终端登录的问题
        return responseRx.asObservable()
            .filter { (rsp) -> Bool in
                if let _ = DataCenter.shared.userInfo.value?.token {
                    return rsp.yjtm_statusCode() == .tokenInvalid || rsp.yjtm_statusCode() == .useridIsIsNil
                }
                return false
            }
            .map({ (_) -> Void in
            })
            .bind(to: MessageCenter.shared.needTokenInvalid)
        
    }
    
}

extension HttpResponse {
    
    /// 获取驭驾本地化错误码
    func yjtm_statusCode() -> Constants.StatusCode? {
        
        let code = (model as? BaseRspModel)?.statusCode() ?? Constants.StatusCode(rawValue: sysCode ?? -1)
        
        return code
    }
    
    // 驭驾本地化的错误提示
    func yjtm_errorMsg() -> String? {
        
        return Constants.Text.errMessage(from: yjtm_statusCode())
    }
    
}

/// 上传请求
class UploadRequest<T: HttpResponseModelProtocol>: HttpUploadRequest<T> {
    
    /// 回收袋
    var disposeBag = DisposeBag()
    
    public override var additionalHeaders: [String : String]? {
        
        return commonHeader()
    }
    
    
    override init() {
        super.init()
        
        method = .POST
        url = Constants.Url.uploadMenosImageUrl
        
        /// 处理收到其他终端登录的问题
        addResponseProcess()
            .disposed(by: disposeBag)
    }
    
}


/// 请求模型基类
class BaseReqModel<T: HttpResponseModelProtocol>: HttpBaseRequestParamModel<T> {
    
    override func toDataReuqest() -> DataRequest<T> {
        
        let req = DataRequest<T>()
        
        if req.method == .GET {
            req.url = url().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        } else {
            req.url = url()
        }
        req.method = method()
        req.originParams = paramsDic()
        req.reqParamObj = self
        
        return req
    }
    
    override func paramsDic() -> [String : Any]? {
        
        if method() == .GET {
            return nil
        } else {
            return super.paramsDic()
        }
        
    }
    
    /// 自定义body
    func customHttpBody() -> Data? {
        return nil
    }
    
}


/// 响应模型基类
class BaseRspModel: HttpBaseResponseModel {
    
    /// 请求结果码
    var status: Int?
    /// 请求结果描述
    var resultDesc: String?
    
    /// 获取枚举状态码
    func statusCode() -> Constants.StatusCode? {
        return Constants.StatusCode(rawValue: status ?? -1)
    }
    
    /// key映射
    override func mapping(mapper: HelpingMapper) {
        mapper <<< resultDesc <-- "description"
    }
    
    override func code() -> Int? {
        return status
    }
    // 错误提示
    override func message() -> String? {
        //        return resultDesc
        return Constants.Text.errMessage(from: statusCode())
    }
    
    override func isSuccess() -> Bool {
        return statusCode() == .success
    }
    
    
}
