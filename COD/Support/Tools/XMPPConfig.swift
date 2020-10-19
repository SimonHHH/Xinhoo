//
//  XMPPConfig.swift
//  COD
//
//  Created by 1 on 2019/4/10.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

//MARK: 添加好友
//添加好友
let COD_AddRoster = "addroster"
//接受好友
let COD_Acceptroster = "acceptroster"
//拒绝好友
let COD_Rejectroster = "rejectroster"
//相互添加为好友
let COD_Bothroster = "bothroster"

//MARK: 单聊相关
let COD_ChatSetting = "chatSetting" //单聊设定
let COD_GetStatus = "getStatus" //获取联系人的在线状态
let COD_Blacklist = "blacklist"   //黑名单
let COD_SearchUserBID = "searchUserBID"  //根据JID搜索用户信息
let COD_RemarksTelephone = "remarkstelephone"   //修改联系人信息

//MARK: 群相关
let COD_SetCreateJoin = "setcreatejoin"  //创建群组时入群
let COD_SetInvitJoin = "setinvitjoin"   //被邀请入群
let COD_InvitJoin = "invitjoin"   //（群已有）成员加入群组
let COD_refusejoin = "refusejoin"   //被邀请的成员中拒绝入群的成员集合
let COD_CanSpeak = "canspeak"   //（群已有）成員是否可以發言
let COD_MemberJoin = "memberJoin" //群成员扫码自主入群
let COD_QrInvitJoin = "qrinvitjoin" //群成员扫码自主入群
let COD_SetQrInvitJoin = "setqrinvitjoin" //群成员扫码自主入群
let COD_KickOut = "kickout"   //群成员离开群
let COD_SetMucname = "setmucname"  //群名称更改
let COD_TransferOwner = "transferowner" //群主转让
let COD_SetKickOut = "setkickout"  //被移出群组
let COD_SignOut = "signout"   //成员自主退群
let COD_SetSignOut = "setsignout" //为了多端同步，存在服务器系统消息队列中。
let COD_ChangeName = "changename" //成员修改昵称
let COD_SetAdmins = "setadmins"   //设置群管理员
let COD_SetAllAdmins = "setalladmins"   //设置全部为管理员
let COD_SetNotice = "setnotice"   //群公告修改
let COD_Notinvite = "notinvite"   //禁止邀请入群
let COD_userdetail = "userdetail"   /// 禁止查看添加好友
let COD_readrosterrequest = "readrosterrequest"   /// 新的朋友已读
let COD_ChangeGroupAvatar = "changegroupavatar"  //修改群头像
let COD_Savecontacts = "savecontacts"  //保存群组
let COD_Showname = "showname"  //显示名字
let COD_XHReferall = "xhreferall" //群成员@所有人
let COD_groupSetting = "groupSetting" //查询群设置
let COD_getHistoryMessageByPaging = "getHistoryMessageByPaging" //拉取群聊历史消息
let COD_xhshowallhistory = "xhshowallhistory" //允许查看入群前消息
let COD_getuniqueshareid = "getuniqueshareid" //获取群链接
let COD_seturlinvitjoin = "seturlinvitjoin" //群链接加入通知
let COD_urlinvitjoin = "urlinvitjoin" //群链接加入通知
let COD_creatertcroom = "creatertcroom" //群里发起语音通话 通知消息
let COD_endroom = "endrtcroom" //群里结束语音通话 通知消息

let COD_creatertcroommsg = "creatertcroommsg" //通知消息，控制会话列表语音图标显示
let COD_endrtcroommsg = "endrtcroommsg" //通知消息，控制会话列表语音图标隐藏


let COD_clearmsgsync = "clearmsgsync" //清除历史记录
let COD_deletesessionitemsync = "deletesessionitemsync" //删除会话

let COD_momentsbage = "momentsbage"  //朋友圈有人点赞评论
let COD_momentsupdate = "momentsupdate"  //有人发朋友圈

let COD_Stickytop = "stickytop"   //置顶
let COD_Topranking = "topranking"   //拖拽修改置顶排序
let COD_Topmsg = "topmsg"   //置顶

let COD_Mute = "mute" //消息免打扰
let COD_Burn = "burn" //阅后即焚
let COD_GetContactsUpdate = "getContactsUpdate" //通讯录增量更新
let COD_GetContacts = "getContacts" //通讯录
let COD_AutoJoinRoom = "autoJoinRoom" //通知后台自动加群
let COD_Changepassword = "changepassword"
let COD_createchannel = "createchannel"
let COD_searchChannel = "globalsearch"
let COD_globalSearch = "globalsearchbytwov2"
let COD_viewsearchdata = "viewsearchdata"
let COD_channeltype = "channeltype"
let COD_channelsignmsg = "signmsg"

let COD_getMsgByMsgId = "getMsgByMsgId" //根据消息ID 去查询消息
let COD_clearallmsgsync = "clearallmsgsync" //后台清除了所有消息

//MARK: xmlns actionName
let COD_com_xinhoo_setting     = "com:xinhoo:setting"
let COD_com_xinhoo_setting_V2     = "com:xinhoo:setting_v2"

let COD_personSetting          = "personSetting"
let COD_changePerson           = "changePerson"
let COD_changeChat             = "changeChat"
let COD_changeGroup            = "changeGroup"
let COD_quitGroupChat          = "quitGroupChat"
let COD_destroyRoom            = "destroyRoom"
let COD_GroupMembersOnlineTime = "groupMembersOnlineTime"
let COD_CheckUserdesc          = "checkuserdesc"

//删除消息
let COD_com_xinhoo_message  = "com:xinhoo:message"
let COD_com_xinhoo_message_V2  = "com:xinhoo:message_v2"

let COD_removeLocalChatMsg  = "removeLocalChatMsg"
let COD_removeLocalGroupMsg = "removeLocalGroupMsg"
let COD_removeclouddiskmsg  = "removeclouddiskmsg"
let COD_removeChatMsg       = "removeChatMsg"
let COD_removeGroupMsg      = "removeGroupMsg"
let COD_removeChannelMsg      = "removechannelmsg"

let COD_deletesessionitem   = "deletesessionitem"
let COD_clearmsg            = "clearmsg"

//编辑消息
let COD_editedMsg           = "editedmsg"
//已读消息
let COD_com_xinhoo_readed           = "com:xinhoo:readed"
let COD_readedTime           = "readedtime"

let COD_com_xinhoo_contacts = "com:xinhoo:contacts"
let COD_com_xinhoo_contacts_v2 = "com:xinhoo:contacts_v2"
let COD_searchUser          = "searchUser"
let COD_searchUserBID       = "searchUserBID"       //根据jid查询用户信息

let COD_com_xinhoo_roster   = "com:xinhoo:roster"
let COD_deleteRoster        = "deleteroster"
let COD_temporaryfriend     = "temporaryfriend" //创建临时好友

let COD_com_xinhoo_groupChat = "com:xinhoo:groupChat"
let COD_com_xinhoo_groupChat_v2 = "com:xinhoo:groupChat_v2"
let COD_com_xinhoo_groupchatsetting = "com:xinhoo:groupchatsetting"
let COD_getRoomMsgHistory   = "getRoomMsgHistory"

let COD_getCloudMsgHistory  = "getMsgHistoryCDMessage"

let COD_getsessionitemlist = "getsessionitemlist"

let COD_com_xinhoo_favorite = "com:xinhoo:favorite"
let COD_createFavorite      = "createFavorite"
let COD_getFavorite         = "getFavorite"
let COD_setBurn             = "setburn"       //阅后即焚
let COD_screenShot          = "screenshot"    //截屏

//let COD_com_xinhoo_voicerequest = "com:xinhoo:voicerequest" //语音聊天
let COD_call_type_video         = "video"
let COD_call_type_voice         = "voice"

let COD_com_xinhoo_voicerequest = "com:xinhoo:video_v2" //语音聊天
let COD_request                 = "request"                 //请求
let COD_requestmore             = "requestmore"             //邀请更多人
let COD_cancel                  = "cancel"                  //取消
let COD_accept                  = "accept"                  //同意
let COD_reject                  = "reject"                  //拒绝
let COD_close                   = "close"                   //关闭
let COD_calltimeout             = "calltimeout"             //超时
let COD_busy                    = "busy"                    //忙线
let COD_connectfailed           = "connectfailed"           //连接失败
let COD_offer                   = "offer"
let COD_answer                  = "answer"
let COD_ice                     = "candidate"
let COD_heartbeats              = "heartbeats"              //语音通话 心跳包

//xmpp通知
let COD_xinhoo_notice_jf        = "xinhoo:notice:jf"        //后台加群成功通知-客户端去获取历史消息
let xinhoo_notify_session = "xinhoo:notify:session" //后台返回会话列表通知


//MARK: 二维码相关
//添加好友
let COD_QRcode_SearchUser   = "searchuser"
//加群
let COD_QRcode_JoinRoom   = "joinroom"
//待绑定
let COD_QRcode_Pending   = "pending"
//桌面端登录用户
let COD_QRcode_Login   = "login"
//待确认登录(移动端扫描后)
let COD_QRcode_Wconf   = "wconf"


//MARK: 频道相关
let COD_com_xinhoo_channelsetting = "com:xinhoo:channelsetting"
let COD_com_xinhoo_channel = "com:xinhoo:channel"
let COD_com_xinhoo_groupchannel = "com:xinhoo:groupchannel"
let COD_Setchannelsetting = "setchannelsetting"
let COD_Getchannelsetting = "getchannelsetting"
let COD_Addinvitjoinchannel = "addinvitjoinchannel"
let COD_Invitjoinchannel = "invitjoinchannel"
let COD_Getchannelbyjid = "getchannelbyjid"

class XMPPConfig: NSObject {

    
}
