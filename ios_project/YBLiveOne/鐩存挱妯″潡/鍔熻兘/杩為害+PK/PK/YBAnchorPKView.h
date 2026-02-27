//
//  YBAnchorPKView.h
//  yunbaolive
//
//  Created by Boom on 2018/11/14.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnchorPKBlock)(void);

@interface YBAnchorPKView : UIView

@property(nonatomic,copy)AnchorPKBlock pkViewEvent;
- (instancetype)initWithFrame:(CGRect)frame andTime:(NSString *)time;
- (void)updateProgress:(CGFloat)progress withBlueNum:(NSString *)blueNum withRedNum:(NSString *)redNum;
- (void)showPkResult:(NSDictionary *)dic andWin:(int)win;
- (void)removeTimer;

@end

