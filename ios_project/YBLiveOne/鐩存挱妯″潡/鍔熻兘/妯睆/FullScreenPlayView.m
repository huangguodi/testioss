//
//  FullScreenPlayView.m
//  YBLive
//
//  Created by ybRRR on 2021/11/24.
//  Copyright © 2021 cat. All rights reserved.
//

#import "FullScreenPlayView.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <TXLiteAVSDK_Professional/V2TXLivePlayer.h>
@interface FullScreenPlayView ()<V2TXLivePlayerObserver>
@property (nonatomic, strong) ZFPlayerController *videoPlayer;

@end
@implementation FullScreenPlayView
{
    V2TXLivePlayer *       _txLivePlayer;
    TXLivePlayConfig*    _config;
    
    UIButton *returnBtn;
    UILabel *nameLb;

}
-(instancetype)initWithFrame:(CGRect)frame withType:(NSString *)sdkType andPlayDic:(NSDictionary *)playDic
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tipsGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tipClick)];
        [self addGestureRecognizer:tipsGesture];
        
        self.playDoc = playDic;
        self.backgroundColor = UIColor.whiteColor;
        returnBtn = [UIButton buttonWithType:0];
        [returnBtn setImage:[UIImage imageNamed:@"personBack"] forState:0];
        [returnBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:returnBtn];
        [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(30+ShowDiff);
            make.top.equalTo(self.mas_top).offset(20);
            make.width.height.mas_equalTo(30);
        }];
        
        nameLb = [[UILabel alloc]init];
        nameLb.font = [UIFont systemFontOfSize:14];
        nameLb.textColor = UIColor.whiteColor;
        nameLb.text = minstr([playDic valueForKey:@"user_nickname"]);
        [self addSubview:nameLb];
        [nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(returnBtn.mas_right).offset(10);
            make.centerY.equalTo(returnBtn.mas_centerY);
        }];
        [self layoutIfNeeded];
        //关注主播
        _focusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _focusBtn.frame = CGRectMake(nameLb.right+10,5,40,25);
        _focusBtn.centerY = nameLb.centerY;
        _focusBtn.layer.masksToBounds = YES;
        _focusBtn.layer.cornerRadius = 12.5;
        _focusBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        [_focusBtn setTitle:YZMsg(@"关注") forState:UIControlStateNormal];
        _focusBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_focusBtn addTarget:self action:@selector(guanzhuzhubo) forControlEvents:UIControlEventTouchUpInside];
        _focusBtn.hidden = YES;
        [_focusBtn setBackgroundImage:[UIImage imageNamed:@"startLive_back"]];
        [self addSubview:_focusBtn];

        [self txPlayer];
        [self  hideAllBtn];
    }
    return self;
}
-(void)hideAllBtn{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            CGRect returnBtnFrame = returnBtn.frame;
            returnBtnFrame.origin.y = -50;
            returnBtn.frame = returnBtnFrame;

            nameLb.centerY = returnBtn.centerY;
            _focusBtn.centerY = returnBtn.centerY;
            
//            CGRect nameLbFrame = nameLb.frame;
//            nameLbFrame.origin.y =  -50;
//            nameLb.frame = nameLbFrame;
//
//            CGRect focusFrame = _focusBtn.frame;
//            focusFrame.origin.y =  -50;
//            _focusBtn.frame = focusFrame;

        }];
    });

}
-(void)tipClick{
    [UIView animateWithDuration:0.5 animations:^{
            CGRect returnBtnFrame = returnBtn.frame;
            returnBtnFrame.origin.y = 20;
            returnBtn.frame = returnBtnFrame;

            nameLb.centerY = returnBtn.centerY;
            _focusBtn.centerY = returnBtn.centerY;

        } completion:^(BOOL finished) {
            if (finished) {
                [self hideAllBtn];
            }
        }];

}

#pragma mark -视频播放器
-(ZFPlayerController *)videoPlayer{
    if(!_videoPlayer){
        /*
        ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
        NSString *ijkRef = [NSString stringWithFormat:@"Referer:%@\r\n",h5url];
        [playerManager.options setFormatOptionValue:ijkRef forKey:@"headers"];
         */
        // #import <ZFPlayer/ZFAVPlayerManager.h>
        ZFAVPlayerManager*playerManager = [[ZFAVPlayerManager alloc] init];
        NSDictionary *header = @{@"Referer":h5url};
        NSDictionary *optiosDic = @{@"AVURLAssetHTTPHeaderFieldsKey" : header};
        [playerManager setRequestHeader:optiosDic];
        
        _videoPlayer =[ZFPlayerController playerWithPlayerManager:playerManager containerView:self];
        _videoPlayer.shouldAutoPlay = YES;
        _videoPlayer.allowOrentitaionRotation = NO;
        _videoPlayer.WWANAutoPlay = YES;


        //不支持的方向
        _videoPlayer.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionVertical;
        //不支持的手势类型
        _videoPlayer.disableGestureTypes =  ZFPlayerDisableGestureTypesPinch;
        /// 1.0是消失100%时候
        _videoPlayer.playerDisapperaPercent = 1.0;
        //功能
        @weakify(self)
        _videoPlayer.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
            NSLog(@"准备");
            @strongify(self)
            
        };
        _videoPlayer.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
            @strongify(self)
        };
        _videoPlayer.playerDidToEnd = ^(id  _Nonnull asset) {
            NSLog(@"结束");
            @strongify(self)
            [self.videoPlayer.currentPlayerManager replay];
        };

    }
    return _videoPlayer;
}
-(void)playWithVideoPlayer{
    NSString *playUrl = [self.playDoc valueForKey:@"pull"];
    self.videoPlayer.assetURL = [NSURL URLWithString:playUrl];
}

-(void)txPlayer {
    if ([minstr([self.playDoc valueForKey:@"isvideo"]) isEqual:@"1"]) {
        [self playWithVideoPlayer];
    }else{
        [self.txLivePlayer setRenderView:self];
        NSString *playUrl = [self.playDoc valueForKey:@"pull"];
        [_txLivePlayer startLivePlay:playUrl];
    }
//    _config = [[TXLivePlayConfig alloc] init];
//    _config.headers = @{@"referer":h5url};
//    //_config.enableAEC = YES;
//    //自动模式
//    _config.bAutoAdjustCacheTime   = YES;
//    _config.minAutoAdjustCacheTime = 1;
//    _config.maxAutoAdjustCacheTime = 5;
//    _txLivePlayer =[[TXLivePlayer alloc] init];
//    if (ios8) {
//        _txLivePlayer.enableHWAcceleration = false;
//
//    }else{
//        _txLivePlayer.enableHWAcceleration = YES;
//    }
//    [_txLivePlayer setupVideoWidget:self.bounds containView:self insertIndex:0];
//    [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
//    [_txLivePlayer setConfig:_config];
//    [_txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
//
//    //isvideo 是不是视频
//    if ([minstr([self.playDoc valueForKey:@"isvideo"]) isEqual:@"1"]) {
//        [_txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
//    }
//    if(_txLivePlayer != nil)
//    {
//        _txLivePlayer.delegate = self;
//        NSString *playUrl = [self.playDoc valueForKey:@"pull"];
//        NSInteger _playType = 0;
//        if ([playUrl hasPrefix:@"rtmp:"]) {
//            _playType = PLAY_TYPE_LIVE_RTMP;
//        } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".flv"].length > 0) {
//            _playType = PLAY_TYPE_LIVE_FLV;
//        }
//        else{}
//        if ([playUrl rangeOfString:@".mp4"].length > 0) {
//            _playType = PLAY_TYPE_VOD_MP4;
//        }
//        if ([playUrl rangeOfString:@".m3u8"].length > 0) {
//            _playType = PLAY_TYPE_VOD_FLV;
//        }
//
//        int result = [_txLivePlayer startLivePlay:playUrl type:_playType];
//        NSLog(@"wangminxin%d",result);
//        if (result == -1){}
//        if( result != 0)
//        {
////            [_notification displayNotificationWithMessage:@"视频流播放失败" forDuration:5];
//        }
//        if( result == 0){
//            NSLog(@"播放视频");
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            });
//        }
//        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//    }
}

-(void)returnBtnClick{
    if (self.btnEvent) {
        self.btnEvent(@"hide");
    }
}
- (void)onStopVideo{
    
    //tx
    if(_txLivePlayer != nil) {
//        _txLivePlayer.delegate = nil;
        [_txLivePlayer stopPlay];
//        [_txLivePlayer removeVideoWidget];
    }
}

-(void)setFousBtnHide:(BOOL)ishide{
    self.focusBtn.hidden = ishide;
}
-(void)guanzhuzhubo{
    NSDictionary *subdic = @{
                             @"touid":[self.playDoc valueForKey:@"uid"]
                             };
    [YBToolClass postNetworkWithUrl:@"User.setAttent" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self setFousBtnHide:YES];
            if (self.btnEvent) {
                self.btnEvent(@"focus");
            }
        }
    } fail:^{
        
    }];

}

//播放监听事件
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param {
//    NSLog(@"eventID:%d===%@",EvtID,param);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"moviplay不连麦已经连接服务器");
        }
        else if (EvtID == PLAY_EVT_RTMP_STREAM_BEGIN){
            NSLog(@"moviplay不连麦已经连接服务器，开始拉流");
        }
        else if (EvtID == PLAY_EVT_PLAY_BEGIN){
            NSLog(@"moviplay不连麦视频播放开始");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            });
        }
        else if (EvtID== PLAY_WARNING_VIDEO_PLAY_LAG){
            NSLog(@"moviplay不连麦当前视频播放出现卡顿（用户直观感受）");
        }
        else if (EvtID == PLAY_EVT_PLAY_END){
            NSLog(@"moviplay不连麦视频播放结束");
//            [_txLivePlayer resume];
            [_txLivePlayer resumeAudio];
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT) {
            //视频播放结束
            NSLog(@"moviplay不连麦网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放");
        }else if (EvtID == PLAY_EVT_CHANGE_RESOLUTION) {
            NSLog(@"主播连麦分辨率改变");
        }
    });
}
-(void)onNetStatus:(NSDictionary *)param{
    
    
}
-(V2TXLivePlayer *)txLivePlayer{
    if(!_txLivePlayer){
        _txLivePlayer = [[V2TXLivePlayer alloc] init];
        [_txLivePlayer setObserver:self];
        [_txLivePlayer enableObserveAudioFrame:YES];
        [_txLivePlayer setRenderFillMode:V2TXLiveFillModeFill];
    }
    return _txLivePlayer;
}

@end
