//
//  YBTxLinkMicView.h
//  YBVideo
//
//  Created by YB007 on 2020/10/15.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TxLinkEventType) {
    TxLinkEventType_Default,
    TxLinkEventType_StartPush,          //开始推流
    TxLinkEventType_StopPush,           //停止推流
    TxLinkEventType_LinkDisconnect,     //断开连麦
    TxLinkEventType_ShadowClick,        //整体点击事件
};
typedef void (^TxLinkMicBlock)(TxLinkEventType eventType,NSDictionary *eventDic);

@interface YBTxLinkMicView : UIView

@property(nonatomic,copy)TxLinkMicBlock linkMicEvent;
@property(nonatomic,strong)NSDictionary *linkDic;

@property(nonatomic,assign,readonly)BOOL isHostToHost;

+(instancetype)createLinkMicViewOnSuper:(UIView*)superView andHostToHost:(BOOL)isHostToHost;

-(void)linkMicShowViewHaveCloseBtn:(BOOL)haveCloseBtn;

-(void)linkMicViewDismiss;

-(void)linkMicMixStream:(NSDictionary *)mixStreamDic andHostToHost:(BOOL)isHostToHost;

//主播-用户连麦上报信息
-(void)linkMicUploadInfo:(NSDictionary *)uploadDic;

/** 键盘弹起事件: 目前只处理 PK和连麦 的界面相对位置不变*/
-(void)keyBoardNoticeIsShow:(BOOL)isShow andHeight:(CGFloat)height;


#pragma mark - 扬声器操作[主播端]
-(void)speakerCtr:(BOOL)mute;

#pragma mark - 麦克风操作【用户端】
-(void)audioCtr:(BOOL)mute;
@end


