//
//  YBAnchorPKAlert.h
//  yunbaolive
//
//  Created by Boom on 2018/11/29.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AnchorPkAlertType) {
    PkAlertType_Default,
    PkAlertType_TimeOut,
    PkAlertType_Agree,
    PkAlertType_unAgree,
};

typedef void (^AnchorPKAlertBlock)(AnchorPkAlertType pkAlertType);

@interface YBAnchorPKAlert : UIView

@property(nonatomic,copy)AnchorPKAlertBlock anchorPkEvent;

- (instancetype)initWithFrame:(CGRect)frame andIsStart:(BOOL)start;

- (void)removeTimer;

@end


