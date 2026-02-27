//
//  recommendModel.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "recommendModel.h"

@implementation recommendModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _isvideo = [minstr([dic valueForKey:@"isvideo"]) intValue];
        _isvoice = [minstr([dic valueForKey:@"isvoice"]) intValue];

        _voice_value =minstr([dic valueForKey:@"voice_value"]);
        _video_value =minstr([dic valueForKey:@"video_value"]);
        if (_isvideo == 1) {
            if (_isvoice == 1) {
                _typeArray = @[@{@"icon":@"home_价格视频",@"content":[NSString stringWithFormat:@"%@%@/%@",minstr([dic valueForKey:@"video_value"]),[common name_coin],YZMsg(@"分钟")]},@{@"icon":@"home_价格语音",@"content":[NSString stringWithFormat:@"%@%@/%@",minstr([dic valueForKey:@"voice_value"]),[common name_coin],YZMsg(@"分钟")]}];
            }else{
                _typeArray = @[@{@"icon":@"home_价格视频",@"content":[NSString stringWithFormat:@"%@%@/%@",minstr([dic valueForKey:@"video_value"]),[common name_coin],YZMsg(@"分钟")]}];

            }
        }else {
            if (_isvoice == 1) {
                _typeArray = @[@{@"icon":@"home_价格语音",@"content":[NSString stringWithFormat:@"%@%@/%@",minstr([dic valueForKey:@"voice_value"]),[common name_coin],YZMsg(@"分钟")]}];
            }else{
                _typeArray = @[];
            }

        }
        _thumb = minstr([dic valueForKey:@"thumb"]);
        _avatar = minstr([dic valueForKey:@"avatar"]);
        _userID = minstr([dic valueForKey:@"id"]);
        _level_anchor = minstr([dic valueForKey:@"level_anchor"]);
        _online = minstr([dic valueForKey:@"online"]);
        _sex = minstr([dic valueForKey:@"sex"]);
        _signature = minstr([dic valueForKey:@"signature"]);
        _user_nickname = minstr([dic valueForKey:@"user_nickname"]);
        _distance = minstr([dic valueForKey:@"distance"]);
        _can_sayhi = minstr([dic valueForKey:@"can_sayhi"]);
    }
    return self;
}
@end
