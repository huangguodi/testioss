//
//  YBVideoControlView.h
//  yunbaolive
//
//  Created by ybRRR on 2020/9/18.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>
#import <ZFVolumeBrightnessView.h>
#import <ZFPlayer/UIImageView+ZFCache.h>
#import <ZFPlayer/ZFUtilities.h>
#import "ZFLoadingView.h"
#import <ZFPlayer/ZFSliderView.h>
#import <ZFPlayer/UIView+ZFFrame.h>

typedef void (^YBControlBlock)(NSString *eventStr,ZFPlayerGestureControl *gesControl);

@interface YBVideoControlView : UIView<ZFPlayerMediaControl>

@property (nonatomic, strong) UIButton *playBtn;
/// 封面图
@property (nonatomic, strong) UIImageView *coverImageView;


@property(nonatomic,copy)YBControlBlock ybContorEvent;
-(void)controlSingleTapped;
-(void)pauseVideo;
- (void)showCoverViewWithUrl:(NSString *)coverUrl withImageMode:(UIViewContentMode)contentMode;
@end

