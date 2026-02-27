//
//  YBMessageManager.h
//  YBHiMo
//
//  Created by YB007 on 2021/9/14.
//  Copyright © 2021 YB007. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 群组cell类型
typedef NS_ENUM(NSInteger,CellListType) {
    CellListType_Normal,        // 普通列表
    CellListType_SelMember,     // 选择成员
};
/// 选择成员类型
typedef NS_ENUM(NSInteger,SelMemberType) {
    SelMemberType_Create,       // 创建群组选人
    SelMemberType_Invite,       // 邀请成员选人
};
/// 群内的身份
typedef NS_ENUM(NSInteger,GroupIdentity) {
    GroupIdentity_Normal,       // 普通用户
    GroupIdentity_Own,          // 群主
    GroupIdentity_Admin,        // 群管理
};
typedef NS_ENUM(NSInteger,MsgUiType) {
    MsgUiType_C2C,
    MsgUiType_Group,
};
NS_ASSUME_NONNULL_BEGIN

@interface YBMessageManager : NSObject

+(instancetype)shareManager;

// 私信列表
-(void)goChatListVC;
// 私信对话
-(void)chatWithUser:(NSString*)userid;




@end

NS_ASSUME_NONNULL_END
