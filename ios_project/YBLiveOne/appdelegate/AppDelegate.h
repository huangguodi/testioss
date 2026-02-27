//
//  AppDelegate.h
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/29.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBTabBarController.h"

typedef NS_ENUM(NSInteger,YBAppLifeCycle) {
    APPLifeCycle_Default,           //默认
    APPLifeCycle_EnterForeground,   //进入前台
    APPLifeCycle_EnterBackground,   //进入后台
    APPLifeCycle_WillTerminate,     //杀进程
};
typedef void(^YBAppLifeCycleBlock) (YBAppLifeCycle lifeCycleType);


@interface AppDelegate : YBAppDelegate <UIApplicationDelegate>

@property(nonatomic,copy)YBAppLifeCycleBlock lifeCycleEvent;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic)YBTabBarController *ybtab;

@end

