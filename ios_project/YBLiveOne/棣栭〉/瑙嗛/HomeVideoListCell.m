//
//  HomeVideoListCell.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "HomeVideoListCell.h"

@implementation HomeVideoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_privateBtn setTitle:YZMsg(@"私密") forState:0];
}
-(void)setDataInfo:(NSDictionary *)dataInfo
{
    if ([minstr([dataInfo valueForKey:@"isprivate"]) isEqual:@"1"]) {
        _privateBtn.hidden = NO;
    }else{
        _privateBtn.hidden = YES;

    }
    [self.thumbImg sd_setImageWithURL:[NSURL URLWithString:minstr([dataInfo valueForKey:@"thumb"])]];
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:minstr([dataInfo valueForKey:@"avatar"])]];
    self.nameLb.text = minstr([dataInfo valueForKey:@"user_nickname"]);
    self.titleLb.text = minstr([dataInfo valueForKey:@"title"]);
}
@end
