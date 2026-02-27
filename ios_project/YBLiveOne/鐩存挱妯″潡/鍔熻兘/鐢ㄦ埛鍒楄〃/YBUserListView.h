//
//  YBUserListView.h
//  YBVideo
//
//  Created by YB007 on 2019/11/30.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UserListBlock)(NSString *eventStr,NSDictionary *eventDic);

typedef NS_ENUM(NSInteger,UserEventType) {
    UserEvent_Leave,
    UserEvent_Enter,
};

@interface YBUserListView : UIView

@property(nonatomic,copy)UserListBlock listEvent;

@property(nonatomic,strong)NSString *liveUid;               //主播uid
@property(nonatomic,strong)NSString *liveStream;            //主播留地址

/** 用户第一次进房间、请求僵尸粉数组赋值 */
-(void)updateListCount:(NSArray *)listArray;

/** 除了自己外的用户进入、离开 */
-(void)userEventOfType:(UserEventType)eventType andInfo:(NSDictionary *)eventDic;

/** 计时器刷新 */
-(void)timerReloadList;

-(void)destroySubs;

@end


