//
//  GuardRankModel.h
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/9.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuardRankModel : NSObject

@property (nonatomic,strong) NSString *type;  //收益榜-0 消费榜-1

@property (nonatomic,strong) NSString *totalCoinStr;
@property (nonatomic,strong) NSString *uidStr;
@property (nonatomic,strong) NSString *unameStr;
@property (nonatomic,strong) NSString *iconStr;
@property (nonatomic,strong) NSString *levelStr;
@property (nonatomic,strong) NSString *level_anchor;
@property (nonatomic,strong) NSString *isAttentionStr;
@property (nonatomic,strong) NSString *sex;

-(instancetype)initWithDic:(NSDictionary *)dic;
+(instancetype)modelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
