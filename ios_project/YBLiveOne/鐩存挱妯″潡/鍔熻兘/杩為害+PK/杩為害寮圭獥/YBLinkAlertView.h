//
//  YBLinkAlertView.h
//  yunbaolive
//
//  Created by Boom on 2018/10/29.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^linkAlertBlock)(BOOL isAgree,BOOL isHostLink);


@interface YBLinkAlertView : UIView
- (instancetype)initWithFrame:(CGRect)frame andUserMsg:(NSDictionary *)dic;

@property (nonatomic,copy) linkAlertBlock linkAlertEvent;
@property (nonatomic,copy) UILabel *timeL;
@property(nonatomic,assign)BOOL isHostToHost;           //是否 主播-主播连麦

@property(nonatomic,strong,readonly)NSString *applyUid;

- (void)show;

@end


