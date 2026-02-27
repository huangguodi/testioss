//
//  YBLookVideoVC.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "YBLookVideoVC.h"
#import "YBVideoControlView.h"
#import "YBLookVideoCell.h"
#import "videoModel.h"
#import "liwuview.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "RechargeViewController.h"
#import "personSelectActionView.h"
#import "TChatController.h"
#import "TConversationCell.h"
//#import "TIMComm.h"
//#import "TIMManager.h"
//#import "TIMMessage.h"
//#import "TIMConversation.h"
#import "InvitationViewController.h"
#import "YBAlertView.h"
#import "VIPViewController.h"
#import "jubaoVC.h"
#import "commentview.h"

static NSString * const reuseIdentifier = @"collectionViewCell";

@interface YBLookVideoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,sendGiftDelegate,haohuadelegate,lookVideoCallDelegate>
{
    int _lastPlayCellIndex;
    NSIndexPath *_lastPlayIndexPath;
    NSDictionary *_currentVideoDic;
    liwuview *giftView;
    UIButton *giftZheZhao;
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    UIView *liansongliwubottomview;
    personSelectActionView *actionView;
    NSDictionary *_userDic;
    YBAlertView *alert;
    BOOL _isLoadingMore;                //列表是否正在加载总

}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) YBVideoControlView *controlView;
@property (nonatomic, strong) NSMutableArray *videoUrls;
@property(nonatomic,strong)YBLookVideoCell *playingCell;
@property(nonatomic,strong)UIButton *goBackBtn;
@property(nonatomic,strong)UIButton *goBackShadow;
@property(nonatomic,strong)NSString *hostID;
@property(nonatomic,strong)commentview *comment;                     //评论

@end

@implementation YBLookVideoVC
-(void)initData{
    self.videoUrls = [NSMutableArray array];
    _isLoadingMore = NO;
    _hostID = @"";
    for (NSDictionary *subDic in _videoList) {
        NSString *videoUrl = minstr([subDic valueForKey:@"href"]);
        NSLog(@"curr---------:%@", videoUrl);
        [_videoUrls addObject:[NSURL URLWithString:videoUrl]];
    }

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_controlView pauseVideo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_controlView.playBtn.hidden == NO) {
        return;
    }
    [self startPlayerVideo];

}
-(void)startPlayerVideo {
    @weakify(self)
    [self.collectionView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self.view addSubview:self.collectionView];

    [self setContentView];

    liansongliwubottomview = [[UIView alloc]init];
    [self.view addSubview:liansongliwubottomview];
    liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);

}
#pragma mark - set/get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = self.view.frame.size.width;
        CGFloat itemHeight = self.view.frame.size.height;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        if (self.scrollViewDirection == ZFPlayerScrollViewDirectionVertical) {
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        } else if (self.scrollViewDirection == ZFPlayerScrollViewDirectionHorizontal) {
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor blackColor];
        /// 横向滚动 这行代码必须写
        _collectionView.zf_scrollViewDirection = self.scrollViewDirection;
        [_collectionView registerClass:[YBLookVideoCell class] forCellWithReuseIdentifier:reuseIdentifier];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        /// 停止的时候找出最合适的播放
        @weakify(self)
        _collectionView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            [self startPlayerVideo];
        };
    }
    return _collectionView;
}
#pragma mark - private method
-(void)pullData{
    if (_isLoadingMore || [YBToolClass checkNull:minstr(_sourceBaseUrl)]) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@&p=%@",_sourceBaseUrl,@(_pages)];
    WeakSelf;
    _isLoadingMore = YES;

    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code,id info,NSString *msg) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            _isLoadingMore = NO;

        });

        if (code == 0) {
            NSArray *infos = info;
            NSArray *infoA = [NSArray arrayWithArray:infos];
            if (_pages==1) {
                [_videoList removeAllObjects];
            }
            [_videoList addObjectsFromArray:infoA];
            if (_videoList.count<=0) {
                [MBProgressHUD showError:YZMsg(@"暂无更多视频哦~")];
            }
        
            [_videoUrls removeAllObjects];
            for (NSDictionary *subDic in _videoList) {
                NSString *videoUrl = minstr([subDic valueForKey:@"href"]);
                [_videoUrls addObject:[NSURL URLWithString:videoUrl]];
            }
            weakSelf.player.assetURLs = _videoUrls;
            [weakSelf.collectionView reloadData];
            //准备播放
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf startPlayerVideo];
            });

        }else{
            [MBProgressHUD showError:msg];
        }
        
    } fail:^{
        [MBProgressHUD hideHUD];

        _isLoadingMore = NO;

    }];

}

- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}

- (void)doVIP{
    VIPViewController *vip = [[VIPViewController alloc]init];
    vip.vipBlock = ^{
        NSMutableDictionary *oldDic = [NSMutableDictionary dictionaryWithDictionary:_currentVideoDic];
        NSDictionary *newDic = @{@"cansee":@"1"};
        [oldDic addEntriesFromDictionary:newDic];
        _currentVideoDic = [NSDictionary dictionaryWithDictionary:oldDic];
        [_videoList replaceObjectAtIndex:_lastPlayIndexPath.row withObject:_currentVideoDic];

    };
    [[YBAppDelegate sharedAppDelegate] pushViewController:vip animated:YES];
}
-(void)doRecharge{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:recharge animated:YES];

}

-(void)setContentView{
    /*
    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
    NSString *ijkRef = [NSString stringWithFormat:@"Referer:%@\r\n",h5url];
    [playerManager.options setFormatOptionValue:ijkRef forKey:@"headers"];
    */
    ZFAVPlayerManager*playerManager = [[ZFAVPlayerManager alloc] init];
    NSDictionary *header = @{@"Referer":h5url};
    NSDictionary *optiosDic = @{@"AVURLAssetHTTPHeaderFieldsKey" : header};
    [playerManager setRequestHeader:optiosDic];
    
    // player的tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.collectionView playerManager:playerManager containerViewTag:191107];
    self.player.controlView = self.controlView;
    self.player.assetURLs = self.videoUrls;
    self.player.shouldAutoPlay = YES;
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    //不支持的方向
    self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionVertical;
    //不支持的手势类型
    self.player.disableGestureTypes =  ZFPlayerDisableGestureTypesPinch;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 1.0;
    
    @weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self setNeedsStatusBarAppearanceUpdate];
        self.collectionView.scrollsToTop = !isFullScreen;
    };
    self.player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
        @strongify(self)
        if (size.width >= size.height) {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
        } else {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        }
    };
    //功能
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"准备");
        @strongify(self)
        self.playingCell.backImgV.image = nil;

    };
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSDictionary *videoDic = _currentVideoDic;
//        if ([minstr([videoDic valueForKey:@"isprivate"]) isEqual:@"1"] && ![_hostID isEqual:[Config getOwnID]]) {
        if ([minstr([videoDic valueForKey:@"cansee"]) isEqual:@"0"]) {

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.controlView pauseVideo];
            });

            if([[YBYoungManager shareInstance] isOpenYoung]){
                
                UIAlertController *showAlert = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"青少年模式下，不能观看付费视频") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:YZMsg(@"去关闭") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Center];

                }];
                [cancelAction setValue:UIColor.grayColor forKey:@"_titleTextColor"];
                [closeAction setValue:normalColors_live forKey:@"_titleTextColor"];
                [showAlert addAction:cancelAction];
                [showAlert addAction:closeAction];
                [[[YBAppDelegate sharedAppDelegate] topViewController] presentViewController:showAlert animated:YES completion:nil];
            }else{
                NSString *msgTitle = [NSString stringWithFormat:YZMsg(@"该视频为私密视频，需支付%@%@观看\n开通VIP后可免费观看"),minstr([videoDic valueForKey:@"coin"]),[common name_coin]];
                WeakSelf;
                alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:msgTitle andButtonArrays:@[YZMsg(@"开通会员"),YZMsg(@"付费观看")] andButtonClick:^(int type) {
                    if (type == 2) {
                        NSString *url  = [NSString stringWithFormat:@"Video.BuyVideo&videoid=%@",minstr([videoDic valueForKey:@"id"])];
                        [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                            if (code == 0) {
                                
                                NSMutableDictionary *oldDic = [NSMutableDictionary dictionaryWithDictionary:_currentVideoDic];
                                NSDictionary *newDic = @{@"cansee":@"1"};
                                [oldDic addEntriesFromDictionary:newDic];
                                _currentVideoDic = [NSDictionary dictionaryWithDictionary:oldDic];
                                [_videoList replaceObjectAtIndex:_lastPlayIndexPath.row withObject:_currentVideoDic];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADHOMEVIDEOLIST" object:nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADVIDEOLIST" object:nil];
                                [self startPlayerVideo];
                            }else if (code == 1005){
                                [weakSelf doRecharge];
                            }
                            [MBProgressHUD showError:msg];
                        } fail:^{
                        }];
                    }else if (type == 1) {
                        [weakSelf doVIP];
                    }
                    [weakSelf removeAlertView];
                    weakSelf.controlView.playBtn.hidden = NO;
                }];
                [weakSelf.view addSubview:alert];
            }
        }else{
            self.controlView.playBtn.hidden = YES;

            if (self.player.playingIndexPath) return;
            if (_lastPlayCellIndex + 1 >= _videoList.count) {
                /// 加载下一页数据
                _pages += 1;
                [MBProgressHUD showMessage:@""];
                [self pullData];
            }else {
//                [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
            }
        }

    };
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        NSLog(@"结束");
        @strongify(self)
        [self.player.currentPlayerManager replay];
    };
    self.player.zf_playerDisappearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerDisapperaPercent) {
        @strongify(self);
        //这里代表将要切换视频
        if (playerDisapperaPercent == 1) {
            NSLog(@"100%%消失:%f",self.player.currentTime);
        }
    };
    [self.player stopCurrentPlayingCell];

    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_pushPlayIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self.view addSubview:self.goBackBtn];

}
#pragma mark - set/get
- (UIButton *)goBackBtn{
    if (!_goBackBtn) {
        //左
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackBtn.frame = CGRectMake(10, 22+statusbarHeight, 40, 40);
        _goBackBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_goBackBtn setImage:[UIImage imageNamed:@"video--返回"] forState:0];
        [_goBackBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        
        //左shadow
        _goBackShadow = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackShadow.frame = CGRectMake(0, 0, 64, 64+statusbarHeight);
        [_goBackShadow addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        _goBackShadow.backgroundColor = [UIColor clearColor];
    }
    return _goBackBtn;
}
#pragma mark - 点击事件
-(void)clickLeftBtn {
    [self.player stopCurrentPlayingCell];
    [self.navigationController popViewControllerAnimated:YES];
}

- (YBLookVideoCell *)playingCell {
    _playingCell = (YBLookVideoCell*)[_collectionView cellForItemAtIndexPath:self.player.playingIndexPath];
    return _playingCell;
}

#pragma mark - 播放
/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    _lastPlayCellIndex = (int)indexPath.row;
    _lastPlayIndexPath = indexPath;
    _currentVideoDic = _videoList[indexPath.row];
////    _videoID = minstr([_currentVideoDic valueForKey:@"id"]);
    NSDictionary *userInfo = [_currentVideoDic valueForKey:@"userinfo"];
    _hostID = minstr([userInfo valueForKey:@"id"]);
    
    [self.player playTheIndexPath:indexPath scrollToTop:scrollToTop];
    [self.controlView showCoverViewWithUrl:minstr([_currentVideoDic valueForKey:@"thumb"]) withImageMode:UIViewContentModeScaleAspectFit];
    

}
- (YBVideoControlView *)controlView {
    if (!_controlView) {
        _controlView = [YBVideoControlView new];
        @weakify(self);
        _controlView.ybContorEvent = ^(NSString *eventStr, ZFPlayerGestureControl *gesControl) {
            @strongify(self);
            [self contorEvent:eventStr andGes:gesControl];
        };
    }
    return _controlView;
}
-(void)contorEvent:(NSString *)eventStr andGes:(ZFPlayerGestureControl*)gesControl{
    if ([eventStr isEqual:@"控制-单击"]) {
        
//        if ([minstr([_currentVideoDic valueForKey:@"isprivate"]) isEqual:@"1"]&&![_hostID isEqual:[Config getOwnID]]) {
        if ([minstr([_currentVideoDic valueForKey:@"cansee"]) isEqual:@"0"]) {

                self.controlView.playBtn.hidden = NO;
                [_controlView pauseVideo];
            if([[YBYoungManager shareInstance] isOpenYoung]){
                
                UIAlertController *showAlert = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"青少年模式下，不能观看付费视频") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:YZMsg(@"去关闭") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Center];

                }];
                [cancelAction setValue:UIColor.grayColor forKey:@"_titleTextColor"];
                [closeAction setValue:normalColors_live forKey:@"_titleTextColor"];
                [showAlert addAction:cancelAction];
                [showAlert addAction:closeAction];
                [[[YBAppDelegate sharedAppDelegate] topViewController] presentViewController:showAlert animated:YES completion:nil];
            }else{

                NSString *msgTitle = [NSString stringWithFormat:YZMsg(@"该视频为私密视频，需支付%@%@观看\n开通VIP后可免费观看"),minstr([_currentVideoDic valueForKey:@"coin"]),[common name_coin]];

                WeakSelf;
                alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:msgTitle andButtonArrays:@[YZMsg(@"开通会员"),YZMsg(@"付费观看")] andButtonClick:^(int type) {
                    if (type == 2) {
                        NSString *url  = [NSString stringWithFormat:@"Video.BuyVideo&videoid=%@",minstr([_currentVideoDic valueForKey:@"id"])];
                        [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                            if (code == 0) {
                                NSMutableDictionary *oldDic = [NSMutableDictionary dictionaryWithDictionary:_currentVideoDic];
                                NSDictionary *newDic = @{@"cansee":@"1"};
                                [oldDic addEntriesFromDictionary:newDic];
                                _currentVideoDic = [NSDictionary dictionaryWithDictionary:oldDic];
                                [_videoList replaceObjectAtIndex:_lastPlayIndexPath.row withObject:_currentVideoDic];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADHOMEVIDEOLIST" object:nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADVIDEOLIST" object:nil];

                                [self startPlayerVideo];

                            }else if (code == 1005){
                                [weakSelf doRecharge];
                            }
                            [MBProgressHUD showError:msg];
                        } fail:^{

                        }];
                    }else if (type == 1) {
                        [weakSelf doVIP];
                    }
                    [weakSelf removeAlertView];
                }];
                [weakSelf.view addSubview:alert];
            }
        }else{
            self.controlView.playBtn.hidden = YES;

            [_controlView controlSingleTapped];
        }
    }
    if ([eventStr isEqual:@"控制-双击"]) {
    }
    if ([eventStr isEqual:@"控制-主页"]) {
    }
}
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeakSelf;
    YBLookVideoCell *cell = (YBLookVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.model = [[videoModel alloc]initWithDic:_videoList[indexPath.row]];
    cell.player = self.player;
    cell.delegate = self;
    cell.cellBtnEvent = ^(NSString *titleStr, videoModel *videoModel, NSDictionary *userDic) {
        if ([titleStr isEqual:@"点赞"]) {
            NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_videoList[indexPath.row]];
            [m_dic addEntriesFromDictionary:userDic];
            [_videoList replaceObjectAtIndex:indexPath.row withObject:m_dic];
            _currentVideoDic = [NSDictionary dictionaryWithDictionary:m_dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADHOMEVIDEOLIST" object:nil];

        }else if ([titleStr isEqual:@"分享"]){
        }else if ([titleStr isEqual:@"评论"]){
            if (_comment) {
                [_comment removeFromSuperview];
                _comment = nil;
            }
            NSString *commentStr = minstr([_currentVideoDic valueForKey:@"comments"]);

            if (!_comment) {
                _comment = [[commentview alloc]initWithFrame:CGRectMake(0,_window_height, _window_width, _window_height) hide:^(NSString *type) {
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.comment.frame = CGRectMake(0, _window_height, _window_width, _window_height);
                        //显示tabbar
                        self.tabBarController.tabBar.hidden = NO;
                    } ];
                } andvideoid:minstr([_currentVideoDic valueForKey:@"id"]) andhostid:_hostID count:[commentStr intValue] talkCount:^(id type) {
                    NSLog(@"yblookviedeoVC-----count:%@",type);
                    //默默更新数据
                    //视频-关注、视频-点赞、视频-评论
                    NSDictionary *newDic = @{@"comments":type};
                    NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_videoList[indexPath.row]];
                    [m_dic addEntriesFromDictionary:newDic];
                    [_videoList replaceObjectAtIndex:indexPath.row withObject:m_dic];
                    YBLookVideoCell *disCell = (YBLookVideoCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                    disCell.viewsL.text =[NSString stringWithFormat:@"%@",type];
                    _currentVideoDic = [NSDictionary dictionaryWithDictionary:m_dic];

                } detail:^(id type) {
        //            [weakSelf pushdetails:type];
                } youke:^(id type) {
//                    [PublicObj warnLogin];
                } andFrom:@""];
                    [self.view addSubview:_comment];
            }
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.comment.frame = CGRectMake(0,0,_window_width, _window_height);
            }];

        }else if ([titleStr isEqual:@"礼物"]){
            [weakSelf sendGiftWithModel:videoModel andUserDic:userDic];
        }else if ([titleStr isEqual:@"更多"]){
            if ([[Config getOwnID] isEqual:minstr([userDic valueForKey:@"id"])]) {

                UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:YZMsg(@"设置为公开视频") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self showAlertView];
                }];
                [action1 setValue:color32 forKey:@"_titleTextColor"];

                UIAlertAction *action2 = [UIAlertAction actionWithTitle:YZMsg(@"删除") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [self doDelVideo];
                }];
                [action2 setValue:color32 forKey:@"_titleTextColor"];

                
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [cancleAction setValue:color96 forKey:@"_titleTextColor"];
                if ([videoModel.isprivate isEqual:@"1"]) {
                    [alertContro addAction:action1];
                }
                [alertContro addAction:action2];
                [alertContro addAction:cancleAction];
                [self presentViewController:alertContro animated:YES completion:nil];
            }else{
                UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:YZMsg(@"举报") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self doJubao];
                }];
                [action2 setValue:color32 forKey:@"_titleTextColor"];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [cancleAction setValue:color96 forKey:@"_titleTextColor"];
                [alertContro addAction:action2];
                [alertContro addAction:cancleAction];
                
                UILabel *appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
                UIFont *font = [UIFont systemFontOfSize:13];
                [appearanceLabel setFont:font];

                [self presentViewController:alertContro animated:YES completion:nil];
            }
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [_textField resignFirstResponder];

    if (self.player.currentPlayIndex == indexPath.row) {
        return;
    }
    
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}
#pragma mark - UIScrollViewDelegate  列表播放必须实现
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
    if (!decelerate) {
        if (self.player.currentPlayIndex == 0 ) {
            [MBProgressHUD showError:YZMsg(@"已经到顶了哦")];
        }
        if (self.player.currentPlayIndex+1 == _videoList.count) {
            [MBProgressHUD showError:YZMsg(@"没有更多视频")];
        }
    }
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
//    lastContenOffset = scrollView.contentOffset.y;
}
#pragma mark----点击事件}

-(void)callBtnWithType:(int)callType andModel:(videoModel *)model andUserDic:(NSDictionary *)userDic
{
    _userDic = userDic;
    WeakSelf;
    if (callType == 1) {
        if (!actionView) {
            NSArray *imgArray = @[@"person_选择语音",@"person_选择视频"];
            NSArray *itemArray = @[[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"语音通话"),minstr([userDic valueForKey:@"voice_value"]),[common name_coin],YZMsg(@"分钟")],[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"视频通话"),minstr([userDic valueForKey:@"video_value"]),[common name_coin],YZMsg(@"分钟")]];
            if ([YBToolClass isUp]) {
                itemArray = @[YZMsg(@"语音通话"),YZMsg(@"视频通话")];
            }
            WeakSelf;
            actionView = [[personSelectActionView alloc]initWithImageArray:imgArray andItemArray:itemArray];
            actionView.block = ^(int item) {
                if (item == 0) {
                    [weakSelf sendCallwithType:@"2"];
                }
                if (item == 1) {
                    [weakSelf sendCallwithType:@"1"];
                }
            };
            [self.view addSubview:actionView];
        }
        [actionView show];
    }else if (callType == 2){
        [self sendCallwithType:@"1"];
    }else if (callType == 3){
        [self sendCallwithType:@"2"];
    }else{
        [MBProgressHUD showError:YZMsg(@"对方已关闭接听")];
    }

}
- (void)doJubao{
    jubaoVC *jubao = [[jubaoVC alloc]init];
    jubao.dongtaiId = minstr([_currentVideoDic valueForKey:@"id"]);
    [self.navigationController pushViewController:jubao animated:YES];
}
- (void)showAlertView{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:YZMsg(@"设为公开视频后，将不可再设置为私密视频") andButtonArrays:@[YZMsg(@"取消"),YZMsg(@"确定")] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf setPublic];
        }else{
            [weakSelf removeAlertView];
        }
    }];
    [self.view addSubview:alert];
}
- (void)setPublic{
    [YBToolClass postNetworkWithUrl:@"Video.setPublic" andParameter:@{@"videoid":minstr([_currentVideoDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            //ray
//            _model.isprivate = @"0";
            [self removeAlertView];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}

-(void)sendGiftWithModel:(videoModel *)model andUserDic:(NSDictionary *)userDic{
    
    if (!giftView) {
        giftView = [[liwuview alloc]initWithDic:@{@"uid":minstr([userDic valueForKey:@"id"]),@"showid":@"0"} andMyDic:nil];
        giftView.giftDelegate = self;
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
        [self.view addSubview:giftView];
        giftZheZhao = [UIButton buttonWithType:0];
        giftZheZhao.frame = CGRectMake(0, 0, _window_width, _window_height-(_window_width/2+100+ShowDiff));
        [giftZheZhao addTarget:self action:@selector(giftZheZhaoClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:giftZheZhao];
        giftZheZhao.hidden = YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height-(_window_width/2+100+ShowDiff), _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
        giftZheZhao.hidden = NO;
    }];

}
#pragma mark ============礼物=============

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
    NSString *type = minstr([playDic valueForKey:@"type"]);
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
        [liansongliwubottomview addSubview:continueGifts];
        //初始化礼物空位
        [continueGifts initGift];
    }
    if ([type isEqual:@"1"]) {
        [self expensiveGift:playDic];
    }
    else{
        [continueGifts GiftPopView:playDic andLianSong:@"Y"];
    }
    
}
- (void)pushCoinV{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:recharge animated:YES];
    
}
/************ 礼物弹出及队列显示开始 *************/
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
-(void)expensiveGift:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        //         [backScrollView insertSubview:haohualiwuV atIndex:8];
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
-(void)endExpensiveGift {
    if (haohualiwuV) {
        [haohualiwuV removeFromSuperview];
        haohualiwuV = nil;
    }
    if (continueGifts) {
        [continueGifts removeFromSuperview];
        continueGifts = nil;
    }
}
- (void)giftZheZhaoClick{
    giftZheZhao.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
    }];
}
#pragma mark ============发起通话=============
- (void)sendCallwithType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_userDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    NSDictionary *dic = @{
                          @"liveuid":minstr([_userDic valueForKey:@"id"]),
                          @"type":type,
                          @"sign":sign
                          };
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"content":@"邀请你通话"
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            
            V2TIMCustomElem * custom_elem = [[V2TIMCustomElem alloc] init];
            [custom_elem setData:data];
            WeakSelf;
            [[YBImManager shareInstance]sendV2CustomMsg:custom_elem andReceiver:minstr([_userDic valueForKey:@"id"]) complete:^(BOOL isSuccess, V2TIMMessage *sendMsg, NSString *desc) {
                if(isSuccess){
                    NSLog(@"SendMsg Succ");
                    [weakSelf showWaitView:infoDic andType:type];
                }else{
                    [MBProgressHUD showError:YZMsg(@"消息发送失败")];
                    [weakSelf sendMessageFaild:infoDic andType:type];
                }
            }];

        }else if(code == 800){
            [self showYuyue:type andMessage:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:minstr([_userDic valueForKey:@"id"]) forKey:@"id"];
    [muDic setObject:minstr([_userDic valueForKey:@"avatar"]) forKey:@"avatar"];
    [muDic setObject:minstr([_userDic valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
    [muDic setObject:minstr([_userDic valueForKey:@"level_anchor"]) forKey:@"level_anchor"];
    [muDic setObject:minstr([_userDic valueForKey:@"video_value"]) forKey:@"video_value"];
    [muDic setObject:minstr([_userDic valueForKey:@"voice_value"]) forKey:@"voice_value"];
    
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:navi animated:YES completion:nil];
    
}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_userDic valueForKey:@"id"]),minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":minstr([_userDic valueForKey:@"id"]),@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign,@"hangtype":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];
    
}
- (void)showYuyue:(NSString *)type andMessage:(NSString *)msg{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"预约") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self SetSubscribe:type];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
    
}
- (void)SetSubscribe:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_userDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":minstr([_userDic valueForKey:@"id"]),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}

@end
