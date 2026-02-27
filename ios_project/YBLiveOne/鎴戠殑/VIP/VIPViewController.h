//
//  VIPViewController.h
//  YBLiveOne
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^buyVipEvent)(void);
@interface VIPViewController : YBBaseViewController
@property (nonatomic, copy)buyVipEvent vipBlock;
@end
