//
//  YBLookVideoVC.h
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "YBBaseViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/ZFAVPlayerManager.h>


@interface YBLookVideoVC : YBBaseViewController
@property (nonatomic, assign) ZFPlayerScrollViewDirection scrollViewDirection;
@property(nonatomic,strong)NSString *sourceBaseUrl;
//滚动方向(垂直、横向)
@property(nonatomic,assign) NSInteger pushPlayIndex;        //第一次从第几个开始播放

@property(nonatomic,strong)NSMutableArray *videoList;
@property (nonatomic,assign) NSInteger pages;

@end
