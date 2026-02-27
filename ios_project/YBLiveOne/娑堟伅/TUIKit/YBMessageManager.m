//
//  YBMessageManager.m
//  YBHiMo
//
//  Created by YB007 on 2021/9/14.
//  Copyright © 2021 YB007. All rights reserved.
//

#import "YBMessageManager.h"
//#import "TChatC2CController.h"
//#import "YBMsgPageVC.h"

@implementation YBMessageManager

static YBMessageManager *_msgManager = nil;


+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _msgManager = [[super allocWithZone:NULL]init];
    });
    return _msgManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return  [self shareManager];;
}

-(void)goChatListVC; {
    
//    YBMsgPageVC *msgVC = [[YBMsgPageVC alloc]init];
//    msgVC.isPush = YES;
//    [[YBAppDelegate sharedAppDelegate] pushViewController:msgVC animated:YES];
    
}

-(void)chatWithUser:(NSString*)userid; {
    
//    [YBNetWorking getRelationshipOfMicUser:userid complete:^(NSDictionary * _Nonnull relationDic) {
//        TConversationCellData *data = [[TConversationCellData alloc] init];
//        data.convId = userid;
//        data.convType = TConv_Type_C2C;
//        data.title = strFormat([relationDic valueForKey:@"user_nickname"]);
//        data.userHeader = strFormat([relationDic valueForKey:@"avatar"]);
//        data.userName = strFormat([relationDic valueForKey:@"user_nickname"]);
//        //data.isauth = model.isauth;
//        data.isAtt = strFormat([relationDic valueForKey:@"isattent"]);
//        data.isVIP = strFormat([[relationDic valueForKey:@"vip"] valueForKey:@"type"]);
//        data.isblack = strFormat([relationDic valueForKey:@"isblack"]);
//        TChatC2CController *chat = [[TChatC2CController alloc] init];
//        chat.conversation = data;
//        [[YBAppDelegate sharedAppDelegate] pushViewController:chat animated:YES];
//    }];
}

@end
