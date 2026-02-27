//
//  GuardRankModel.m
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/9.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "GuardRankModel.h"

@implementation GuardRankModel
- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        
        _totalCoinStr = YBValue(dic, @"totalcoin");
        _uidStr = YBValue(dic, @"uid");
        _unameStr = YBValue(dic, @"user_nickname");
        _iconStr = YBValue(dic, @"avatar_thumb");
        _level_anchor = YBValue(dic, @"level_anchor");
        _levelStr = YBValue(dic, @"level");
        _isAttentionStr = YBValue(dic, @"isAttention");
        _sex = YBValue(dic, @"sex");

    }
    return self;
}
+(instancetype)modelWithDic:(NSDictionary *)dic {
     return [[self alloc]initWithDic:dic];
}

@end
