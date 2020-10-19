//
//  HttpManager.swift
//  COD
//
//  Created by XinHoo on 2019/3/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let kAuthorization = "eXwdrXrvrjsHDs7F"

extension DataRequest {
    
    func cod_validate() -> Self {
        validate { (_, _, data) -> ValidationResult in
            
            
            return .success(Void())
        }
    }
    
}

 struct IdentityAndTrust {

    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}

let afHttpAdapter = Adapter { (urlRequest, _, completion) in
    
    var request = urlRequest
    
    let xhUserName = UserManager.sharedInstance.loginName ?? ""
    let xhUserResource = UserManager.sharedInstance.resource ?? ""
    let xhUserToken = UserManager.sharedInstance.session ?? ""
    
    let version = CustomUtil.getVersionForHeader()

    request.headers.add(name: "xh-user-name", value: xhUserName)
    request.headers.add(name: "xh-user-resource", value: xhUserResource)
    request.headers.add(name: "xh-user-token", value: xhUserToken)
    request.headers.add(name: "version", value: version)

    
    
    let mutableRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
    
    if let httpBody = mutableRequest.httpBody, var json = try? JSON(data: httpBody), let dictionaryObject = json.dictionaryObject {
        
        let key = "192006250b4c09247ec02edce69f6a2d"
        
        let params = dictionaryObject.sorted { (value1, value2) -> Bool in
            return value1.key < value2.key
        }
        
        var paramString = ""

        for keyValue in params {
            
            if let value = keyValue.value as? String, value.count == 0 {
                continue
            }

            paramString += "\(keyValue.key)=\(keyValue.value)&"

        }
        
        paramString += "key=\(key)"
        
        let sign = paramString.hmac(algorithm: .SHA256, key: key)
        
        json["sign"] = JSON(sign)
        
        mutableRequest.httpBody = try? json.rawData()
        

    }


    URLProtocol.setProperty(true, forKey: "kEchoURLProtocolKey", in: mutableRequest)
    completion(.success(mutableRequest as URLRequest))
}

struct ServerTrustPolicy {
    
    public static func certificates(in bundle: Bundle = Bundle.main) -> [SecCertificate] {
        var certificates: [SecCertificate] = []

        let paths = Set([".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].map { fileExtension in
            bundle.paths(forResourcesOfType: fileExtension, inDirectory: nil)
        }.joined())

        for path in paths {
            if
                let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData,
                let certificate = SecCertificateCreateWithData(nil, certificateData)
            {
                certificates.append(certificate)
            }
        }

        return certificates
    }
    
    public static func apiSign(httpBody: [String: Any]) -> String {
        return ""
    }


}

struct ClientTrust {
    
    static var certName: String {
        return "client_xinhoo"
    }
    
    static func sendClientCer() -> URLCredential  {
        
        let path: String = Bundle.main.path(forResource: self.certName, ofType: "p12")!
        
        let PKCS12Data = try! Data(contentsOf: URL(fileURLWithPath: path))


        let identityAndTrust:IdentityAndTrust = self.extractIdentity(certData: PKCS12Data);


        let urlCredential:URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: .forSession);
        
        return urlCredential

        
    }
    
    static func extractIdentity(certData:Data) -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess

        let path: String = Bundle.main.path(forResource: self.certName, ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "123456"]
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        var items : CFArray?

         securityError = SecPKCS12Import(PKCS12Data, options, &items)

        if securityError == errSecSuccess {
            let certItems:CFArray = (items as CFArray?)!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {

                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity;
//                print("\(identityPointer)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
//                print("\(trustPointer)  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
            }
        }
        return identityAndTrust;
    }
    
}


class HttpManager: NSObject {
    static let share = HttpManager();
    
    var manager: Session = {
        return HttpManager.createSesstion()
    }();
    
    var requestManager: DownloadRequest?

    
    typealias AFSNetSuccessBlock = (NSDictionary,SwiftyJSON.JSON) -> Void
    typealias AFSNetFaliedBlock  = (AFSErrorInfo) -> Void
    typealias AFSProgressBlock  = (Double) -> Void
    
    typealias DownloadSuccessBlock = (NSDictionary?,SwiftyJSON.JSON?) -> Void
    
    class func createSesstion() -> Session {
        
        var evaluators: [String: ServerTrustEvaluating] = [:]
        
        let pinnedCertificatesTrustEvaluator = PinnedCertificatesTrustEvaluator(certificates: ServerTrustPolicy.certificates(), acceptSelfSignedCertificates: false, performDefaultValidation: true, validateHost: true)

        for host in CODAppInfo.serverList {
            evaluators[host.imServer.host] = pinnedCertificatesTrustEvaluator
            
            evaluators[host.apiServer.host] = pinnedCertificatesTrustEvaluator
            evaluators[host.restApiServer.host] = pinnedCertificatesTrustEvaluator
            evaluators[host.fileServer.host] = pinnedCertificatesTrustEvaluator
            evaluators[host.momnetServer.host] = pinnedCertificatesTrustEvaluator
        }
        
        let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: true, evaluators: evaluators)


        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 300
        configuration.shouldUseExtendedBackgroundIdleMode = true
        
        let session = Session(configuration: configuration,serverTrustManager: serverTrustManager)
        
        
        return session
        
    }
    
    func sendClientCer() -> URLCredential  {
        return ClientTrust.sendClientCer()
    }
    
    
    

    func refreshManager() {
        
        self.manager.cancelAllRequests(completingOnQueue: .main) {
            self.manager = HttpManager.createSesstion()
        }
        
        
    }
    
    /** POST请求*/
    func post(url :String, param :Parameters?, isShowNoNetwork: Bool = true, successBlock :@escaping AFSNetSuccessBlock, faliedBlock :@escaping AFSNetFaliedBlock){
        // http
        
        if !CODWebRTCManager.whetherConnectedNetwork() {
            
            if isShowNoNetwork {
                CODProgressHUD.showErrorWithStatus("暂无网络")
            }
            
            var errorInfo = AFSErrorInfo()
            errorInfo.message = NSLocalizedString("暂无网络", comment: "")
            faliedBlock(errorInfo)
            return
        }
        
        self.post(url: url, param: param)?.responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
        })
        
    }

    func post(url :String, param :Parameters?) -> DataRequest? {
        
        //        print("param: \(String(describing: param))")
        let encodStr = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let xhUserName = UserManager.sharedInstance.loginName ?? ""
        let xhUserResource = UserManager.sharedInstance.resource ?? ""
        let xhUserToken = UserManager.sharedInstance.session ?? ""
        
        let headers : HTTPHeaders = ["Content-Type":"application/json",
                                     "Authorization":kAuthorization,
                                     "xh-user-name":xhUserName,
                                     "xh-user-resource":xhUserResource,
                                     "xh-user-token":xhUserToken]; // http
        
        
        
        print("\n----------------\nURL:\(url)\nparam:\(param ?? [:])\n----------------")
        
        return self.manager.request(encodStr!, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding(options: []), headers: headers, interceptor: afHttpAdapter).authenticate(with: sendClientCer()).validate().response { (response) in
            print("\(response)")
        }
        
    }
    
    /** POST请求  请求头带用户信息*/
    func postWithUserInfo(url :String, param :Parameters?, successBlock :@escaping AFSNetSuccessBlock, faliedBlock :@escaping AFSNetFaliedBlock){
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        
        let xhUserName = UserManager.sharedInstance.loginName ?? ""
        let xhUserResource = UserManager.sharedInstance.resource ?? ""
        let xhUserToken = UserManager.sharedInstance.session ?? ""
        
        let encodStr = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let nameStr = String(format: "%@:%@",UserManager.sharedInstance.loginName ?? "",UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        
        
        let headers = HTTPHeaders(["Authorization":authValue,
                                   "Content-Type":"application/json",
                                   "xh-user-name":xhUserName,
                                   "xh-user-resource":xhUserResource,
                                   "xh-user-token":xhUserToken])
        
        
        print("\n----------------\nURL:\(url)\nparam:\(param ?? [:])\n----------------")
        // http
        self.manager.request(encodStr!, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding(options: []), headers: headers, interceptor: afHttpAdapter).authenticate(with: sendClientCer()).validate().responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
        })
    }
    
    /** POST请求*/
    func postWithHeader(url :String, param :Parameters?, imageView: UIImageView, userPath:String, filePath: String, formatString: String, successBlock :@escaping DownloadSuccessBlock, faliedBlock :@escaping AFSNetFaliedBlock){
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        let encodStr = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let filePath =  "file:///" + filePath
        let nameStr = String(format: "%@:%@",UserManager.sharedInstance.loginName ?? "",UserManager.sharedInstance.password ?? "")
        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let authValue = String(format: "Basic %@", base64String ?? "")
        let headers = HTTPHeaders(["Authorization":authValue,"Content-Type":"application/json"])
        
        //指定下载路径（文件名不变）
        let destination: DownloadRequest.Destination = { url, response in
            let fileURL = URL.init(string: filePath)
            return (fileURL!, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        self.manager.download(encodStr!, method: .post, parameters: param,encoding: JSONEncoding(options: []), headers: headers, interceptor: afHttpAdapter, to: destination)
            .authenticate(with: sendClientCer()).downloadProgress { (progress) in
            
        }.responseData { (response) in
            ///下载好的文件移动文件到新的文件夹
            
            if let downURL = response.fileURL,FileManager.default.fileExists(atPath:downURL.path) {
                do {
                    try FileManager.default.moveItem(at: downURL, to: URL(string: filePath)!)
                }catch{
                    
                }
            }
            if let imagePath = response.fileURL?.path {
                let image = UIImage(contentsOfFile: imagePath)
                imageView.image = image
                successBlock(nil,nil)
            }
            
        }
    }
    
    /** GET请求*/
    func get(url:String,successBlock:@escaping AFSNetSuccessBlock,faliedBlock:@escaping AFSNetFaliedBlock){
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        let headers : HTTPHeaders = ["Content-Type":"application/json","Authorization":kAuthorization]; // http
        //        let nameStr = String(format: "%@:%@",UserManager.sharedInstance.loginName ?? "",UserManager.sharedInstance.password ?? "")
        //        let utf8Data = nameStr.data(using: String.Encoding.utf8)
        //        let base64String = utf8Data?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        //        let authValue = String(format: "Basic %@", base64String ?? "")
        //        let headers = ["Accept":"*/*","Authorization":authValue]
        self.manager.request(url, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers, interceptor: afHttpAdapter)
            .validate()
            .authenticate(with: sendClientCer())
            .responseJSON(completionHandler: { (response) in
                self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
            })
    }
    
    /** 上传图片*/
    func postImage(imageData:Data,url:String,params:Parameters?,isGIF:Bool = false,progressBlock:@escaping AFSProgressBlock,successBlock:@escaping AFSNetSuccessBlock,faliedBlock:@escaping AFSNetFaliedBlock) -> UploadRequest? {
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            self.handleRequestError(error: NSError(), faliedBlock: faliedBlock)
            return nil
        }
        let xhUserName = UserManager.sharedInstance.loginName ?? ""
        let xhUserResource = UserManager.sharedInstance.resource ?? ""
        let xhUserToken = UserManager.sharedInstance.session ?? ""
            
        let headersDic : [String: String] = ["xh-user-name":xhUserName,
                                     "xh-user-resource":xhUserResource,
                                     "xh-user-token":xhUserToken]
        let headers = HTTPHeaders(headersDic)
        //         let imageData = image.jpegData(compressionQuality: 0.1)
        // 默认60s超时
        let mD5Url = Date.init().getTimeStamp().md5()
        
        let fileName = mD5Url + (isGIF ? ".gif":".png")
        
        let uploadRequest = manager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "file", fileName: fileName, mimeType: "image/png");
            for (key, value) in params ?? [:] {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8) ?? Data(), withName: key)
            }
        }, to: url, headers: headers, interceptor: afHttpAdapter)
        
        return uploadRequest.authenticate(with: sendClientCer()).responseJSON(completionHandler: { (response) in
            
            switch response.result {
                
            case .success(_):
                self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
                
            case .failure(let error):
                self.handleRequestError(error: error as NSError, faliedBlock: faliedBlock)
            }
            
            
        })
            .uploadProgress { (progress) in
                print("FileName:\(fileName), 上传进度=================\(progress.fractionCompleted)")
                progressBlock(progress.fractionCompleted)
        }
        
        
    }
    
    /** 上传视频*/
    func postVideo(video:Data,url:String,params:Parameters?,progressBlock:@escaping AFSProgressBlock,successBlock:@escaping AFSNetSuccessBlock,faliedBlock:@escaping AFSNetFaliedBlock){
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        // 默认60s超时,以可以设置超时时间
        let xhUserName = UserManager.sharedInstance.loginName ?? ""
        let xhUserResource = UserManager.sharedInstance.resource ?? ""
        let xhUserToken = UserManager.sharedInstance.session ?? ""
            
        let headersDic : [String: String] = ["xh-user-name":xhUserName,
                                     "xh-user-resource":xhUserResource,
                                     "xh-user-token":xhUserToken]
        let headers = HTTPHeaders(headersDic)
        
        manager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(video, withName: "file", fileName: "ios.mp4", mimeType: "video/mp4");
            for (key, value) in params ?? [:] {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8) ?? Data(), withName: key)
            }
        }, to: url, headers: headers, interceptor: afHttpAdapter)
            .authenticate(with: sendClientCer())
            .responseJSON(completionHandler: { (response) in
                
                switch response.result {
                    
                case .success(_):
                    self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
                    
                case .failure(let error):
                    self.handleRequestError(error: error as NSError, faliedBlock: faliedBlock)
                }
                
                
            })
            .uploadProgress { (progress) in
                //                print("FileName:\(fileName), 上传进度=================\(progress.fractionCompleted)")
                progressBlock(progress.fractionCompleted)
        }
        
    }
    /** 上传文件*/
    func postFile(video:Data,url:String,fileName: String, params:Parameters?,progressBlock:@escaping AFSProgressBlock,successBlock:@escaping AFSNetSuccessBlock,faliedBlock:@escaping AFSNetFaliedBlock){
        if !CODWebRTCManager.whetherConnectedNetwork() {
            CODProgressHUD.showErrorWithStatus("暂无网络")
            return
        }
        // 默认60s超时,以可以设置超时时间
        let xhUserName = UserManager.sharedInstance.loginName ?? ""
        let xhUserResource = UserManager.sharedInstance.resource ?? ""
        let xhUserToken = UserManager.sharedInstance.session ?? ""
            
        let headersDic : [String: String] = ["xh-user-name":xhUserName,
                                     "xh-user-resource":xhUserResource,
                                     "xh-user-token":xhUserToken]
        let headers = HTTPHeaders(headersDic)
        
        HttpManager.share.manager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(video, withName: "file", fileName: fileName, mimeType: "application/octet-stream");
            for (key, value) in params ?? [:] {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8) ?? Data(), withName: key)
            }
        }, to: url, headers: headers, interceptor: afHttpAdapter)
            .authenticate(with: sendClientCer())
            .responseJSON(completionHandler: { (response) in
                
                switch response.result {
                    
                case .success(_):
                    self.handleResponse(response: response, successBlock: successBlock, faliedBlock: faliedBlock)
                    
                case .failure(let error):
                    self.handleRequestError(error: error as NSError, faliedBlock: faliedBlock)
                }
                
                
            })
            .uploadProgress { (progress) in
                //                print("FileName:\(fileName), 上传进度=================\(progress.fractionCompleted)")
                progressBlock(progress.fractionCompleted)
        }
        
        
    }
    
    /** 处理服务器响应数据*/
    private func handleResponse(response:AFDataResponse<Any>,successBlock:AFSNetSuccessBlock,faliedBlock:AFSNetFaliedBlock){
        print("response: \(response)")
        if let error = response.error { // 服务器未返回数据
            self.handleRequestError(error: error as NSError, faliedBlock: faliedBlock)
        }else if let value = response.value { // 服务器有返回数据
            if (value as? NSDictionary) == nil { // 返回格式不对
                self.handleRequestSuccessWithFaliedBlcok(faliedBlock: faliedBlock)
            }else{
                self.handleRequestSuccess(value: value, successBlock: successBlock, faliedBlock: faliedBlock)
            }
        }
    }
    
    /** 处理请求失败数据*/
    private func handleRequestError(error:NSError,faliedBlock:AFSNetFaliedBlock){
        var errorInfo = AFSErrorInfo()
        errorInfo.code = error.code
        errorInfo.error = error
        if ( errorInfo.code == -1009 ) {
            errorInfo.message = "无网络连接";
        }else if ( errorInfo.code == -1001 ){
            errorInfo.message = "请求超时";
        }else if ( errorInfo.code == -1005 ){
            errorInfo.message = "网络连接丢失(服务器忙)";
        }else if ( errorInfo.code == -1004 ){
            errorInfo.message = "服务器没有启动";
        }else if ( errorInfo.code == 404 || errorInfo.code == 3){
            
        }
        faliedBlock(errorInfo)
    }
    
    /** 处理请求成功数据*/
    private func handleRequestSuccess(value:Any,successBlock:AFSNetSuccessBlock,faliedBlock:AFSNetFaliedBlock){
        let json = JSON(value)
        if json["code"].int != nil && json["code"].int! == 0 { // 拦截
            successBlock(value as! NSDictionary,json)
        }else if json["code"].int != nil && json["code"].int != 0  { // 获取服务器返回失败原因
            var errorInfo = AFSErrorInfo()
            errorInfo.code = json["code"].int!
            errorInfo.message = json["msg"].string != nil ? json["msg"].string! : "不认识的错误"
            faliedBlock(errorInfo)
        }else{
            successBlock(value as! NSDictionary,json)
        }
    }
    
    /** 服务器返回数据解析出错*/
    private func handleRequestSuccessWithFaliedBlcok(faliedBlock:AFSNetFaliedBlock){
        var errorInfo = AFSErrorInfo()
        errorInfo.code = -1
        errorInfo.message = "数据解析出错"
    }
    
    func isHaveNet() -> Bool {
        let  net = NetworkReachabilityManager.init()
        return net?.isReachable ?? false
    }
    
}

/** 访问出错具体原因 */
struct AFSErrorInfo {
    var code = 0
    var message = ""
    var error:NSError?
}


