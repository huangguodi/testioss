//
//  TChatAlertView.h
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/8.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^TChatAlertViewBlock)(int code);
@interface TChatAlertView : UIView
@property(nonatomic,copy)TChatAlertViewBlock block;
- (instancetype)initWithFrame:(CGRect)frame andScreenFrame:(CGRect)screenFrame andtype:(int)type anddration:(int)dration;
@end

NS_ASSUME_NONNULL_END
