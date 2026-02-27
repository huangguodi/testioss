//
//  SystemViewController.h
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/18.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SystemViewController : YBBaseViewController

@property(nonatomic,assign)LiveEnum uiFrom;
- (void)liveImRequest;

@end

NS_ASSUME_NONNULL_END
