//
//  YBLiveHeader.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/8/31.
//  Copyright © 2023 iOS. All rights reserved.
//

#ifndef YBLiveHeader_h
#define YBLiveHeader_h


/// 直播相关 通知宏
 
// 用户资料卡
#define Live_Notice_Userinfo        @"yb_live_userinfo_pop"
// 公屏消息
#define Live_Notice_RoomMsg         @"yb_live_socket_msg"
// 用户离开、进入
#define Live_Notice_UserLeave       @"yb_live_socket_user_leave"
#define Live_Notice_UserEnter       @"yb_live_socket_user_enter"
// 进场动画
#define Live_Notice_EnterAni        @"yb_live_socket_enter_animation"
// 点亮
#define Live_Notice_Light           @"yb_live_socket_user_light"
// 弹幕
#define Live_Notice_Barrage         @"yb_live_socket_barrage"
// 增加映票
#define Live_Notice_Votes           @"yb_live_socket_votes_update"
// 礼物
#define Live_Notice_GiftSoc         @"yb_live_socket_send_gift"
// pk进度
#define Live_Notice_PKProgress      @"yb_live_socket_pk_progress"
// IM小窗高度改变
#define ybImSamllChange             @"ybImSamllChangeEvent"
// 关注状态变化
#define Live_Notice_Attention       @"yb_live_socket_isattention"
// 直播间At某人发言
#define Live_Notice_AtMsg           @"yb_live_input_msg_at"
// 直播间向某人发送私信
#define Live_Notice_SendChat        @"yb_live_send_chat_c2c"
// 直播间僵尸粉
#define Live_Notice_RoomFans        @"yb_live_room_fans"
// 展示用户连麦小窗
#define Live_Notice_UserLinkPop     @"yb_live_link_show_user_pop"
// 连麦用户挂断
#define Live_Notice_UserHung        @"yb_live_link_user_disconnect"
// 主播同意连麦
#define Live_Notice_AnchorAgree     @"yb_live_link_anchor_agree"
// 主播拒绝连麦
#define Live_Notice_AnchorRefuse    @"yb_live_link_anchor_refuse"
// 主播下麦用户|主播忙碌|主播超时【通知用户端销毁连麦窗口】
#define Live_Notice_RemoveLinkPop   @"yb_live_link_anchor_down_user"
// 主播移除连麦列表弹窗
#define Live_Notice_RemoveOnline    @"yb_live_anchor_link_remove_online"
// 主播-主播连麦成功、关闭连麦通知
#define Live_Notice_AnchorLinkChange    @"yb_live_anchor_link_success"
// PK开始
#define Live_Notice_PKStart             @"yb_live_pk_start"
// PK结果
#define Live_Notice_PKRes               @"yb_live_pk_res"
// PK改变pk按钮
#define Live_Notice_PKBtn               @"yb_live_pk"

/// 直播相关 枚举+Block
typedef NS_ENUM(NSInteger, LiveEnum) {
    
    /**
     * 各个事件-可自行扩展
     */
    
    Live_Default,               // 默认
    
    /// 主播开播前的预览
    Live_Preview_Close,         // 直播预览关闭
    Live_Preview_TurnCamera,    // 预览-翻转
    Live_Preview_Beauty,        // 预览-美颜
    Live_Preview_Share,         // 预览-分享
    Live_Preview_RoomType,      // 预览-房间类型
    Live_PreView_CreateSuc,     // 开播成功
    
    /// 主播设置房间类型
    Live_Set_Room_Normal,       // 普通
    Live_Set_Room_Ticket,       // 门票
    Live_Set_Room_Pwd,          // 密码
    Live_Set_Room_Time,         // 计时
    
    /// 用户进房间==>类型提示
    Live_User_Room_TxtAlert,    // 门票、计时房间进入前的提示语显示
    Live_User_Room_Pwd,         // 密码房间输入密码
    Live_Alert_Room_Close,      // 弹窗-右上角关闭
    Live_Alert_Room_Cancel,     // 弹窗-取消
    Live_Alert_Room_Sure,       // 弹窗-确认
    Live_Alert_Room_Next,       // 弹窗-下一个
    
    /// 直播间控制层UI
    Live_Ctr_Close,             // 直播间关闭
    
    /// 映票点击事件
    Live_Room_Tickt,
    
    /// 直播间-底部功能键-更多UI
    Live_More_Close,            // 关闭
    Live_More_Beauty,           // 美颜
    Live_More_TurnCamera,       // 翻转摄像头
    Live_More_Torch,            // 闪光灯
    Live_More_Music,            // 伴奏
    Live_More_Share,            // 分享
    Live_More_Message,          // 私信
    Live_More_UserLink,         // 用户连麦
    Live_More_AnchorLink,       // 主播连麦
    Live_More_Mirror,           // 镜像
    Live_More_UserInfo,         // 用户资料
    
    /// 直播间用户弹窗
    Live_User_Pop,              // 用户头像点击事件
    Live_User_Follow,           // 关注事件
    
    /// socket角色
    Live_Socket_User,           // 用户
    Live_Socket_Anchor,         // 主播
    
    /// socket事件
    Live_Socket_CheckLive,      // socekt发生重连,需要主播主动检测直播状态
    Live_Socket_SuperClose,     // 超管关播
    Live_Socket_BanReason,      // 主播端提示关播原因：
    Live_Socket_LiveOver,       // 直播结束，请求结束接口
    Live_Socket_UserLight,      // 用户点亮
    Live_Socket_SetAdmin,       // 设置-取消管理
    Live_Socket_Kick,           // 被踢出房间
    Live_Socket_Conn,           // socket链接
    
    
    ///直播间输入框
    Live_Chat_Msg,              // 公屏聊天输入框
    
    /// 直播间私信
    Live_Im_Samll,
    
    /// 在线观众
    Live_Online_Close,
    
    /// 直播结束界面点击事件
    Live_EndLive_Close,
    
    /// 用户-主播连麦
    Live_UserLink_Replay,       // 用户连麦-重新播放
    
    /// 伴奏
    Live_Music_Stop,            // 停止伴奏
    
    /// 网络
    Live_Net_Suc,
    Live_Net_Fail,
};
typedef void (^LiveBlock)(LiveEnum event,NSDictionary *eventDic);

#endif /* YBLiveHeader_h */
