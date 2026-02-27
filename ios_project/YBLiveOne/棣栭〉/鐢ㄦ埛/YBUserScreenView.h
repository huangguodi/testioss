//
//  YBUserScreenView.h
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^YBUserScreenViewBlock)(NSDictionary *dic);
@interface YBUserScreenView : UIView
@property (nonatomic,copy) YBUserScreenViewBlock block;
- (void)show;
@end

NS_ASSUME_NONNULL_END
