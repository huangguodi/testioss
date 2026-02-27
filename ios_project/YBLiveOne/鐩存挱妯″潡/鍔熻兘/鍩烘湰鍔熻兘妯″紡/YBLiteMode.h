//
//  YBLiteMode.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/23.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PageFrom) {
    PageFrom_AppDelegate,           // appdelegate
    PageFrom_Home                   // 首页
};


typedef void (^LiteModeBlock)(int event);

@interface YBLiteMode : UIView

+(instancetype)shareInstance;

@property(nonatomic,copy)LiteModeBlock liteEvent;


/** 判断是否为基本功能模式 */
-(BOOL)checkShow;

/** 展示基本功能模式弹窗 */
-(void)showBaseModeAlert:(PageFrom)from;

/** 首页全功能按钮 */
-(void)showLiteAllBtn;

@end


