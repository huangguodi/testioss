//
//  UserForbiddenView.m
//  YBLive
//
//  Created by ybRRR on 2019/11/8.
//  Copyright © 2019 cat. All rights reserved.
//

#import "UserForbiddenView.h"

@implementation UserForbiddenView

-(void)setInfoData:(NSDictionary *)infos{
    self.titlelb.text = YZMsg(@"账号已被封禁");
    self.fjLb.text = YZMsg(@"封禁说明:");
    self.fjscLb.text = YZMsg(@"封禁时长:");
    [self.zhidaoLb setTitle:YZMsg(@"知道了") forState:0];

    self.forbiddenInfoLb.text = minstr([infos valueForKey:@"ban_reason"]);
//    self.forbiddenTimeLb.text = [NSString stringWithFormat:@"%@%@,%@%@%@",YZMsg(@"本次封禁时间为"),minstr([infos valueForKey:@"ban_long"]),YZMsg(@"账号将于"),minstr([infos valueForKey:@"end_bantime"]),YZMsg(@"解除封禁")];
    self.forbiddenTimeLb.text = minstr([infos valueForKey:@"ban_tip"]);
}


- (IBAction)sureBtnClick:(UIButton *)sender {
    if (self.hideSelf) {
        self.hideSelf();
    }
}

@end
