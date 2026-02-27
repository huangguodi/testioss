//
//  YBAnchorUnit.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/5.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBAnchorUnit : UIView
/**
 * uid、stream、avatar、user_nickname
 */
@property(nonatomic,strong)NSDictionary *infoDic;

/**
 * 事件回调
 */
@property(nonatomic,copy)LiveBlock ancEvent;


// 控制关注按钮显示隐藏
-(void)changeAttent:(int)isAttent;

-(int)getAttent;


@end


