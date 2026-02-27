//
//  YBUserListModel.m
//  YBVideo
//
//  Created by YB007 on 2019/12/3.
//  Copyright © 2019 cat. All rights reserved.
//

#import "YBUserListModel.h"

@implementation YBUserListModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        _rawDic = dic;
        _userID =minstr([dic valueForKey:@"id"]);
        _user_nickname = minstr([dic valueForKey:@"user_nickname"]);
        _iconName = minstr([dic valueForKey:@"avatar"]);
        _sex = minstr([dic valueForKey:@"sex"]);
        _level = minstr([dic valueForKey:@"level"]);
        _vip_type = minstr([[dic valueForKey:@"vip"] valueForKey:@"type"]);
        _signature = minstr([dic valueForKey:@"signature"]);
        _contribution = minstr([dic valueForKey:@"contribution"]);
        
    }
    return self;
    
}
+(instancetype)modelWithDic:(NSDictionary *)dic {
    
    return   [[self alloc]initWithDic:dic];
}
@end
