//
//  YBImManager.h
//  YBHiMo
//
//  Created by YB007 on 2021/9/15.
//  Copyright © 2021 YB007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TMessageCell.h"
#import "TConversationCell.h"
#pragma mark - 自定义消息 action
/// 用户发起
static const int IMAction_CallUserReq       = 0;
/// 用户取消
static const int IMAction_CallUserCancel    = 1;
/// 主播发起
static const int IMAction_CallAnchorReq     = 2;
/// 主播取消
static const int IMAction_CallAnchorCancel  = 3;
/// 主播接听
static const int IMAction_CallAnchorAgree   = 4;
/// 主播拒绝
static const int IMAction_CallAnchorReject  = 5;
/// 用户接听
static const int IMAction_CallUserAgree     = 6;
/// 用户拒绝
static const int IMAction_CallUserReject    = 7;
/// 主播挂断
static const int IMAction_CallAnchorHang    = 8;
/// 用户挂断
static const int IMAction_CallUserHang      = 9;

/// 拍乐云检测实现
/// 关闭摄像
//static const int IMAction_CallCameraClose   = 10;
/// 打开摄像
//static const int IMAction_CallCameraOpen    = 11;

/**
 * 可以使用 TIMProfileTypeKey_Custom_Prefix 来获取IM的前缀
 * Tag_Profile_Custom_age           年龄
 * Tag_Profile_Custom_avatar        头像
 * Tag_Profile_Custom_city          城市
 * Tag_Profile_Custom_nickname      昵称
 * Tag_Profile_Custom_sex           性别
 * Tag_Profile_Custom_sign          签名（交友心声）
 */
/// 这里定义了用户信息后缀,请勿改动,需要和腾讯IM控制台统一
#define IMKey_Custom_Suffix_Avatar      @"Avatar"
#define IMKey_Custom_Suffix_Nickname    @"nickname"  //Username

typedef NS_ENUM(NSInteger,ImCallType) {
    ImCallType_Audio,
    ImCallType_Video,
};

typedef void (^ImStatusBlock)(BOOL isSucc);
typedef void (^ImDownLoadImgBlock)(BOOL isSucc);
//typedef void (^ImGroupListBlock)(NSArray *groupList);
//typedef void (^ImUpdateListBlock)(NSMutableArray *dataList);
//typedef void (^ImTransformBlock)(NSString *transformStr);
//typedef void (^ImTransformArrayBlock)(NSArray *transformArray);
typedef void (^ImGetUnreadBlock)(int allUnread);
typedef void (^ImGetConversationListBlock)(NSMutableArray *CovList, BOOL isSuccess);
typedef void (^ImRecevNewMsgBlock)(TMessageCellData *receData);    //获取新消息
typedef void (^ImSendV2MsgBlock)(BOOL isSuccess, V2TIMMessage*sendMsg, NSString *desc);    //发送消息


@interface YBImManager : NSObject

+(instancetype)shareInstance;

#pragma mark - 加入群组
-(void)joinGroup;

#pragma mark - 登录、登出
-(void)imLogin;
-(void)imLogout;

#pragma mark -  V2TIM 发送消息
-(void)sendV2ImMsg:(TMessageCellData *)msg andReceiver:(NSString *)receiverID complete:(ImSendV2MsgBlock)sendFinish;
#pragma mark -  V2TIM 发送自定义消息
-(void)sendV2CustomMsg:(V2TIMCustomElem *)customMsg andReceiver:(NSString *)receiverID complete:(ImSendV2MsgBlock)sendFinish;
#pragma mark - 消息转换
- (V2TIMMessage *)transIMMsgFromUIMsg:(TMessageCellData *)data;
#pragma mark -  V2TIM 收到新消息
-(void)onRecvNewMessage:(V2TIMMessage *)msg complete:(ImRecevNewMsgBlock)newMsg;
/// 播放、停止响铃
-(void)playAudioCall;
//-(void)stopAudioCall;

///// 消息提示
//- (void)tryPlayMsgAlertWithSenderid:(NSString *)senderUid;

//#pragma mark - 消息处理
//-(void)addNoti;

#pragma mark - 获取未读消息数
-(void)getAllUnredNumExceptUser:(NSArray *)userList complete:(ImGetUnreadBlock)finish;
#pragma mark - 获取会话列表
-(void)getConversationList:(ImGetConversationListBlock)covBlock;
#pragma mark - 获取所有用户会话列表
-(void)getAllConversationList:(ImGetConversationListBlock)covBlock;

#pragma mark - 清空所有会话的未读消息数。
-(void)clearAllUnreadConv;
#pragma mark - 清除某一个用户未读
-(void)clearUnreadConvId:(NSString *)convid sendNot:(BOOL)send;
-(void)sendClearNot;

-(TConversationCellData *)createEmptyCellDataWithId:(NSString *)convid;
@end


