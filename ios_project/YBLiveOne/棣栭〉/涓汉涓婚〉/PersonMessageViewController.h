//
//  PersonMessageViewController.h
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "recommendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PersonMessageViewController : YBBaseViewController

@property(nonatomic,strong)NSString *roomUid;// 从直播间进入主页

@property (nonatomic,strong) NSDictionary *liveDic;// 要查看的个人信息

@end

NS_ASSUME_NONNULL_END
