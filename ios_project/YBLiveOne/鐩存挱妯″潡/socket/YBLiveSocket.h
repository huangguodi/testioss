//
//  YBLiveSocket.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/15.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface YBLiveSocket : NSObject

@property(nonatomic,assign)BOOL musicIsPlay;                    //是否在播放伴奏

+(instancetype)shareInstance;

@property(nonatomic,strong)NSString *userType;                  //用户类型:普通用户-30;房间管理-40;主播-50;超管-60;
@property(nonatomic,copy)LiveBlock socketEvent;

/** 链接 */
-(void)socketConnectInfo:(NSDictionary *)roomInfo role:(LiveEnum)role;
/** 断开 */
-(void)socketDisconnect;


/** 系统通知 */
-(void)socketSendSystem:(NSString *)conStr conStrEn:(NSString *)conStrEn;
/** 踢人 */
-(void)socketSendKick:(NSDictionary *)conDic;
/** 禁言 */
-(void)socketSendShutUpUser:(NSDictionary *)conDic;
/** 设置取消管理 */
-(void)socketSendSetAdmin:(NSDictionary *)conDic;
/** 更新映票 */
-(void)socketSendUpdateVotes:(NSDictionary *)conDic;
/** 僵尸粉 */
-(void)socketSendRequestFans;
/** 个人资料开关 */
-(void)socketSendLiveUdataSwitch:(NSDictionary *)conDic;
/** 弹幕 */
-(void)socketSendSendBarrage:(NSString *)conStr;
/** 礼物 */
-(void)socketSendSendGift:(NSDictionary *)conDic;
/** 发送文字 */
-(void)socketSendSendMsg:(NSString *)conStr;
/** 超管关播 */
-(void)socketSendSuperStopLive;
/** 主播关播 */
-(void)socketSendEndLive;
/** 点亮 */
-(void)socketSendScreenLight:(NSDictionary *)conDic;

/** 用户连麦 */
-(void)socketSendUserLink:(NSDictionary *)conDic;
/** 主播连麦 */
-(void)socketSendAnchorLink:(NSDictionary *)conDic;
/** PK */
-(void)socketSendLivePKAction:(NSString *)action;

@end


