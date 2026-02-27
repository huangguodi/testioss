//
//  YBVideoControlView.m
//  yunbaolive
//
//  Created by ybRRR on 2020/9/18.
//  Copyright © 2020 cat. All rights reserved.
//

#import "YBVideoControlView.h"

@implementation YBVideoControlView
@synthesize player = _player;
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.playBtn];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImageView.frame = self.player.currentPlayerManager.view.bounds;

    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 100;
    CGFloat min_h = 100;
    self.playBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.playBtn.center = self.center;
}
- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
    /*
    [self.bgImgView addSubview:self.effectView];
     */
    [player.currentPlayerManager.view insertSubview:self.coverImageView atIndex:1];
}

#pragma mark - eeee

-(void)controlSingleTapped {
    if (self.player.currentPlayerManager.isPlaying) {
        [self.player.currentPlayerManager pause];
        NSLog(@"22222===:%lu",self.player.currentPlayerManager.playState);
        self.playBtn.hidden = NO;
        self.playBtn.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        [UIView animateWithDuration:0.2f delay:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.playBtn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    } else {
        [self.player.currentPlayerManager play];
        self.playBtn.hidden = YES;
    }
}
-(void)pauseVideo{
    [self.player.currentPlayerManager pause];
    NSLog(@"22222===:%lu",self.player.currentPlayerManager.playState);
    self.playBtn.hidden = NO;
    self.playBtn.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f delay:0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.playBtn.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];

}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    
    if (self.ybContorEvent) {
        self.ybContorEvent(@"控制-单击",gestureControl);
    }
}
/// 加载状态改变
- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state {
    if (state == ZFPlayerLoadStatePrepare) {
        self.coverImageView.hidden = NO;
    } else if (state == ZFPlayerLoadStatePlaythroughOK || state == ZFPlayerLoadStatePlayable) {
        self.coverImageView.hidden = YES;
        //缓冲的时候点击了暂停
        if (self.playBtn.hidden == NO) {
            [videoPlayer.currentPlayerManager pause];
        }
    }
    if ((state == ZFPlayerLoadStateStalled || state == ZFPlayerLoadStatePrepare) && videoPlayer.currentPlayerManager.isPlaying) {
//        [self.sliderView startAnimating];
    } else {
        
//        [self.sliderView stopAnimating];
    }
}
- (void)videoPlayer:(ZFPlayerController *)videoPlayer playStateChanged:(ZFPlayerPlaybackState)state {
//    NSLog(@"rk_===playState:%lu",(unsigned long)state);
//    if (_isDisappear&&state==ZFPlayerPlayStatePlaying) {
//        NSLog(@"rk_实行了");
//        [self.player stopCurrentPlayingCell];
//    }

}

#pragma mark - sss
- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    if (self.ybContorEvent) {
        self.ybContorEvent(@"控制-双击",gestureControl);
    }
}

- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location;{
    if (direction == 2 && location == 2) {
        //侧滑进入个人主页
        if (self.ybContorEvent) {
            self.ybContorEvent(@"控制-主页",gestureControl);
        }
    }
    NSLog(@"rk_____end--dir:%lu==loc:%lu",(unsigned long)direction,(unsigned long)location);
}
- (void)showCoverViewWithUrl:(NSString *)coverUrl withImageMode:(UIViewContentMode)contentMode {
    self.coverImageView.contentMode = contentMode;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:[UIImage imageNamed:@"img_video_loading"]];
    /*
    [self.bgImgView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];
     */
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.userInteractionEnabled = NO;
        [_playBtn setImage:[UIImage imageNamed:@"ask_play"] forState:UIControlStateNormal];
        _playBtn.hidden = YES;
    }
    return _playBtn;
}
- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

@end
