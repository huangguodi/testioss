//
//  YBUserListModel.h
//  YBVideo
//
//  Created by YB007 on 2019/12/3.
//  Copyright © 2019 cat. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface YBUserListModel : NSObject

@property(nonatomic,strong)NSDictionary *rawDic;
@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *user_nickname;
@property(nonatomic,strong)NSString *iconName;
@property(nonatomic,strong)NSString *sex;
@property(nonatomic,strong)NSString *level;
@property(nonatomic,strong)NSString *vip_type;
@property(nonatomic,strong)NSString *signature;
@property(nonatomic,strong)NSString *contribution;


-(instancetype)initWithDic:(NSDictionary *)dic;
+(instancetype)modelWithDic:(NSDictionary *)dic;

@end


