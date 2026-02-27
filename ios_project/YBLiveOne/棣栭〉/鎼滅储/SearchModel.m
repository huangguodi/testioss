//
//  SearchModel.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SearchModel.h"

@implementation SearchModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        _userID = minstr([dic valueForKey:@"id"]);
        _user_nickname = minstr([dic valueForKey:@"user_nickname"]);
        _sex = minstr([dic valueForKey:@"sex"]);
        _avatar = minstr([dic valueForKey:@"avatar"]);
        _signature = minstr([dic valueForKey:@"signature"]);
        _level = minstr([dic valueForKey:@"level"]);
        _level_anchor = minstr([dic valueForKey:@"level_anchor"]);
        _fans = minstr([dic valueForKey:@"fans"]);
        _coin = minstr([dic valueForKey:@"coin"]);
        if ([dic.allKeys containsObject:@"u2t"]) {
            _isAtt = minstr([dic valueForKey:@"u2t"]);
        }else{
            _isAtt = @"1";
        }
       
        _subscribeid = minstr([dic valueForKey:@"subscribeid"]);
        _isauth = minstr([dic valueForKey:@"isauth"]);
        _isauthor_auth =minstr([dic valueForKey:@"isauthor_auth"]);
        _isVip = minstr([dic valueForKey:@"isvip"]);
        _isblack = minstr([dic valueForKey:@"isblack"]);
        _type = minstr([dic valueForKey:@"type"]);
        _online = minstr([dic valueForKey:@"online"]);
        _can_sayhi = minstr([dic valueForKey:@"can_sayhi"]);

    }
    return self;
}
@end
