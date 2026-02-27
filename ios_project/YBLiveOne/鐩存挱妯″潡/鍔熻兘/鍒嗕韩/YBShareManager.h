//
//  YBShareManager.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/5.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,ShareEnum) {
    Share_Default,
    Share_Live_Preview,     // 开播前分享
    Share_Live_Room,        // 主播、用户直播间内分享
};
typedef NS_ENUM(NSInteger,FinishEnum) {
    Finish_Default,
};
typedef void (^ShareFinish)(FinishEnum fenum, NSDictionary *extDic);

@interface YBShareManager : UIView

/**
 * 分享参数：根据 ShareEnum 类型 key、value 自行定义
 */
@property(nonatomic,strong)NSDictionary *shareParam;

+(instancetype)shareInstance;
/**
 * 使用方式一：分享有UI
 */
-(void)shareUiWithEnum:(ShareEnum)senum finish:(ShareFinish)finish;

/**
 * 使用方式二：分享无UI
 */
-(void)sharePlat:(NSString *)plat andEnum:(ShareEnum)senum finish:(ShareFinish)finish;




@end


