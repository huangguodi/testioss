//
//  OnlineUserView.h
//  YBLive
//
//  Created by ybRRR on 2023/6/21.
//  Copyright © 2023 cat. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OnlineUserView : UIView

-(instancetype)initWithFrame:(CGRect)frame;
@property(nonatomic,copy)LiveBlock onlineEvent;
@property(nonatomic,strong)NSDictionary *liveDic;

@end

