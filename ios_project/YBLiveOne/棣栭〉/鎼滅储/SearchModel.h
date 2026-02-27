//
//  SearchModel.h
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchModel : NSObject
-(instancetype)initWithDic:(NSDictionary *)dic;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *user_nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *signature;
@property (nonatomic,strong) NSString *level;
@property (nonatomic,strong) NSString *fans;
@property (nonatomic,strong) NSString *level_anchor;
@property (nonatomic,strong) NSString *coin;
@property (nonatomic,strong) NSString *isAtt;
@property (nonatomic,strong) NSString *subscribeid;
@property (nonatomic,strong) NSString *isauth;
@property (nonatomic,strong) NSString *isauthor_auth;
@property (nonatomic,strong) NSString *isVip;
@property (nonatomic,strong) NSString *isblack;
//1视频 2语音
@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *online;
@property (nonatomic,strong) NSString *can_sayhi;


@end

NS_ASSUME_NONNULL_END
