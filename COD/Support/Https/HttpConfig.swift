//
//  HttpConfig.swift
//  COD
//
//  Created by XinHoo on 2019/3/5.
//  Copyright © 2019 XinHoo. All rights reserved.
//
import UIKit


//#if DEBUG
//let WebBaseDomain = "codtest.xinhoo.com"
//let HttpMeetURL = "https://codrtc.xinhoo.com/"

//let WebServiveDomain = "https://\(WebBaseDomain):9091"
//let WebServiveBASE = "https://\(WebBaseDomain)"
//#else

//let WebBaseDomain = "192.168.1.50"
//let HttpMeetURL = "http://cluster.xinhoo.com/"
//let WebServiveDomain = "http://\(WebBaseDomain):9090"
//let WebServiveBASE = "http://\(WebBaseDomain)"
//let QR_ParsingURL = "http://imango.im/cod?"
//let GeneralURL = "http://help.flygram.im"

////李玄
//let WebBaseDomain = "192.168.0.99"
//let HttpMeetURL = "http://cluster.xinhoo.com/"
//let WebServiveDomain = "http://\(WebBaseDomain):9090"
//let WebServiveBASE = "http://\(WebBaseDomain)"
//let QR_ParsingURL = "https://f.me.xinhoo.com/cod?"
//let GeneralURL = "http://help.flygram.im"
#if MANGO

//im 服务器域名
//var WebBaseDomain = "im.rezffb.com"
var XMPPHost = "im.rezffb.com"

//文件服务器
var WebServiveDomain1 = "https://file.rezffb.com"

//IM API 服务器
var WebServiveDomain = "https://imapi.rezffb.com"

// REST API 服务器
var WebServiveDomain2 = "https://restapi.rezffb.com"

// 朋友圈 服务器
var WebServiveDomain3 = "https://moments.rezffb.com"


let GeneralURL = "https://help.imangoim.com"
let QR_ParsingURL = "https://imango.im/cod?"
let OPEN_ChannleURL = "f.imango://joinchat?"
#elseif PRO

var WebBaseDomain = "im.flygram.im"
var WebBaseDomain_circle = "api.flygram.im"
var WebBaseDomain_circle_file = "att.flygram.im"
let GeneralURL = "https://help.flygram.im"
let QR_ParsingURL = "https://f.flygram.im/cod?"
let OPEN_ChannleURL = "f.flygram://joinchat?"
let WebServiveBASE = "https://\(WebBaseDomain)"

var XMPPHost = "im.r7lz6.com"

//文件服务器
var WebServiveDomain1 = "https://file.r7lz6.com"

//IM API 服务器
var WebServiveDomain = "https://imapi.r7lz6.com"

// REST API 服务器
var WebServiveDomain2 = "https://restapi.r7lz6.com"

// 朋友圈 服务器
var WebServiveDomain3 = "https://moments.r7lz6.com"
#else

//im 服务器域名
var XMPPHost = "im-master.xinhoo.com"

let GeneralURL = "https://cod.xinhoo.com"
let QR_ParsingURL = "https://f.me.xinhoo.com/cod?"
let OPEN_ChannleURL = "f.xinhoo://joinchat?"

//IM API 服务器
var WebServiveDomain = "https://imapi-master.xinhoo.com"

//文件服务器
var WebServiveDomain1 = "https://file-master.xinhoo.com"

// REST API 服务器
var WebServiveDomain2 = "https://rest-master.xinhoo.com"

// 朋友圈 服务器
var WebServiveDomain3 = "https://mom-master.xinhoo.com"
#endif

//let HttpMeetURL = "https://codrtc.xinhoo.com/"


//#endif


//let HttpMeetURL = "https://meet.jit.si/"


//let WebBaseDomain = "192.168.0.50"
//let HttpMeetURL = "http://192.168.0.50:7443/codmeet/"
//let WebServiveDomain = "http://\(WebBaseDomain):9090"
//let HttpMeetURL = "https://meet.jit.si/"


//let WebBaseDomain = "192.168.0.50"
//let WebBaseDomain = "192.168.0.153"
//let WebBaseDomain = "192.168.0.201"  //云霄


//MARK: 隐私政策 这个是http开头
let COD_Privacy_URL = "\(GeneralURL)/helpermobile/privacy.html"

//MARK: 用户服务协议
let COD_Agreement_URL = "\(GeneralURL)/helpermobile/agreement.html"

//MARK: 帮助
let COD_Help_URL = "\(GeneralURL)/helpermobile/help.html"

//MARK: 意见反馈
let COD_feedback_URL = "\(GeneralURL)/feedback"

class HttpConfig: NSObject {
    
    //清空通知消息
    static var COD_moments_empty_message: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/spread-message/empty-message"
        }
    }
    
    //查询某用户朋友圈图片
    static var COD_moments_get_user_moments_pic: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/moments/get-user-moments-pic"
        }
    }
    
    
    //朋友圈图片上传
    static var COD_moments_uploadImg: String {
        get{
            return "\(WebServiveDomain1)/file/v1/uploadImg"
        }
    }
    
    //朋友圈视频上传
    static var COD_moments_uploadVideo: String {
        get{
            return "\(WebServiveDomain1)/file/v1/uploadVideo"
        }
    }
    
    //朋友圈下载视频
    static var COD_moments_downloadFile: String {
        get{
            return "\(WebServiveDomain1)/file/v1/downloadFile"
        }
    }
    
    //发布朋友圈
    static var COD_add_moments: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/moments/add-moments"
        }
    }
    
    //查看朋友圈
    static var COD_moments_see_moments: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/moments/see-moments"
        }
    }
    
    //删除朋友圈
    static var COD_moments_del_moments: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/moments/del-moments"
        }
    }
    
    //点赞
    static var COD_moments_add_praise: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/message/add-praise"
        }
    }
    
    //取消点赞
    static var COD_moments_del_praise: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/message/del-praise"
        }
    }
    
    //查询朋友圈设定
    static var COD_moments_find_comment: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/comment-setting/find-comment"
        }
    }
    
    //获取朋友圈的通知条数和是否有最新帖子
    static var COD_moments_get_new_moments: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/moments/get-new-moments"
        }
    }
    
    //增量分页查询通知消息
    static var COD_moments_find_incr_message: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/spread-message/find-incr-message"
        }
    }
    
    //全量分页查询通知消息
    static var COD_moments_find_pull_message: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/spread-message/find-pull-message"
        }
    }
    
    //评论
    static var COD_moments_add_comment: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/message/add-comment"
        }
    }
    
    //删除评论
    static var COD_moments_del_comment: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/message/del-comment"
        }
    }
    
    //查询朋友圈详情
    static var COD_moments_get_moments_by_id: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/moments/get-moments-by-id"
        }
    }
    
    //朋友圈设置背景图
    static var COD_moments_set_moments_background: String {
        get{
            return "\(WebServiveDomain3)/rest-api/v1/comment-setting/set-moments-background"
        }
    }
    
    //登录注册
    static var registerUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/registuser"
        }
    }
    
    //所有短信验证登录
    static var SMSloginUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/getuser"
        }
    }
    
    //密码登录
    static var PWLoginUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/login"
        }
    }
    
    //用户名登录
    static var UsernameLoginUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/usernamelogin"
        }
    }
    
    //修改密码
    static var alterPasswordUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/changepassword"
        }
    }
    
    //验证密码
    static var checkCodeUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)verificationservice/checkcodeandtel"
        }
    }
    
    //验证更换手机号码验证码
    static var checkChangePhoneCodeUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)verificationservice/checksafecode"
        }
    }
    
    //重置密码
    static var resetPasswordUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/forgetpassword"
        }
    }
    
    //文件上传路径
    static var uploadUrl: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/uploadFile"
        }
    }
    
    //文件下载路径
    static var downLoadUrl: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/download"
        }
    }
    
    //头像上传路径
    static var COD_HeaderPic_UploadUrl: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/uploadheadimg"
        }
    }
    
    //群头像上传路径
    static var COD_GroupHeaderPic_UploadUrl: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/uploadGroupHeadimg"
        }
    }
    

    //二维码下载路径
    static var COD_QRcode_DownLoadUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)qrcodeservice/qrcode"
        }
    }
    
    //二维码验证路径
    static var COD_QRcode_ValidQRcodeUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)qrcodeservice/validqrcode"
        }
    }
    
    //MARK: 注册session
    static var setPushSession: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/loginsession"
        }
    }
    
    //MARK: 注销session
    static var logoutPushSession: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/logoutsession"
        }
    }
    
    //MARK: 更新客户端ip地址
    static var updateClientIpAddressByResource: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/updateClientIpAddressByResource"
        }
    }
    
    //MARK: 修改session的国家语言设置
    static var updateLang: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/updatesessionbylang"
        }
    }
    
    //MARK: 检查版本
    static var checkVersion: String {
        get{
            return "\(HttpConfig.BaseUrl)updateservice/checkversion"
        }
    }
    
    //MARK: 登录过的设备
    static var loginDevices: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/getaccountloginrecord"
        }
    }
    
    //MARK: 注销的设备
    static var logoutDevices: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/killsession"
        }
    }
    
    //MARK: 时间偏移效验
    static var validTimeStamp: String {
        get{
            return "\(HttpConfig.BaseUrl)commonservice/validtimestamp"
        }
    }
    
    //MARK: 更新未读数量
    static var unreadCount_URL: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/updatepushsession"
        }
    }
    
    //MARK: 验证文件是否存在
    static var COD_Vaildfile: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/vaild"
        }
    }
    
    //MARK: 验证文件迁移是不是成功
    static var COD_VaildTranfile: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/vaildandtranfile"
        }
    }
    
    //MARK: 国家编码
    static var COD_CountryCode: String {
        get{
            return "\(HttpConfig.BaseUrl)areacodeservice/getareacodes"
        }
    }
    
    //MARK: 获取通讯录好友在线状态
    static var COD_GetContactOnlineState: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/getonlinestatususers"
        }
    }
    
    //MARK: 好友请求列表
    static var COD_getRosterRequestList: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/getRosterRequestList"
        }
    }
    
    //MARK: 通讯录邀请好友
    static var COD_inviterRegisterBySms: String {
        get{
            return "\(HttpConfig.BaseUrl)userservice/inviterRegisterBySms"
        }
    }
    
    //找回密码发送短信验证码
    static var resetSMSCodeUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)sendmessageservice/getresetcode"
        }
    }
    
    //获取图片验证码
    static var getPicCodeUrl: String {
        get {
            return "\(HttpConfig.BaseUrl)userservice/searchcontacts"
        }
    }
    
    //获取短信验证码
    static var getSMSCodeUrl: String {
        get{
            return "\(HttpConfig.BaseUrl)sendmessageservice/sendregistcode"
        }
    }
    
    //举报
    static var COD_Report: String {
        get{
            return "\(WebServiveDomain2)/rest-api/v1/tip-off/user-tip-off"
        }
    }
    
    //获取指定ip清单
    static var COD_GetIPList: String {
        get{
            return "\(WebServiveDomain2)/rest-api/v1/srvaddress/get-srvaddress-availablity-list"
        }
    }
    
    //获取全部ip清单
    static var COD_GetALLIPList: String {
        get{
            return "\(WebServiveDomain2)/rest-api/v1/server/address/get-XhServerAddress-Availablity-list"
        }
    }
    
    
    //校验文件是否存在
    static var COD_Valida_File: String {
        get{
            return "\(WebServiveDomain1)/file/openfire/v1/validSha512"
        }
    }
    
    //获取意见反馈token清单
    static var COD_GetFeedBackToken: String {
        get{
            return "\(WebServiveDomain2)/rest-api/v1/feedback/flush-feedback-token"
        }
    }
    
    static var BaseUrl: String {
        get{
            return "\(WebServiveDomain)/plugins/xhcodrestapi/v1/"
        }
    }
    
    
    
}
