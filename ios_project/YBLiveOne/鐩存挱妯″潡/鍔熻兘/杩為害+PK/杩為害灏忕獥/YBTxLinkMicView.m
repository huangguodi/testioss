//
//  YBTxLinkMicView.m
//  YBVideo
//
//  Created by YB007 on 2020/10/15.
//  Copyright © 2020 cat. All rights reserved.
//

#import "YBTxLinkMicView.h"

//#import <TXLiteAVSDK_Professional/TXLivePlayListener.h>
//#import <TXLiteAVSDK_Professional/TXLivePlayConfig.h>
//#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
//#import <TXLiteAVSDK_Professional/TXLivePush.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "V8HorizontalPickerView.h"
#import <TXLiteAVSDK_Professional/V2TXLivePlayer.h>
#import "YBLiveRTCManager.h"

@interface YBTxLinkMicView()<V2TXLivePusherObserver,V2TXLivePlayerObserver>{
    int _linkCount;
    BOOL _viewDismiss;
}

@property(nonatomic,strong)CWStatusBarNotification *notification;

@property(nonatomic,strong)UIView *linkSuperView;
@property(nonatomic,strong)UIView *linkPreView;
@property(nonatomic,strong)UIImageView *loadingIV;
@property(nonatomic,strong)UIButton *closeBtn;

@property(nonatomic,strong)V2TXLiveVideoEncoderParam *txLiveVieoParam;
@property(nonatomic,strong)V2TXLivePusher *txLivePusher;
@property(nonatomic,strong)TXAudioEffectManager *audioEffect;
@property(nonatomic, strong)V2TXLivePlayer *txLivePlayer;

@property(nonatomic,strong)NSString *playUrl;
@property(nonatomic,strong)NSString *pushUrl;

@property(nonatomic,assign)BOOL isHostToHost;
@end

@implementation YBTxLinkMicView

+(instancetype)createLinkMicViewOnSuper:(UIView*)superView andHostToHost:(BOOL)isHostToHost;{
    YBTxLinkMicView *linkView = [[YBTxLinkMicView alloc]init];
    linkView.linkSuperView = superView;
    linkView.isHostToHost = isHostToHost;
    [superView addSubview:linkView];
    [superView sendSubviewToBack:linkView];
    /*
    [linkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superView.mas_right);
        if (isHostToHost) {
            make.top.equalTo(superView.mas_top).offset(130+statusbarHeight);
            make.width.mas_equalTo(_window_width/2);
            make.height.mas_equalTo(_window_width*2/3);
        }else {
            make.bottom.equalTo(superView.mas_bottom).offset(-120-ShowDiff);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(150);
        }
    }];
    */
    if (isHostToHost) {
        linkView.frame = CGRectMake(_window_width/2, 130+statusbarHeight, _window_width/2, _window_width*2/3);
    }else {
        linkView.frame = CGRectMake(_window_width-100, _window_height-(150+120+ShowDiff), 100, 150);
    }
    
    [linkView setUpView];
    return linkView;
}
/** 键盘弹起事件: 目前只处理 PK和连麦 的界面相对位置不变*/
-(void)keyBoardNoticeIsShow:(BOOL)isShow andHeight:(CGFloat)height;{
    
    if (_isHostToHost) {
        self.top = 130+statusbarHeight+height;
    }else {
        self.top = _window_height-(150+120+ShowDiff)+height;
    }
    
    /*
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_linkSuperView.mas_right);
        if (_isHostToHost) {
            make.top.equalTo(_linkSuperView.mas_top).offset(130+statusbarHeight+height);
            make.width.mas_equalTo(_window_width/2);
            make.height.mas_equalTo(_window_width*2/3);
        }else {
            make.bottom.equalTo(_linkSuperView.mas_bottom).offset(-120-ShowDiff+height);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(150);
        }
    }];
    */
}
-(void)setUpView {
    _notification = [CWStatusBarNotification new];
    _notification.notificationLabelBackgroundColor = [UIColor redColor];
    _notification.notificationLabelTextColor = [UIColor whiteColor];
    
    _linkPreView = [[UIView alloc]init];
    [self addSubview:_linkPreView];
    [_linkPreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerX.centerY.equalTo(self);
    }];
    
    _loadingIV = [[UIImageView alloc]init];
    _loadingIV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_loadingIV];
    [_loadingIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerX.centerY.equalTo(self);
    }];
    NSMutableArray *m_array = [NSMutableArray array];
    for (int i = 0; i < 14; i++) {
        [m_array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_image%d.png",i]]];
    }
    _loadingIV.animationImages = [NSArray arrayWithArray:m_array];
    _loadingIV.animationDuration= [m_array count]*0.1;
    _loadingIV.animationRepeatCount = MAXFLOAT;
    
    
    UIButton *shadowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    shadowBtn.backgroundColor = RGBA(0, 0, 0, 0.5);
    [shadowBtn addTarget:self action:@selector(clickLinkShadow) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shadowBtn];
    [shadowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerX.centerY.equalTo(self);
    }];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"连麦-关闭"] forState:0];
    [_closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    _closeBtn.hidden = YES;
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.top.equalTo(self.mas_top).offset(3);
        make.right.equalTo(self.mas_right).offset(-3);
    }];
}
-(void)clickLinkShadow {
    // 预留-
    if (self.linkMicEvent && _isHostToHost == NO) {
        self.linkMicEvent(TxLinkEventType_ShadowClick, _linkDic);
    }
}
- (void)setLinkDic:(NSDictionary *)linkDic {
    _linkDic = linkDic;
    _playUrl = minstr([linkDic valueForKey:@"playurl"]);
    _pushUrl = minstr([linkDic valueForKey:@"pushurl"]);
}

-(void)linkMicShowViewHaveCloseBtn:(BOOL)haveCloseBtn {
    [self addNoti];
    _closeBtn.hidden = !haveCloseBtn;
    [_loadingIV startAnimating];
    
    if ([_linkDic allKeys].count<=0) {
        return;
    }
    _viewDismiss = NO;
    if ([_pushUrl isEqual:@"0"]) {
        [self txRtmpPlay];
    }else {
        [self txRtmpPush];
    }
}
-(void)addNoti {
    NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
    [noti addObserver:self selector:@selector(appactive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [noti addObserver:self selector:@selector(appnoactive) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)appactive {
//    if (_txLivePush) {
//        [_txLivePush resumePush];
//    }
    [_txLivePusher resumeVideo];

}

-(void)appnoactive {
    [_txLivePusher pauseVideo];
}

-(void)removeNoti {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)destroyLoadingIV {
    if (_loadingIV) {
        [_loadingIV stopAnimating];
        [_loadingIV removeFromSuperview];
        _loadingIV = nil;
    }
}
-(void)clickCloseBtn {
    
    self.linkMicEvent(TxLinkEventType_LinkDisconnect, _linkDic);
    
    [self linkMicViewDismiss];
}

-(void)linkMicViewDismiss{
    [self removeNoti];
    [self destroyLoadingIV];
    _viewDismiss = YES;
    
    if (_txLivePlayer) {
        [_txLivePlayer stopPlay];
        _txLivePlayer = nil;
    }
    if (_txLivePusher) {
        [_txLivePusher stopPush];
        _txLivePusher = nil;
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}
#pragma mark - 推流
-(void)txRtmpPush {
    //配置推流参数
    _txLiveVieoParam = [[V2TXLiveVideoEncoderParam alloc]init];
    _txLiveVieoParam.videoResolution =V2TXLiveVideoResolution1280x720;
    
    _txLivePusher = [[V2TXLivePusher alloc]initWithLiveMode:V2TXLiveMode_RTC];
    [_txLivePusher setVideoQuality:_txLiveVieoParam];
    [_txLivePusher startCamera:YES];
    [_txLivePusher startMicrophone];
    [_txLivePusher setRenderView:_linkPreView];
    [_txLivePusher startPush:_pushUrl];
    [_txLivePusher setObserver:self];
    [_txLivePusher setEncoderMirror:YES];
    
    TXBeautyManager *beautyManager = [_txLivePusher getBeautyManager];
    [beautyManager setBeautyStyle:0];
    [beautyManager setBeautyLevel:9];
    [beautyManager setWhitenessLevel:3];
    [beautyManager setRuddyLevel:0];
}
#pragma mark  --RTC推流回调
/**
 * 推流器连接状态回调通知
 *
 * @param status    推流器连接状态 {@link V2TXLivePushStatus}。
 * @param msg       连接状态信息。
 * @param extraInfo 扩展信息。
 */
- (void)onPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == V2TXLivePushStatusDisconnected) {
            /// 与服务器断开连接
            NSLog(@"movieplay连麦推流 推流失败，结束连麦");
            [_notification displayNotificationWithMessage:YZMsg(@"推流失败，结束连麦") forDuration:5];
            if (self.linkMicEvent) {
                self.linkMicEvent(TxLinkEventType_StopPush, @{});
            }

        }else if(status == V2TXLivePushStatusConnecting){
            /// 正在连接服务器

        }else if(status == V2TXLivePushStatusConnectSuccess){
            /// 连接服务器成功
            NSLog(@"play_linkmic连麦推流已经与服务器握手完毕,开始推流");
            if (self.linkMicEvent) {
                self.linkMicEvent(TxLinkEventType_StartPush, @{});
            }
            [self destroyLoadingIV];

        }else if(status == V2TXLivePushStatusConnectSuccess){
            ///  重连服务器中
            [_notification displayNotificationWithMessage:@"网络断连, 已启动自动重连" forDuration:5];
        }
    });
}

/**
 * 推流器连接状态回调通知
 *
 * @param status    推流器连接状态 {@link V2TXLivePushStatus}。
 * @param msg       连接状态信息。
 * @param extraInfo 扩展信息。
 */
-(void)ybRTCPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == V2TXLivePushStatusDisconnected) {
            /// 与服务器断开连接
            NSLog(@"movieplay连麦推流 推流失败，结束连麦");
            [_notification displayNotificationWithMessage:YZMsg(@"推流失败，结束连麦") forDuration:5];
            if (self.linkMicEvent) {
                self.linkMicEvent(TxLinkEventType_StopPush, @{});
            }

        }else if(status == V2TXLivePushStatusConnecting){
            /// 正在连接服务器

        }else if(status == V2TXLivePushStatusConnectSuccess){
            /// 连接服务器成功
            NSLog(@"play_linkmic连麦推流已经与服务器握手完毕,开始推流");
            if (self.linkMicEvent) {
                self.linkMicEvent(TxLinkEventType_StartPush, @{});
            }
            [self destroyLoadingIV];
        }
    });
}
-(void)ybPushLiveStatus:(V2TXLiveCode)pushStatus
{
    if (pushStatus == V2TXLIVE_OK) {
        NSLog(@"LIVEBROADCAST --:推流成功、停止推流");
    }else if (pushStatus == V2TXLIVE_ERROR_INVALID_PARAMETER){
        [_notification displayNotificationWithMessage:@"操作失败，url 不合法" forDuration:5];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_ERROR_INVALID_LICENSE){
        [_notification displayNotificationWithMessage:@"操作失败，license 不合法，鉴权失败" forDuration:5];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_ERROR_REFUSED){
        [_notification displayNotificationWithMessage:@"操作失败，RTC 不支持同一设备上同时推拉同一个 StreamId" forDuration:5];
        NSLog(@"推流器启动失败");
    }else if (pushStatus == V2TXLIVE_WARNING_NETWORK_BUSY){
        [_notification displayNotificationWithMessage:YZMsg(@"您当前的网络环境不佳，请尽快更换网络保证正常连麦") forDuration:5];
    }
}
#pragma mark - 播流
-(void)txRtmpPlay {
    
    [self.txLivePlayer setRenderView:self];
    V2TXLiveCode result = [self.txLivePlayer startLivePlay:_playUrl];
    NSLog(@"wangminxin%ld",result);
    if( result == 0){
        NSLog(@"播放视频");
//        [loadingImage removeFromSuperview];
//        loadingImage = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

#pragma mark  -播放监听事件 liveplayObserver
- (void)onError:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    NSLog(@"liveplay-error");
    [self clickCloseBtn];

}
- (void)onWarning:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo;
{
    NSLog(@"liveplay-onWarning");
}
/**
 * 已经成功连接到服务器
 *
 * @param player    回调该通知的播放器对象。
 * @param extraInfo 扩展信息。
 */

- (void)onVideoPlaying:(id<V2TXLivePlayer>)player firstPlay:(BOOL)firstPlay extraInfo:(NSDictionary *)extraInfo;
{
    [self destroyLoadingIV];
}
-(void)linkMicMixStream:(NSDictionary *)mixStreamDic andHostToHost:(BOOL)isHostToHost{
    self.isHostToHost = isHostToHost;
    
    NSString *selfUrl = minstr([mixStreamDic valueForKey:@"selfUrl"]);
    NSString *otherUrl = minstr([mixStreamDic valueForKey:@"otherUrl"]);
    
    NSString * mainStreamId = [self getStreamIDByStreamUrl:selfUrl];
    NSString *subStreamId = [self getStreamIDByStreamUrl:otherUrl];
  
    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth =  540;
    config.videoHeight = 960;
    config.videoBitrate = 0;
    config.videoFramerate  = 20;

    V2TXLiveMixStream *mainStream = [[V2TXLiveMixStream alloc] init];
    V2TXLiveMixStream *subStream = [[V2TXLiveMixStream alloc] init];

    if (![YBToolClass checkNull:otherUrl]) {
        if (isHostToHost) {
            config.videoWidth = _window_width;
            config.videoHeight = _window_width*2/3;

            mainStream.streamId = nil;
            mainStream.userId = [Config getOwnID];
            mainStream.x = 0;
            mainStream.y = 0;
            mainStream.height = _window_width*2/3;
            mainStream.width = _window_width/2;
            mainStream.zOrder   = 0;
            mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;

            subStream.streamId = subStreamId;
            subStream.userId = minstr([_linkDic valueForKey:@"userid"]);
            subStream.height = _window_width*2/3;
            subStream.width = _window_width/2;
            subStream.x = _window_width/2;//rr
            subStream.y = 0;
            subStream.zOrder = 1;
            subStream.inputType = V2TXLiveMixInputTypeAudioVideo;
        }else{
            mainStream.streamId = nil;
            mainStream.userId = [Config getOwnID];
            mainStream.height = 960;//rrrr
            mainStream.width = 540;//rrrr
            mainStream.x = 0;
            mainStream.y = 0;
            mainStream.zOrder = 1;
            mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;
            
            subStream.streamId = subStreamId;
            subStream.userId = minstr([_linkDic valueForKey:@"userid"]);
            subStream.height =  240;
            subStream.width = 135;
            subStream.x = 390;
            subStream.y =576;
            subStream.zOrder = 2;
            subStream.inputType = V2TXLiveMixInputTypeAudioVideo;

        }
        config.mixStreams = @[mainStream,subStream];
        [[YBLiveRTCManager shareInstance]MixTranscoding:config];
    }else{
        //断开连麦取消云端混流
        [[YBLiveRTCManager shareInstance]MixTranscoding:nil];
    }

    
//    NSMutableArray * inputStreamList = [NSMutableArray new];
//
//    /**
//     *  大背景
//     *  主播与主播连麦 背景设置为画布(input_type = 3)
//     *  用户-主播连麦大主播fram 或者 主播-主播连麦的背景画布 的fram
//     */
//    CGFloat big_bg_x = 0;
//    CGFloat big_bg_y = 0;
//    CGFloat big_bg_w = _window_width;
//    CGFloat big_bg_h = _window_height;
//
//    /**
//     *  视频流
//     *  用户-主播连麦连麦用户fram 或者 主播-主播连麦的右边主播fram
//     */
//    CGFloat small_x = 0.75;//_window_width-100;
//    CGFloat small_y = 0.6;//_window_height - 110 -statusbarHeight - 150 -ShowDiff;
//    CGFloat small_w = 0.25;//100;
//    CGFloat small_h = 0.21;//150;
//
//    /**
//     *  视频流
//     *  仅用于主播与主播连麦，主播-主播左边主播fram
//     */
//    CGFloat host_own_x = 0;
//    CGFloat host_own_y = 0.25;//0
//    CGFloat host_own_w = 0.5;//_window_width/2;
//    CGFloat host_own_h = 0.5;//_window_width*2/3;
//
//    NSString * _mainStreamId = [self getStreamIDByStreamUrl:selfUrl];
//    NSString *host_own_stram_id = _mainStreamId;
//    NSInteger inputType = 0;
//    if (isHostToHost && ![PublicObj checkNull:otherUrl]) {
//        host_own_stram_id = @"canvas1";
//        inputType = 3;
//        //        big_bg_x = 0;
//        //        big_bg_y = 130+statusbarHeight;
//        //        big_bg_w = host_own_w*2;
//        //        big_bg_h = host_own_h;
//
//        small_x = 0.5;//_window_width/2;
//        small_y = 0.25;//host_own_y;
//        small_w = 0.5;//host_own_w;
//        small_h = 0.5;//host_own_h;
//    }
//
//    //大主播
//    NSDictionary * mainStream = @{
//        @"InputStreamName": host_own_stram_id,
//        @"LayoutParams": @{
//                @"ImageLayer": [NSNumber numberWithInt:1],
//                @"ImageWidth": [NSNumber numberWithFloat: big_bg_w],
//                @"ImageHeight": [NSNumber numberWithFloat: big_bg_h],
//                @"LocationX": [NSNumber numberWithFloat:big_bg_x],
//                @"LocationY": [NSNumber numberWithFloat:big_bg_y],
//                @"InputType": @(inputType),
//        },
//    };
//    [inputStreamList addObject:mainStream];
//
//    if (![PublicObj checkNull:otherUrl]) {
//        if (isHostToHost) {
//            //pk主播(左边边主播)
//            NSDictionary * mainStreamss = @{
//                @"InputStreamName": _mainStreamId,
//                @"LayoutParams": @{
//                        @"ImageLayer": [NSNumber numberWithInt:3],
//                        @"ImageWidth": [NSNumber numberWithFloat: host_own_w],
//                        @"ImageHeight": [NSNumber numberWithFloat: host_own_h],
//                        @"LocationX": [NSNumber numberWithFloat:host_own_x],
//                        @"LocationY": [NSNumber numberWithFloat:host_own_y]
//                },
//            };
//            [inputStreamList addObject:mainStreamss];
//        }
//        //小主播(用户:右下角) 或者 pk主播(右边主播)
//        NSString *subPath = [self getStreamIDByStreamUrl:otherUrl];
//        NSDictionary * subStream = @{
//            @"InputStreamName": subPath,
//            @"LayoutParams": @{
//                    @"ImageLayer": [NSNumber numberWithInt:2],
//                    @"ImageWidth": [NSNumber numberWithFloat: small_w],
//                    @"ImageHeight": [NSNumber numberWithFloat: small_h],
//                    @"LocationX": [NSNumber numberWithFloat:small_x],
//                    @"LocationY": [NSNumber numberWithFloat:small_y],
//            },
//        };
//        [inputStreamList addObject:subStream];
//    }
//
//    //para
//    NSDictionary * mergeParams = @{
//        @"MixStreamSessionId": _mainStreamId,
//        @"OutputParams": @{@"OutputStreamName":_mainStreamId},
//        @"InputStreamList": inputStreamList
//    };
//    NSString *jsonStr = [self pictureArrayToJSON:mergeParams];
//
//    NSString *linkUrl = @"Linkmic.MergeVideoStream";
//    NSDictionary *mergeInfo = @{
//                                @"uid":[Config getOwnID],
//                                @"mergeparams":jsonStr
//                              };
//    NSLog(@"=====json:%@",mergeInfo);
//    [self requestLink:mergeInfo andUrl:linkUrl];
}
- (NSString *)pictureArrayToJSON:(NSDictionary *)picArr {
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:picArr options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSLog(@"jsonStr==%@",jsonStr);
    return jsonStr;
}
-(void)requestLink:(NSDictionary *)dicInfo andUrl:(NSString *)urlStr{
    WeakSelf;
    if (_viewDismiss) {
        return;
    }
    [YBToolClass postNetworkWithUrl:urlStr andParameter:dicInfo success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        NSLog(@"混流====:%@",info);
        if (code != 0 ) {
            if (_linkCount > 5) {
                return;
            }else{
                _linkCount ++;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf requestLink:dicInfo andUrl:urlStr];
                });
            }
        }
    } fail:^{
        
    }];
    
}
-(NSString*) getStreamIDByStreamUrl:(NSString*) strStreamUrl {
    if (strStreamUrl == nil || strStreamUrl.length == 0) {
        return nil;
    }
    strStreamUrl = [strStreamUrl lowercaseString];
    //推流地址格式：rtmp://8888.livepush.myqcloud.com/live/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
    NSString * strLive = @"/play/";
    NSRange range = [strStreamUrl rangeOfString:strLive];
    if (range.location == NSNotFound) {
        return nil;
    }
    NSString * strSubString = [strStreamUrl substringFromIndex:range.location + range.length];
    NSArray * array = [strSubString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?."]];
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    return @"";
}

//主播-用户连麦上报信息
-(void)linkMicUploadInfo:(NSDictionary *)uploadDic; {
    [YBToolClass postNetworkWithUrl:@"Zlive.showVideo" andParameter:uploadDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        NSLog(@"Live.showVideo:%@",info);
    } fail:^{
        
    }];
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


#pragma mark - 扬声器操作
-(void)speakerCtr:(BOOL)mute; {
    if(mute){
        [_txLivePlayer setPlayoutVolume:0];
    }else {
        [_txLivePlayer setPlayoutVolume:100];
    }
}
#pragma mark - 麦克风操作
-(void)audioCtr:(BOOL)mute; {
    if(mute){
        [_txLivePusher pauseAudio];
    }else {
        [_txLivePusher resumeAudio];
    }
}
@end
