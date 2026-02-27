//
//  YBAnchorLinkInfo.h
//  YBVideo
//
//  Created by YB007 on 2022/3/3.
//  Copyright © 2022 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ToHostAttentStatus)(int isAttent);

@interface YBAnchorLinkInfo : UIView

@property(nonatomic,assign,readonly)int toIsattent;
@property(nonatomic,copy)ToHostAttentStatus attentEvent;

+(YBAnchorLinkInfo *)showHostInfoWithSuperView:(UIView *)superView;
/// 获取对方主播信息
-(void)reqToHostInfo:(NSString*)toHostid;
/// 关注
-(void)updateFollow;

-(void)keyboardChangeHeight:(CGFloat)height;
@end

