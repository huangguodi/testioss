//
//  YBButton.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/1.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger,YBBtnFunc) {
//    BtnFunc_Default,
//
//    BtnFunc_Live_Preview_TurnCamera,    // 预览-翻转
//    BtnFunc_Live_Preview_Beauty,        // 预览-美颜
//    BtnFunc_Live_Preview_Share,         // 预览-分享
//    BtnFunc_Live_Preview_RoomType,      // 预览-房间类型
//};

@interface YBButton : UIButton

@property(nonatomic,assign)LiveEnum btnfunc;

@end


