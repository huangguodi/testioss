//
//  YBAnchorOnline.h
//  YBVideo
//
//  Created by YB007 on 2020/10/16.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AnchorListType) {
    AnchorListType_Default,
    AnchorListType_Dismiss,
    AnchorListType_StartLink,
};

/** 方法描述-对方主播信息-自己的信息 */
typedef void (^YBAnchorOnlineViewBlock)(AnchorListType callBackType,NSDictionary *otherInfo,NSDictionary *myInfo);

@interface YBAnchorOnline : UIView

@property(nonatomic,strong)NSString *myStream;      //主播自己的stream

@property(nonatomic,copy)YBAnchorOnlineViewBlock anchorListEvent;

+(instancetype)showAnchorListOnView:(UIView *)superView;

-(void)showOnlineView;

@end


