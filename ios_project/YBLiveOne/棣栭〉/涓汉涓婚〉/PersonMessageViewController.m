//
//  PersonMessageViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "PersonMessageViewController.h"
#import "YBPageControl.h"
#import "messageTableView.h"
#import "personWordCell.h"
#import "personImpressCell.h"
#import "personLiveCell.h"
#import "personUserCell.h"
#import "liwuview.h"
#import "AnchorViewController.h"
#import "TChatController.h"
#import "TConversationCell.h"
#import "InvitationViewController.h"
//#import "TIMManager.h"
//#import "TIMMessage.h"
//#import "TIMConversation.h"
#import "GiftCabinetCell.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "MineImpressViewController.h"
#import "personSelectActionView.h"
#import "RechargeViewController.h"
#import "GiftCabinetViewController.h"
#import "videoShowCell.h"
#import "picShowCell.h"
#import "LookVideoViewController.h"
#import "liansongBackView.h"
#import "YBImageView.h"
#import "JPVideoPlayerKit.h"
#import "VIPViewController.h"
#import "ZoneView.h"
#import "ReportUserVC.h"
#import "ImageBrowserViewController.h"
#import "ShowDetailVC.h"

#import "YBLookPicVView.h"
#import "YBLookVideoVC.h"

#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import "YBScrollImageView.h"
#import <YYWebImage/YYWebImage.h>
#import "EditInfoViewController.h"
#import "GuardRankVC.h"

@interface PersonMessageViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,sendGiftDelegate,haohuadelegate,UICollectionViewDelegate,UICollectionViewDataSource,ZoneViewDelegate,continueGiftDelegate,UIGestureRecognizerDelegate,MutElementScrollDelegate>{
    UIView * firstBottomV;
    //UIImageView *firstBottomV;
    UIScrollView *topScroll;
    UIView *lastView;
    CGFloat btnHeight;
    //视频语音通话发起按钮
    UIButton *callBtn;
    //礼物
    UIButton *giftBtn;
    UIButton *secondGiftBtn;
    //关注
    UIButton *followBtn;
    UIButton *secondFollowBtn;

    //消息
    UIButton *messageBtn;
    UIButton *secondMessageBtn;

    //上啦按钮
    UIButton *upSwipBtn;
    //
    UIPageControl *pageControl;
    
    int page;
    NSArray *sectionArray;
    liwuview *giftView;
    UIButton *giftZheZhao;
    int callType;
    YBLookPicVView *picVView;
    
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    liansongBackView *liansongliwubottomview;

    personSelectActionView *actionView;
    UIView *moveLine;
    
    
    UIScrollView *bottomScrollV;
    NSMutableArray *segmentBtnArray;
    int videoPage;
    int picPage;

    
    YBAlertView *alert;
    NSArray *topImgArr;
    UIImageView *playerImgview;
    UIView *secondNavi;
    UIView *videoNothingView;
    UIView *picNothingView;

    NSString *blackActionTitle;
    
    BOOL isVideoAuthor;
    
    NSIndexPath *currentIndex;
    NSMutableArray *allVideoArr;
    NSMutableDictionary *videoDic;
    
    
    BOOL islisten;
    BOOL voiceEnd;
    int oldVoiceTime;
    NSTimer *voicetimer;
    UIImageView *headImg;
    BOOL _canScroll;
}
@property (nonatomic,strong) YBScrollView *backScroll;
@property (nonatomic,strong) UITableView *messageTable;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) UICollectionView *videoCollectionV;
@property (nonatomic,strong) NSMutableArray *videoArray;
@property (nonatomic,strong) UICollectionView *picCollectionV;
@property (nonatomic,strong) NSMutableArray *picArray;
@property (nonatomic,strong) ZoneView *zoneView;
@property (nonatomic, strong) ZFPlayerController *player;

@property(nonatomic,strong)UIImageView *audioImg;
@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property (strong, nonatomic)UILabel *voiceTimeLb;
@property (strong, nonatomic)UIImageView *vioceImgNormal;
@property(nonatomic,assign)int voicetime;//音频时长
@property (nonatomic,strong) AVPlayer *voicePlayer;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

@end

@implementation PersonMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.naviView.hidden = YES;
    _canScroll = YES;
    if ([minstr([_liveDic valueForKey:@"isblack"]) isEqual:@"1"]) {
        blackActionTitle = YZMsg(@"解除拉黑");
    }else{
        blackActionTitle = YZMsg(@"拉黑");
    }
    topImgArr = [_liveDic valueForKey:@"photos_list"];
    sectionArray = @[YZMsg(@"个人介绍"),YZMsg(@"个性签名"),YZMsg(@"主播形象"),YZMsg(@"用户印象"),YZMsg(@"个人资料"),YZMsg(@"礼物柜"),YZMsg(@"用户评价")];
    self.view.backgroundColor = [UIColor whiteColor];
    [self creatScrollView:@{}];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadVideolist) name:@"RELOADVIDEOLIST" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followEvent:) name:ybPersonFollowEvent object:nil];
}
-(void)reloadVideolist{
    videoPage = 1;
    [self pullVideoList];
}

- (void)creatScrollView:(NSDictionary *)dic{
    _backScroll = [[YBScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _backScroll.backgroundColor =RGBA(245, 245, 245, 1);// [UIColor whiteColor];
    _backScroll.pagingEnabled = NO;
    _backScroll.bounces = NO;
    _backScroll.delegate = self;
    _backScroll.contentSize = CGSizeMake(0, _window_height + _window_width + 56 - statusbarHeight);
    _backScroll.showsVerticalScrollIndicator = NO;
    _backScroll.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _backScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }

    [self.view addSubview:_backScroll];
    if (@available(iOS 11.0, *)) {
        _backScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([minstr([_liveDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_liveDic valueForKey:@"isvoice"]) isEqual:@"1"]) {
        callType = 1;
    }else if ([minstr([_liveDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_liveDic valueForKey:@"isvoice"]) isEqual:@"0"]){
        callType = 2;
    }else if ([minstr([_liveDic valueForKey:@"isvideo"]) isEqual:@"0"] && [minstr([_liveDic valueForKey:@"isvoice"]) isEqual:@"1"]){
        callType = 3;
    }else{
        callType = 0;
    }
    topScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width)];
    topScroll.delegate = self;
    topScroll.pagingEnabled = YES;
    topScroll.backgroundColor = [UIColor whiteColor];
    topScroll.showsVerticalScrollIndicator = NO;
    topScroll.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        topScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [_backScroll addSubview:topScroll];
    topScroll.contentSize = CGSizeMake(_window_width*topImgArr.count, 0);
    UITapGestureRecognizer *taps = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapclick)];
    [topScroll addGestureRecognizer:taps];
    for (int i = 0; i < topImgArr.count; i++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*i, 0, _window_width, _window_width)];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        imgV.backgroundColor = [UIColor whiteColor];
        [imgV sd_setImageWithURL:[NSURL URLWithString:[topImgArr[i] valueForKey:@"thumb"]]];
        [topScroll addSubview:imgV];
        if (i == 0 && [minstr([topImgArr[i] valueForKey:@"type"]) isEqual:@"1"]){
            playerImgview = imgV;
            CGSize imgsize = [self imagesizeurl:[topImgArr[0] valueForKey:@"thumb"]];
            if (imgsize.width > imgsize.height) {
                [self creatplay:1];
            }else{
                [self creatplay:0];
            }
           
        }
    }
    UIButton *ranBtn = [UIButton buttonWithType: 0];
    ranBtn.frame = CGRectMake(_window_width-86,_window_width-75-75, 70, 70);
    [ranBtn setImage:[UIImage imageNamed:getImagename(@"person_守护榜单")] forState:0];
    [ranBtn addTarget:self action:@selector(rankBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topScroll addSubview:ranBtn];
    
    UIImageView* mask_top = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100+statusbarHeight)];
    [mask_top setImage:[UIImage imageNamed:@"video_record_mask_top"]];
    [_backScroll addSubview:mask_top];

    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [_backScroll addSubview:rBtn];

    if ([minstr([_liveDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
        UIButton *righteditBtn = [UIButton buttonWithType:0];
        righteditBtn.frame = CGRectMake(_window_width-85, 24+statusbarHeight, 75, 24);
        [righteditBtn addTarget:self action:@selector(righteditBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [righteditBtn setBackgroundColor:RGBA(1, 1, 1, 0.4)];
        righteditBtn.layer.cornerRadius = 12;
        righteditBtn.layer.masksToBounds = YES;
        [righteditBtn setTitle:YZMsg(@"编辑资料") forState:0];
        [righteditBtn setTitleColor:UIColor.whiteColor forState:0];
        righteditBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_backScroll addSubview:righteditBtn];

    }else{
        UIButton *rightBtn = [UIButton buttonWithType:0];
        rightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);
        [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setImage:[UIImage imageNamed:@"三点白"] forState:0];
        [rightBtn setTintColor:[UIColor whiteColor]];
        [_backScroll addSubview:rightBtn];
    }

    firstBottomV = [[UIView alloc]initWithFrame:CGRectMake(15, _window_width-75, _window_width-30, 150)];
    firstBottomV.backgroundColor = [UIColor whiteColor];
    firstBottomV.clipsToBounds = YES;
    firstBottomV.layer.cornerRadius = 10;
    firstBottomV.layer.masksToBounds = YES;
    [_backScroll addSubview:firstBottomV];
    
    if (IS_IPHONE_5) {
        btnHeight = 30.0;
    }else{
        btnHeight = 36.0;
    }
//   [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(15, firstBottomV.height-1, _window_width - 30, 1) andColor:RGB_COLOR(@"#E5E5E5", 1) andView:firstBottomV];
    
//    UILabel *priceL = [[UILabel alloc]initWithFrame:CGRectMake(15, firstBottomV.height-48, _window_width-30, 28)];
    UILabel *priceL = [[UILabel alloc]init];
    priceL.font = SYS_Font(12);
    priceL.textColor = RGB_COLOR(@"#323232", 1);
    priceL.numberOfLines = 0;
    [firstBottomV addSubview:priceL];
    [priceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(firstBottomV.mas_width).offset(-30);
        make.centerX.bottom.equalTo(firstBottomV);
        make.height.mas_equalTo(48);
    }];
    if (callType == 1) {
        [callBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-视频语音")] forState:0];
        priceL.text = [NSString stringWithFormat:@"%@：%@%@/%@   %@：%@%@/%@",YZMsg(@"视频"),minstr([_liveDic valueForKey:@"video_value"]),[common name_coin],YZMsg(@"分钟"),YZMsg(@"语音"),minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin],YZMsg(@"分钟")];
        if ([YBToolClass isUp]) {
            priceL.text = [NSString stringWithFormat:@"%@：%@   %@：%@",YZMsg(@"视频"),YZMsg(@"已开启"),YZMsg(@"语音"),YZMsg(@"已开启")];
        }
    }else if (callType == 2){
        [callBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-视频")] forState:0];
        priceL.text = [NSString stringWithFormat:@"%@：%@%@/%@",YZMsg(@"视频"),minstr([_liveDic valueForKey:@"video_value"]),[common name_coin],YZMsg(@"分钟")];
        if ([YBToolClass isUp]) {
            priceL.text = [NSString stringWithFormat:@"%@：%@   %@：%@",YZMsg(@"视频"),YZMsg(@"已开启"),YZMsg(@"语音"),YZMsg(@"未开启")];
        }
    }else if (callType == 3){
        [callBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-语音")] forState:0];
        priceL.text = [NSString stringWithFormat:@"%@：%@%@/%@",YZMsg(@"语音"),minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin],YZMsg(@"分钟")];
        if ([YBToolClass isUp]) {
            priceL.text = [NSString stringWithFormat:@"%@：%@   %@：%@",YZMsg(@"视频"),YZMsg(@"未开启"),YZMsg(@"语音"),YZMsg(@"已开启")];
        }
    }else{
        [callBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-视频语音")] forState:0];
        priceL.text = [NSString stringWithFormat:@"%@：%@   %@：%@",YZMsg(@"视频"),YZMsg(@"未开启"),YZMsg(@"语音"),YZMsg(@"未开启")];
    }
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, firstBottomV.top - 25, _window_width, 20)];
    pageControl.numberOfPages = topImgArr.count;
    pageControl.currentPageIndicatorTintColor = RGB_COLOR(@"#E014E2", 1);
    pageControl.pageIndicatorTintColor = RGB_COLOR(@"#b8b4b2", 1);
    pageControl.hidesForSinglePage = YES;
    pageControl.currentPage = 0;
    pageControl.enabled = NO;
    //pageControl.backgroundColor = [UIColor redColor];
    [_backScroll addSubview:pageControl];
  //  [firstBottomV addSubview:pageControl];
    
    [firstBottomV layoutIfNeeded];
    
    UIImageView *sexImgV = [[UIImageView alloc]initWithFrame:CGRectMake(priceL.left, priceL.top-18, 15, 15)];
    if ([minstr([_liveDic valueForKey:@"sex"]) isEqual:@"1"]) {
        sexImgV.image = [UIImage imageNamed:@"person_性别男"];
    }else{
        sexImgV.image = [UIImage imageNamed:@"person_性别女"];
    }
    [firstBottomV addSubview:sexImgV];
    
    UIButton *liveingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [liveingBtn addTarget:self action:@selector(clickLiveingBtn) forControlEvents:UIControlEventTouchUpInside];
    NSURL *imgUrl = [[NSBundle mainBundle] URLForResource:getImagename(@"person_living") withExtension:@"gif"];
    [liveingBtn sd_setImageWithURL:imgUrl forState:0];
    [firstBottomV addSubview:liveingBtn];
    [liveingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(firstBottomV.mas_right).offset(-10);
        make.centerY.equalTo(sexImgV);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(26);
    }];
    int isliveing = [minstr([_liveDic valueForKey:@"islive"]) intValue];
    liveingBtn.hidden = !isliveing;
    
    UIImageView *locationImgV = [[UIImageView alloc]initWithFrame:CGRectMake(sexImgV.right+10, priceL.top-18, 15, 15)];
    locationImgV.image = [UIImage imageNamed:@"person_位置"];
    [firstBottomV addSubview:locationImgV];
    NSString *city = minstr([_liveDic valueForKey:@"city"]);
    CGFloat locationWidth = [[YBToolClass sharedInstance] widthOfString:city andFont:SYS_Font(12) andHeight:15];
    UILabel *locationL = [[UILabel alloc]initWithFrame:CGRectMake(locationImgV.right+5, sexImgV.top, locationWidth, sexImgV.height)];
    locationL.font = SYS_Font(12);
    locationL.text = city;
    locationL.textColor = RGB_COLOR(@"#969696", 1);
    [firstBottomV addSubview:locationL];

    UIView *shuline = [[UIView alloc] initWithFrame:CGRectMake(locationL.right + 10, sexImgV.top + 2.5, 1, 10)];
    shuline.backgroundColor = RGB_COLOR(@"#C8C8C8", 1);
    [firstBottomV addSubview:shuline];
   // [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(locationL.right+10, sexImgV.top+2.5, 1, 10) andColor:RGB_COLOR(@"#C8C8C8", 1) andView:lastView];
    
    UILabel *idLabel = [[UILabel alloc]initWithFrame:CGRectMake(shuline.right+10, sexImgV.top, 100, sexImgV.height)];
    idLabel.font = SYS_Font(13);
    idLabel.text = [NSString stringWithFormat:@"ID:%@",minstr([_liveDic valueForKey:@"id"])];
    idLabel.textColor = RGB_COLOR(@"#969696", 1);
    [firstBottomV addSubview:idLabel];
    
    NSString *name = minstr([_liveDic valueForKey:@"user_nickname"]);

    CGFloat nameWidth = [[YBToolClass sharedInstance] widthOfString:name andFont:SYS_Font(17) andHeight:24];

    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(priceL.left, sexImgV.top-34, nameWidth, 24)];
    nameLabel.font = SYS_Font(17);
    nameLabel.text = name;
    nameLabel.textColor = RGB_COLOR(@"#323232", 1);
    [firstBottomV addSubview:nameLabel];
    
    UIImageView *starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.right+8, nameLabel.top+4.5, 25, 15)];
    [starImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:minstr([_liveDic valueForKey:@"level_anchor"])]]];
    [firstBottomV addSubview:starImgV];

    UIImageView *stateImgV = [[UIImageView alloc]initWithFrame:CGRectMake(starImgV.right+8, nameLabel.top+4.5, 36, 15)];
    NSArray *onlineArr = @[@"离线",@"勿扰",@"在聊",@"在线"];
    NSString *imgStr = [NSString stringWithFormat:@"主页状态-%@",onlineArr[[minstr([_liveDic valueForKey:@"online"]) intValue]]];
    stateImgV.image = [UIImage imageNamed:getImagename(imgStr)];

    [firstBottomV addSubview:stateImgV];

    
    if ([minstr([_liveDic valueForKey:@"isvip"]) isEqual:@"1"] && ![YBToolClass isUp]) {
        UIImageView *vipImgV = [[UIImageView alloc]initWithFrame:CGRectMake(starImgV.right+8, nameLabel.top+4.5, 25, 15)];
        vipImgV.image = [UIImage imageNamed:@"vip"];
        [firstBottomV addSubview:vipImgV];
        stateImgV.x = vipImgV.right + 8;
    }

    
    UILabel *fansL = [[UILabel alloc]initWithFrame:CGRectMake(firstBottomV.width-60, 15, 50, 40)];
    fansL.font = SYS_Font(13);
    fansL.numberOfLines = 2;
    fansL.text = [NSString stringWithFormat:@"%@\n%@",minstr([_liveDic valueForKey:@"fans"]),YZMsg(@"粉丝")];
    fansL.textColor = RGB_COLOR(@"#323232", 1);
    fansL.textAlignment = NSTextAlignmentCenter;
    [firstBottomV addSubview:fansL];
    
    headImg = [[UIImageView alloc]init];
    headImg.layer.cornerRadius = 40;
    headImg.layer.masksToBounds = YES;
    headImg.contentMode = UIViewContentModeScaleToFill;
    [headImg sd_setImageWithURL:[NSURL URLWithString:minstr([_liveDic valueForKey:@"avatar"])]];
    [_backScroll addSubview:headImg];
    [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstBottomV.mas_left).offset(10);
        make.centerY.equalTo(firstBottomV.mas_top);
        make.height.width.mas_equalTo(80);
    }];
    [_backScroll layoutIfNeeded];
    
    [_backScroll addSubview:self.audioImg];
    if (minstr([_liveDic valueForKey:@"audio"]).length > 1) {
        self.audioImg.hidden = NO;
        _voicetime = [minstr([_liveDic valueForKey:@"audio_length"]) intValue];
        _voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
    }

    [self creatSecondPageView];
    
    liansongliwubottomview = [[liansongBackView alloc]init];
    [self.view addSubview:liansongliwubottomview];
    liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);


}
#pragma mark ----排行榜-----
-(void)rankBtnClick{
    GuardRankVC *rank = [[GuardRankVC alloc]init];
    [[YBAppDelegate sharedAppDelegate]pushViewController:rank animated:YES];
}
-(void)clickLiveingBtn {
    NSDictionary *subDic = [_liveDic valueForKey:@"live_info"];
    if([minstr([subDic valueForKey:@"uid"]) isEqual:_roomUid]){
        [[YBAppDelegate sharedAppDelegate] popViewController:YES];
    }else {
        [YBLiveUnitManager shareInstance].liveUid = minstr([subDic valueForKey:@"uid"]);
        [YBLiveUnitManager shareInstance].liveStream = minstr([subDic valueForKey:@"stream"]);
        [YBLiveUnitManager shareInstance].currentIndex = 0;
        [YBLiveUnitManager shareInstance].listArray = @[subDic];
        [[YBLiveUnitManager shareInstance] checkLiving];
    }
    
}

-(UIImageView *)audioImg{
    if (!_audioImg) {
        _audioImg = [[UIImageView alloc]init];
//        _audioImg.frame =CGRectMake(_window_width-_window_width/2*0.8-10,_window_width-75-45, _window_width/2*0.8, 30);
        _audioImg.frame =CGRectMake(0,headImg.bottom-17, headImg.width *0.7, 20);
        _audioImg.centerX = headImg.centerX;
//        _audioImg.backgroundColor = normalColors;
        _audioImg.userInteractionEnabled = YES;
//        _audioImg.layer.cornerRadius = 10;
//        _audioImg.layer.masksToBounds = YES;
        _audioImg.image = [UIImage imageNamed:@"person_audioBg"];
        _audioImg.hidden = YES;
        
        
        UIImageView *lbImg = [[UIImageView alloc]init];
        lbImg.image = [UIImage imageNamed:@"laba"];
        lbImg.frame = CGRectMake(_audioImg.width/2-17, 3, 14, 14);
        lbImg.image = [UIImage imageNamed:@"laba"];
        lbImg.userInteractionEnabled = YES;
        [_audioImg addSubview:lbImg];
        
//        _animationView = [[YYAnimatedImageView alloc]init];
//        NSURL *url = [[NSBundle mainBundle] URLForResource:@"trendslistaudeo" withExtension:@"gif"];
//        _animationView.yy_imageURL = url;
//        _animationView.hidden = YES;
//        [_audioImg addSubview:_animationView];
//        [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(_audioImg);
//            make.left.equalTo(_audioImg).offset(20);
//            make.width.equalTo(_audioImg).multipliedBy(0.6);
//            make.height.mas_equalTo(30);
//        }];

        
//        _vioceImgNormal = [[UIImageView alloc]init];
//        _vioceImgNormal.image =[UIImage imageNamed:@"icon_voice_play_1"];
//        _vioceImgNormal.userInteractionEnabled = YES;
//        [_audioImg addSubview:_vioceImgNormal];
//        [_vioceImgNormal mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(_audioImg);
//            make.left.equalTo(_audioImg).offset(20);
//            make.width.equalTo(_audioImg).multipliedBy(0.6);
//            make.height.mas_equalTo(18);
//
//        }];

        _voiceTimeLb = [[UILabel alloc]init];
        _voiceTimeLb.textColor =[UIColor whiteColor];
        _voiceTimeLb.font = [UIFont systemFontOfSize:14];
        [_audioImg addSubview:_voiceTimeLb];
        [_voiceTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lbImg.mas_right).offset(8);
            make.centerY.equalTo(_audioImg.mas_centerY);
            make.right.equalTo(_audioImg.mas_right);
            make.height.mas_equalTo(16);
        }];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioImgClick)];
        [_audioImg addGestureRecognizer:singleTap];
    }
    return _audioImg;

}



-(void)creatplay:(int)code{
    /// playerManager
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
    
    /// player的tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:playerImgview];
    [self.player setDisableGestureTypes:ZFPlayerDisableGestureTypesAll];
    if (code == 0) {
        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
    }else{
        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
    }
   
    self.player.playerDisapperaPercent = 1.0;
}
- (void)creatSecondPageView{
    
    UIView *secondTopView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_width + 75, _window_width, 40)];
    secondTopView.backgroundColor =RGBA(245, 245, 245, 1);// [UIColor clearColor];
    [_backScroll addSubview:secondTopView];
    segmentBtnArray = [NSMutableArray array];
    NSArray *array = @[YZMsg(@"资料"),YZMsg(@"视频"),YZMsg(@"相册"),YZMsg(@"动态")];

    for (int i = 0; i < array.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake((_window_width-240)/5+i*((_window_width-240)/5 + 60), 0, 60, 35);
        [btn setTitle:array[i] forState:0];
        [btn setTitleColor:color32 forState:UIControlStateSelected];
        [btn setTitleColor:color96 forState:0];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [secondTopView addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            moveLine = [[UIView alloc]initWithFrame:CGRectMake(btn.centerX-15, btn.centerY+2, 30, 6)];
            moveLine.backgroundColor = RGB_COLOR(@"#7014e2",0.3);
            moveLine.layer.cornerRadius = 3;
            moveLine.layer.masksToBounds = YES;
            [secondTopView addSubview:moveLine];
        }
        btn.tag = 1957+i;
        [segmentBtnArray addObject:btn];
    }
    
    UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, secondTopView.bottom, _window_width, _window_height-40)];
    secondView.backgroundColor = [UIColor clearColor];
    [_backScroll addSubview:secondView];

    //bottomScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight+40, _window_width, _window_height-64-60-statusbarHeight-ShowDiff-40)];
    bottomScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0,10, _window_width, _window_height-64 - statusbarHeight-60-ShowDiff)];
    bottomScrollV.backgroundColor = [UIColor clearColor];
    bottomScrollV.contentSize = CGSizeMake(_window_width*4, 0);
    bottomScrollV.pagingEnabled = YES;
    bottomScrollV.bounces = NO;
    bottomScrollV.delegate = self;
    [secondView addSubview:bottomScrollV];
    
    for (int i = 0; i < 4; i ++) {
        UIView *backWhiteview = [[UIView alloc]init];
        backWhiteview.frame = CGRectMake(15+_window_width *i, 0, _window_width-30, bottomScrollV.height);
        backWhiteview.layer.cornerRadius = 10;
        backWhiteview.layer.masksToBounds = YES;
        backWhiteview.backgroundColor = UIColor.whiteColor;
        [bottomScrollV addSubview:backWhiteview];
    }
    
    
    _messageTable = [[UITableView alloc]initWithFrame:CGRectMake(15, 10, secondView.width-30, _window_height-64-statusbarHeight-60-ShowDiff-20) style:0];
    _messageTable.delegate = self;
    _messageTable.dataSource = self;
    //_messageTable.scrollEnabled = NO;
    _messageTable.separatorStyle = 0;
    _messageTable.backgroundColor = [UIColor clearColor];
    [bottomScrollV addSubview:_messageTable];
    _messageTable.showsHorizontalScrollIndicator = NO;
    _messageTable.showsVerticalScrollIndicator = NO;
    [_messageTable registerClass:[messageTableView class] forHeaderFooterViewReuseIdentifier:@"messageHeaderView"];
    
    _videoArray = [NSMutableArray array];
    allVideoArr = [NSMutableArray array];
    videoPage = 1;

    [bottomScrollV addSubview:self.videoCollectionV];
    [bottomScrollV addSubview:self.picCollectionV];

    [bottomScrollV addSubview:self.zoneView];

    [_zoneView layoutTableWithFlag:@"个中"];
    _zoneView.fVC = self;
    [_zoneView pullData:@"Dynamic.getHomeDynamic" withliveId:minstr([_liveDic valueForKey:@"id"])];
    
    if (![minstr([_liveDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
        UIView *secondLastView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-60-ShowDiff, _window_width, 60+ShowDiff)];
        secondLastView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:secondLastView];
        
        CGFloat btnLeft = 0;
        if ([[YBYoungManager shareInstance]isOpenYoung]) {
            btnLeft =_window_width-10;
        }else{
            btnLeft =_window_width-(btnHeight+1)*3.33-10;
        }
        if (![[YBYoungManager shareInstance]isOpenYoung]) {
            UIButton *secondCallBtn = [UIButton buttonWithType:0];
            secondCallBtn.frame = CGRectMake(btnLeft, (60-btnHeight)/2, btnHeight*3.33, btnHeight);
            [secondCallBtn addTarget:self action:@selector(callBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [secondLastView addSubview:secondCallBtn];
            if (callType == 1) {
                [secondCallBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-视频语音")] forState:0];
            }else if (callType == 2){
                [secondCallBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-视频")] forState:0];
            }else if (callType == 3){
                [secondCallBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-语音")] forState:0];
            }else{
                [secondCallBtn setImage:[UIImage imageNamed:getImagename(@"person_按钮-视频语音")] forState:0];
//                secondCallBtn.userInteractionEnabled = NO;
            }
        }

        NSArray *arr;
        if ([[YBYoungManager shareInstance]isOpenYoung]) {
            arr = @[@"person_未关注2",@"person_私信2"];

        }else{
            arr = @[@"person_礼物2",@"person_未关注2",@"person_私信2"];
        }
        for (int i = 0; i < arr.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(btnLeft-(i+1)*(5+50), 5, 50, 50);
            [btn setImage:[UIImage imageNamed:arr[i]] forState:0];
            [btn addTarget:self action:@selector(lastBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [secondLastView addSubview:btn];
            if ([[YBYoungManager shareInstance]isOpenYoung]) {
                switch (i) {
                    case 0:
                        secondFollowBtn = btn;
                        [secondFollowBtn setImage:[UIImage imageNamed:@"person_已关注2"] forState:UIControlStateSelected];
                        if ([minstr([_liveDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                            secondFollowBtn.selected = YES;
                        }else{
                            secondFollowBtn.selected = NO;
                        }

                        break;
                    case 1:
                        secondMessageBtn = btn;
                        break;
                        
                    default:
                        break;
                }

            }else{
                switch (i) {
                    case 0:
                        secondGiftBtn = btn;
                        break;
                    case 1:
                        secondFollowBtn = btn;
                        [secondFollowBtn setImage:[UIImage imageNamed:@"person_已关注2"] forState:UIControlStateSelected];
                        if ([minstr([_liveDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                            secondFollowBtn.selected = YES;
                        }else{
                            secondFollowBtn.selected = NO;
                        }

                        break;
                    case 2:
                        secondMessageBtn = btn;
                        break;
                        
                    default:
                        break;
                }

            }
            
            
        }
    }

    //顶部
    secondNavi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    //secondNavi = [[UIView alloc]initWithFrame:CGRectMake(0, _window_width + 56 - statusbarHeight, _window_width, 64+statusbarHeight)];
    secondNavi.backgroundColor = [UIColor whiteColor];
     [self.view addSubview:secondNavi];
    secondNavi.alpha = 0;
     UIButton *yinrBtn = [UIButton buttonWithType:0];
     yinrBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
     //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
     [yinrBtn setImage:[UIImage imageNamed:@"navi_backImg"] forState:0];
     [yinrBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
     [secondNavi addSubview:yinrBtn];
    UILabel *titleL2 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80, 34+statusbarHeight, 160, 20)];
    titleL2.font = SYS_Font(16);
    titleL2.textColor = color32;
    titleL2.text = minstr([_liveDic valueForKey:@"user_nickname"]);
    titleL2.textAlignment = NSTextAlignmentCenter;
    [secondNavi addSubview:titleL2];
    
    if ([minstr([_liveDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
        UIButton *righteditBtn = [UIButton buttonWithType:0];
        righteditBtn.frame = CGRectMake(_window_width-85, 24+statusbarHeight, 75, 24);
        [righteditBtn addTarget:self action:@selector(righteditBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [righteditBtn setBackgroundColor:RGBA(1, 1, 1, 0.4)];
        righteditBtn.layer.cornerRadius = 12;
        righteditBtn.layer.masksToBounds = YES;
        [righteditBtn setTitle:YZMsg(@"编辑资料") forState:0];
        [righteditBtn setTitleColor:UIColor.whiteColor forState:0];
        righteditBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [secondNavi addSubview:righteditBtn];

    }else{
        UIButton *yinrightBtn = [UIButton buttonWithType:0];
        yinrightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);
        [yinrightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [yinrightBtn setImage:[UIImage imageNamed:@"三点"] forState:0];
        [secondNavi addSubview:yinrightBtn];

    }

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, secondNavi.height-1, _window_width, 1) andColor:RGB_COLOR(@"#fafafa", 1) andView:secondNavi];
    //secondNavi.hidden = YES;
    
    _listArray = [NSMutableArray array];
    page = 1;
    _messageTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self pullInternet];
    }];
    [self pullInternet];
    [self pullPicList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pullVideoList];
    });



}
-(void)righteditBtnClick{
    EditInfoViewController *auth = [[EditInfoViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];

}
-(void)doReturn{
    [self sendGiftEnd];
    [[YBAppDelegate sharedAppDelegate]popViewController:YES];
}
- (ZoneView *)zoneView {
    if (!_zoneView) {
        _zoneView = [[ZoneView alloc]initWithFrame:CGRectMake(_window_width*3+15,10, _window_width-30, _window_height-64-60-statusbarHeight-ShowDiff-40-10)];
        _zoneView.translatesAutoresizingMaskIntoConstraints = NO;
        _zoneView.delegate = self;
        _zoneView.mutScrollDelegate = self;
        WeakSelf;
        _zoneView.zoneScrollEvent = ^(CGFloat contentY) {
            [weakSelf isscrolltop];
        };
    }
    return _zoneView;
}
-(void)cellImgaeClick:(NSMutableArray *)imagearr atIndex:(NSInteger)index
{
    [ImageBrowserViewController show:self type:PhotoBroswerVCTypeModal hideDelete:YES index:index imagesBlock:^NSArray *{
        return imagearr;
        
    } retrunBack:^(NSMutableArray *imgearr) {
    }];
    
}
-(void)cellVideoClick:(NSString *)videourl
{
    ShowDetailVC *detail = [[ShowDetailVC alloc]init];
    detail.fromStr = @"trendlist";
    detail.videoPath =videourl;
    detail.backcolor = @"video";

    detail.deleteEvent = ^(NSString *type) {
    };
    [[YBAppDelegate sharedAppDelegate]pushViewController:detail animated:YES];
}

- (void)pullInternet{
    
    [YBToolClass postNetworkWithUrl:@"Label.GetEvaluateList" andParameter:@{@"liveuid":minstr([_liveDic valueForKey:@"id"]),@"p":@(page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_messageTable.mj_footer endRefreshing];

        if (code == 0) {
            if (page == 1) {
                [_listArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                [_listArray addObject:[[personUserModel alloc] initWithDic:dic]];
            }
            [_messageTable reloadData];
            if ([info count] == 0) {
                [_messageTable.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^{
        [_messageTable.mj_footer endRefreshing];
    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 6) {
        return _listArray.count;
    }
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    messageTableView *headerView = (messageTableView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"messageHeaderView"];
    if (headerView == nil) {
        headerView = [[messageTableView alloc] initWithReuseIdentifier:@"messageHeaderView"];
    }
    UITapGestureRecognizer *tapppp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doliwugui)];

    headerView.titleL.text = sectionArray[section];
    headerView.giftL.hidden = YES;
    headerView.rightImgV.hidden = YES;
    headerView.giftNumL.hidden = YES;
    headerView.badL.hidden = YES;
    headerView.badImgV.hidden = YES;
    headerView.goodL.hidden = YES;
    headerView.goodImgV.hidden = YES;
    [headerView removeGestureRecognizer:tapppp];
    if (section == 5) {
        headerView.rightImgV.hidden = NO;
        headerView.giftNumL.hidden = NO;
        headerView.giftL.hidden = NO;

        headerView.giftNumL.text = minstr([_liveDic valueForKey:@"gift_total"]);
        headerView.giftL.text = YZMsg(@"礼物总数");
        [headerView addGestureRecognizer:tapppp];
    }else if(section == 6){
        headerView.badL.hidden = NO;
        headerView.badL.text = minstr([_liveDic valueForKey:@"badnums"]);
        headerView.badImgV.hidden = NO;
        headerView.goodL.hidden = NO;
        headerView.goodL.text = minstr([_liveDic valueForKey:@"goodnums"]);
        headerView.goodImgV.hidden = NO;
        
    }
    headerView.backgroundColor = UIColor.clearColor;
    return headerView;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || indexPath.section == 1) {
        personWordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personWordCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personWordCell" owner:nil options:nil] lastObject];
        }
        if (indexPath.section == 0) {
            cell.contentL.text = minstr([_liveDic valueForKey:@"intr"]);
        }else{
            cell.contentL.text = minstr([_liveDic valueForKey:@"signature"]);
        }
        cell.contentView.backgroundColor = UIColor.clearColor;
        return cell;

    }else if (indexPath.section == 2 || indexPath.section == 3){
        if (indexPath.section == 2) {
            personImpressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personImpressCELL"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"personImpressCell" owner:nil options:nil] lastObject];
                cell.nothingL.text = YZMsg(@"TA还没有收到印象");
            }

            cell.nothingL.hidden = YES;
            cell.rightJiantou.hidden = YES;
            NSArray *labels = [_liveDic valueForKey:@"label_list"];
            for (int i = 0; i < labels.count; i ++) {
                NSDictionary *dic = labels[i];
                if (i == 0) {
                    cell.view1.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    cell.label1.text = minstr([dic valueForKey:@"name"]);
                }
                if (i == 1) {
                    cell.view2.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    cell.lable2.text = minstr([dic valueForKey:@"name"]);
                }
                if (i == 2) {
                    cell.view3.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    cell.label3.text = minstr([dic valueForKey:@"name"]);
                }
            }
            return cell;

        }else{
            personImpressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personImpressCELL00"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"personImpressCell" owner:nil options:nil] lastObject];
                cell.nothingL.text = YZMsg(@"TA还没有收到印象");
            }

            NSArray *labels = [_liveDic valueForKey:@"evaluate_list"];
            cell.rightJiantou.hidden = NO;

            if (labels.count == 0) {
                cell.nothingL.hidden = NO;
            }else{
                cell.nothingL.hidden = YES;
                for (int i = 0; i < labels.count; i ++) {
                    NSDictionary *dic = labels[i];
                    if (i == 0) {
                        cell.view1.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                        cell.label1.text = minstr([dic valueForKey:@"name"]);
                    }
                    if (i == 1) {
                        cell.view2.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                        cell.lable2.text = minstr([dic valueForKey:@"name"]);
                    }
                    if (i == 2) {
                        cell.view3.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                        cell.label3.text = minstr([dic valueForKey:@"name"]);
                    }
                }
            }
            return cell;
        }
//        return cell;

    }else if (indexPath.section == 4){
        personLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personLiveCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personLiveCell" owner:nil options:nil] lastObject];
            cell.logL.text = YZMsg(@"最后登录：");
            cell.jietingL.text = YZMsg(@"接听率：");
            cell.heightL.text = YZMsg(@"身高：");
            cell.bodyL.text = YZMsg(@"体重：");
            cell.cityL.text = YZMsg(@"城市：");
            cell.starL.text = YZMsg(@"星座：");
        }
        cell.label1.text = minstr([_liveDic valueForKey:@"last_online_time"]);
        cell.label2.text = minstr([_liveDic valueForKey:@"answer_rate"]);
        cell.label3.text = [NSString stringWithFormat:@"%@cm",minstr([_liveDic valueForKey:@"height"])];
        cell.label4.text = [NSString stringWithFormat:@"%@kg",minstr([_liveDic valueForKey:@"weight"])];
        cell.label5.text = minstr([_liveDic valueForKey:@"city"]);
        cell.label6.text = minstr([_liveDic valueForKey:@"constellation"]);
        /*rk_fy
        NSString *startId = minstr([_liveDic valueForKey:@"constellation"]);
        cell.label6.text = [YBToolClass getStartWithId:startId];
         */
        return cell;

    }else if (indexPath.section == 5){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celllll"];
        if (!cell) {    
            cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"celllll"];
            cell.selectionStyle = 0;
            NSArray *gift_list = [_liveDic valueForKey:@"gift_list"];
            if (gift_list.count == 0) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, cell.contentView.width, 50)];
                label.text = YZMsg(@"TA还没有收到礼物");
                label.font = SYS_Font(12);
                label.textColor = color96;
                [cell.contentView addSubview:label];
            }else{
                for (int i = 0; i < gift_list.count; i++) {
                    NSDictionary *dic = gift_list[i];
                    GiftCabinetCell *view = [[[NSBundle mainBundle] loadNibNamed:@"GiftCabinetCell" owner:nil options:nil] lastObject];
                    view.frame = CGRectMake((_window_width-30)/5*i, 0, (_window_width-30)/5, (_window_width-30)/5+40);
                    [cell.contentView addSubview:view];
                    [view.thumbImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
                    view.nameL.text = minstr([dic valueForKey:@"name"]);
                    view.giftNumL.text = minstr([dic valueForKey:@"total_nums"]);
                }
            }
        }
        return cell;
    }else{
        personUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personUserCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personUserCell" owner:nil options:nil] lastObject];
        }
        cell.model = _listArray[indexPath.row];
        return cell;
    }
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [[YBToolClass sharedInstance] heightOfString:minstr([_liveDic valueForKey:@"signature"]) andFont:SYS_Font(12) andWidth:_window_width-30]+25;
    }else if (indexPath.section == 1) {
        return [[YBToolClass sharedInstance] heightOfString:minstr([_liveDic valueForKey:@"intr"]) andFont:SYS_Font(12) andWidth:_window_width-30]+25;
    }else if (indexPath.section == 2 || indexPath.section == 3){
        return 50;
    }else if (indexPath.section == 4){
        return 135;
    }else if (indexPath.section == 5){
        NSArray *gift_list = [_liveDic valueForKey:@"gift_list"];
        if (gift_list.count == 0) {
            return  50;
        }
        return _window_width/5+40;
    }else{
        return 50;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        MineImpressViewController *impress = [[MineImpressViewController alloc]init];
        impress.touid = minstr([_liveDic valueForKey:@"id"]);
        [self.navigationController pushViewController:impress animated:YES];
    }
}

#pragma mark =========顶部轮播点击放大=====
-(void)tapclick{
    YBScrollImageView *imgView = [[YBScrollImageView alloc] initWithImageArray:topImgArr andIndex:pageControl.currentPage andMine:NO isCanScrol:YES andBlock:^(NSArray * _Nonnull array) {
    }];
    [imgView hideDelete];
    [[UIApplication sharedApplication].keyWindow addSubview:imgView];

    [self playerStop];
   // [self pauseclick:YES];
//    WeakSelf;
//    picVView = [[YBLookPicVView alloc] init:topImgArr andindex:pageControl.currentPage];
//    picVView.block = ^(int code) {
//        [weakSelf pauseclick:NO];
//
//    };
//    [self.view addSubview:picVView];

}
-(void)pauseclick:(BOOL)ispause{
//    if (!ispause) {
//        [picVView removeFromSuperview];
//        picVView = nil;
//        if (pageControl.currentPage != 0) {
//            return;
//        }
//    }
  //  [self.player setPauseByEvent:ispause];
    [picVView removeFromSuperview];
    picVView = nil;
    if (pageControl.currentPage != 0) {
        return;
    }
    [self playerPlay];
}
#pragma mark ============底部按钮点击事件=============
- (void)callBtnClick{
    if (callType == 1) {

        if (!actionView) {
            NSArray *imgArray = @[@"person_选择语音",@"person_选择视频"];
            NSArray *itemArray = @[[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"语音通话"),minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin],YZMsg(@"分钟")],[NSString stringWithFormat:@"%@（%@%@/%@）",YZMsg(@"视频通话"),minstr([_liveDic valueForKey:@"video_value"]),[common name_coin],YZMsg(@"分钟")]];
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
- (void)lastBtnClick:(UIButton *)sender{
    if (sender == giftBtn || sender == secondGiftBtn) {
        //礼物
        if (!giftView) {
            giftView = [[liwuview alloc]initWithDic:@{@"uid":minstr([_liveDic valueForKey:@"id"]),@"showid":@"0"} andMyDic:nil];
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
    if (sender == followBtn || sender == secondFollowBtn) {
        //关注
        WeakSelf
        [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic = [info firstObject];
                int isattent = [minstr([infoDic valueForKey:@"isattent"]) intValue];
                [weakSelf changeFollow:isattent];
            }
            [MBProgressHUD showError:msg];

        } fail:^{
            
        }];
    }
    if (sender == messageBtn || sender == secondMessageBtn) {
        //消息
        TConversationCellData *data = [[TConversationCellData alloc] init];
        data.convId = minstr([_liveDic valueForKey:@"id"]);
        data.convType = TConv_Type_C2C;
        data.title = minstr([_liveDic valueForKey:@"user_nickname"]);
        data.userHeader = minstr([_liveDic valueForKey:@"avatar"]);
        data.userName = minstr([_liveDic valueForKey:@"user_nickname"]);
        data.level_anchor = minstr([_liveDic valueForKey:@"level_anchor"]);
        data.isauth = minstr([_liveDic valueForKey:@"isauth"]);
        data.isAtt = [NSString stringWithFormat:@"%d",secondFollowBtn.selected];
        data.isVIP = minstr([_liveDic valueForKey:@"isvip"]);
        data.isblack = minstr([_liveDic valueForKey:@"isblack"]);

        TChatController *chat = [[TChatController alloc] init];
        chat.conversation = data;
        [self.navigationController pushViewController:chat animated:YES];
    }

}

-(void)followEvent:(NSNotification *)noti {
    int isattent = [minstr(noti.object) intValue];
    [self changeFollow:isattent];
}
-(void)changeFollow:(int)isattent {
    followBtn.selected = isattent;
    secondFollowBtn.selected = isattent;

    NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_liveDic];
    [m_dic setObject:@(isattent) forKey:@"isattent"];
    _liveDic = [NSDictionary dictionaryWithDictionary:m_dic];
}


#pragma mark ============礼物=============

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
    NSString *type = minstr([playDic valueForKey:@"type"]);
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
        continueGifts.delegate = self;

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
-(void)sendGiftEnd
{
    if (continueGifts) {
        [continueGifts removeFromSuperview];
        continueGifts = nil;
    }
    if (haohualiwuV) {
        [haohualiwuV removeFromSuperview];
        haohualiwuV = nil;
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
-(void)endExpensiveGift
{
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
#pragma mark ============scrolldelegate=============

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"滚动距离===%f=",scrollView.contentOffset.y);

    if (scrollView == _messageTable || scrollView == _videoCollectionV || scrollView == _picCollectionV) {
        if (_canScroll) {
            scrollView.contentOffset = CGPointZero;
        }
        if (scrollView.contentOffset.y <= 0) {
            _canScroll = YES;
            scrollView.contentOffset = CGPointZero;
        }
    }

    if (scrollView == _backScroll){
        // CGFloat bottomCellOffset = _window_width + 56  - statusbarHeight;
        CGFloat topRealHeight = 115;//(150/2+40)
        CGFloat bottomCellOffset = _window_width + topRealHeight - statusbarHeight;
        if (scrollView.contentOffset.y >= bottomCellOffset) {
            scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
            if (_canScroll) {
                _canScroll = NO;
                _zoneView.canScroll = YES;
            }
            //secondNavi.hidden = NO;
            [self chagescroll:YES];
        }else{
            if (!_canScroll) {//子视图没到顶部
                scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
            }
            //secondNavi.hidden = YES;
            [self chagescroll:NO];
        }
        secondNavi.alpha = scrollView.contentOffset.y/(_window_width + topRealHeight  - statusbarHeight);

    }else{
        if (scrollView.contentOffset.y<0) {
            [self isscrolltop];
        }
    }
    if (playerImgview){
        if (pageControl.currentPage == 0 && secondNavi.alpha == 0 && scrollView.contentOffset.y <= 0) {
          
            //[self pauseclick:NO];
            if (!self.player.currentPlayerManager.isPlaying) {
                
               [self playerPlay];
            }
        }else if(secondNavi.alpha == 1){
            //[self pauseclick:YES];
            [self playerStop];
        }
    }
   
}
- (void)changeScrollStatus {
    _canScroll = YES;
    // 重要:子视图一定是canScroll = NO
    _zoneView.canScroll = NO;
}
-(void)isscrolltop{
    // [_backScroll setContentOffset:CGPointZero animated:YES];
}
-(void)chagescroll:(BOOL)isscroll{
//    _messageTable.scrollEnabled = isscroll;
//    _videoCollectionV.scrollEnabled = isscroll;
//    _picCollectionV.scrollEnabled = isscroll;
//    [_zoneView isscroll:isscroll];
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if(decelerate == NO){
//
//       [self scrollViewDidEndDecelerating:scrollView];
//
//    }
//}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == topScroll) {
        pageControl.currentPage = scrollView.contentOffset.x/_window_width;
        if (playerImgview) {
            if (pageControl.currentPage == 0) {
              
                //[self pauseclick:NO];
                
                    [self playerPlay];
                
                
            }else{
                //[self pauseclick:YES];
                [self playerStop];
            }
        }
    }
    if (scrollView == bottomScrollV) {
        int i = scrollView.contentOffset.x/_window_width;
        UIButton *btn = segmentBtnArray[i];
        moveLine.centerX = btn.centerX;
        for (UIButton *bttnn in segmentBtnArray) {
            if (bttnn == btn) {
                bttnn.selected = YES;
            }else{
                bttnn.selected = NO;
            }
        }
    }
//    if (scrollView == _backScroll) {
//        if (_backScroll.contentOffset.y == 0 && pageControl.currentPage == 0) {
//            //[self pauseclick:NO];
//            [self playerPlay];
//        }else{
//            //[self pauseclick:YES];
//            [self playerStop];
//        }
//    }
}


#pragma mark ============发起通话=============
- (void)sendCallwithType:(NSString *)type{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self callllllllllType:type];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self callllllllllType:type];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
                return;
            }

        }
    }else{
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian:type];
                    }else{
                        [MBProgressHUD showError:YZMsg(@"未允许摄像头权限，不能视频通话")];
                    }
                });

            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian:type];
            }else{
                [MBProgressHUD showError:YZMsg(@"请前往设置中打开摄像头权限")];
            }
        }
    }

    //视频
    

}
- (void)checkYuyinQuanxian:(NSString *)type{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self callllllllllType:type];
                }else{
                    [MBProgressHUD showError:YZMsg(@"未允许麦克风权限，不能语音通话")];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self callllllllllType:type];
        }else{
            [MBProgressHUD showError:YZMsg(@"请前往设置中打开麦克风权限")];
            return;
        }
    }
}
- (void)callllllllllType:(NSString *)type{
    WeakSelf;
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_liveDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    NSDictionary *dic = @{
                          @"liveuid":minstr([_liveDic valueForKey:@"id"]),
                          @"type":type,
                          @"sign":sign
                          };
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
//            TIMConversation *conversation = [[TIMManager sharedInstance]
//                                             getConversation:TIM_C2C
//                                             receiver:minstr([_liveDic valueForKey:@"id"])];
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
            [[YBImManager shareInstance]sendV2CustomMsg:custom_elem andReceiver:minstr([_liveDic valueForKey:@"id"]) complete:^(BOOL isSuccess, V2TIMMessage *sendMsg, NSString *desc) {
                if(isSuccess){
                    NSLog(@"SendMsg Succ");
                    [weakSelf showWaitView:infoDic andType:type];
                }else{
                    NSLog(@"SendMsg Failed:%d->%@", code, desc);
                   [MBProgressHUD showError:YZMsg(@"消息发送失败")];
                   [weakSelf sendMessageFaild:infoDic andType:type];                }
            }];

//            TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
//            [custom_elem setData:data];
//            TIMMessage * msg = [[TIMMessage alloc] init];
//            [msg addElem:custom_elem];
//            WeakSelf;
//            [conversation sendMessage:msg succ:^(){
//                NSLog(@"SendMsg Succ");
//                [weakSelf showWaitView:infoDic andType:type];
//            }fail:^(int code, NSString * err) {
//                NSLog(@"SendMsg Failed:%d->%@", code, err);
//                [MBProgressHUD showError:YZMsg(@"消息发送失败")];
//                [weakSelf sendMessageFaild:infoDic andType:type];
//            }];
            
            
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
    [muDic setObject:minstr([_liveDic valueForKey:@"id"]) forKey:@"id"];
    [muDic setObject:minstr([_liveDic valueForKey:@"avatar"]) forKey:@"avatar"];
    [muDic setObject:minstr([_liveDic valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
    [muDic setObject:minstr([_liveDic valueForKey:@"level_anchor"]) forKey:@"level_anchor"];
    [muDic setObject:minstr([_liveDic valueForKey:@"video_value"]) forKey:@"video_value"];
    [muDic setObject:minstr([_liveDic valueForKey:@"voice_value"]) forKey:@"voice_value"];

    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:navi animated:YES completion:nil];

}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_liveDic valueForKey:@"id"]),minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":minstr([_liveDic valueForKey:@"id"]),@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign,@"hangtype":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_liveDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":minstr([_liveDic valueForKey:@"id"]),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}
- (void)doliwugui{
    if([[YBYoungManager shareInstance] isOpenYoung]){
        [MBProgressHUD showError:YZMsg(@"青少年模式下该功能不能使用")];
        return;
    }
    GiftCabinetViewController *vc = [[GiftCabinetViewController alloc]init];
    vc.userID = minstr([_liveDic valueForKey:@"id"]);
    [[YBAppDelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)rightBtnClick{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:blackActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBlack];
    }];
    [sureAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];

    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:YZMsg(@"举报") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doReport];
    }];
    [reportAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:reportAction];

    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];

    [self presentViewController:alertContro animated:YES completion:nil];

}




- (void)topBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in segmentBtnArray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        moveLine.centerX = sender.centerX;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAllSound" object:nil];
    [bottomScrollV setContentOffset:CGPointMake(_window_width*(sender.tag-1957), 0)];
}
- (void)pullVideoList{
    [YBToolClass postNetworkWithUrl:@"Video.GetHomeVideo" andParameter:@{@"p":@(videoPage),@"liveuid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        [MBProgressHUD hideHUD];
        if (code == 0) {
            if (videoPage == 1) {
                [_videoArray removeAllObjects];
                [allVideoArr removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                videoModel *model = [[videoModel alloc]initWithDic:dic];
                [_videoArray addObject:model];
                [allVideoArr addObject:dic];
            }
            [_videoCollectionV reloadData];
            if (_videoArray.count == 0) {
                videoNothingView.hidden = NO;
            }else{
                videoNothingView.hidden = YES;
            }

        }
    } fail:^{
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        
    }];
}
- (void)pullPicList{
    [YBToolClass postNetworkWithUrl:@"Photo.getHomePhoto" andParameter:@{@"p":@(picPage),@"liveuid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_picCollectionV.mj_footer endRefreshing];
        [_picCollectionV.mj_header endRefreshing];
        [MBProgressHUD hideHUD];

        if (code == 0) {
            if (picPage == 1) {
                [_videoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                picModel *model = [[picModel alloc]initWithDic:dic];
                [_picArray addObject:model];
            }
            [_picCollectionV reloadData];
            if (_picArray.count == 0) {
                picNothingView.hidden = NO;
            }else{
                picNothingView.hidden = YES;
            }
        }
    } fail:^{
        [_picCollectionV.mj_footer endRefreshing];
        [_picCollectionV.mj_header endRefreshing];
        
    }];


}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _videoCollectionV) {
        return _videoArray.count;
    }else{
        return _picArray.count;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (collectionView == _picCollectionV) {
        picModel *model = _picArray[indexPath.row];
        picShowCell *cell = (picShowCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([model.isprivate isEqual:@"1"] && [model.cansee isEqual:@"0"]) {
            if([[YBYoungManager shareInstance] isOpenYoung]){
                
                UIAlertController *showAlert = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"青少年模式下，不能观看付费照片") preferredStyle:UIAlertControllerStyleAlert];
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
                return;
            }else{
                [self showAlertView:[NSString stringWithFormat:@"%@%@%@%@",YZMsg(@"该照片为私密照片，需支付"),model.coin,[common name_coin],YZMsg(@"观看，开通VIP后可免费观看")] andIsVideo:NO andModel:model andPicCell:cell];
                return;

            }
        }
//        [self showBigPhoto:cell andModel:model];
        NSMutableArray *imgArr = [NSMutableArray array];
        for (picModel *model in _picArray) {
            [imgArr addObject:model.thumb];
        }
        YBScrollImageView *imgView = [[YBScrollImageView alloc] initWithImageArray:imgArr andIndex:indexPath.row andMine:NO isCanScrol:NO andBlock:^(NSArray * _Nonnull array) {
        }];
        [imgView hideDelete];
        [[UIApplication sharedApplication].keyWindow addSubview:imgView];

    }else{
        currentIndex = indexPath;
        videoDic =[[NSMutableDictionary alloc]initWithDictionary:allVideoArr[indexPath.row]];
        videoModel *model = _videoArray[indexPath.row];
        if ([model.isprivate isEqual:@"1"] && [model.cansee isEqual:@"0"]) {
            
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
                return;
            }else{
                [self showAlertView:[NSString stringWithFormat:@"%@%@%@%@",YZMsg(@"该视频为私密视频，需支付"),model.coin,[common name_coin],YZMsg(@"观看，开通VIP后可免费观看")] andIsVideo:YES andModel:model andPicCell:nil];
                return;
            }
        }
        [self goLookVideo:model];
    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _videoCollectionV) {
        videoShowCell *cell = (videoShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"videoShowCELL" forIndexPath:indexPath];
        cell.stateL.text = YZMsg(@"审核中");
        videoModel *model = _videoArray[indexPath.row];
        cell.model = model;
        return cell;


    }else{
        picShowCell *cell = (picShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"picShowCELL" forIndexPath:indexPath];
        cell.stateL.text = YZMsg(@"审核中");
        picModel *model = _picArray[indexPath.row];
        cell.model = model;
        return cell;

    }
}
- (UICollectionView *)videoCollectionV{
    if (!_videoCollectionV) {

        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.itemSize = CGSizeMake((_window_width-40-4)/3, (_window_width-40-4)/3*1.33);
        flow.minimumLineSpacing = 2;
        flow.minimumInteritemSpacing = 2;
        flow.sectionInset = UIEdgeInsetsMake(2, 0,2, 0);
        
        _videoCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(_window_width+17, 10, _window_width-34, _window_height-64-60-statusbarHeight-ShowDiff-40-30-10) collectionViewLayout:flow];
        _videoCollectionV.backgroundColor = [UIColor clearColor];
        _videoCollectionV.delegate   = self;
        _videoCollectionV.dataSource = self;
       
        // _videoCollectionV.scrollEnabled = NO;
        _videoCollectionV.showsHorizontalScrollIndicator = NO;
        _videoCollectionV.showsVerticalScrollIndicator = NO;
        [_videoCollectionV registerNib:[UINib nibWithNibName:@"videoShowCell" bundle:nil] forCellWithReuseIdentifier:@"videoShowCELL"];
        
        _videoCollectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            videoPage ++;
            [self pullVideoList];
        }];
        videoNothingView = [[UIView alloc]initWithFrame:CGRectMake(0, _videoCollectionV.height/2-100, _videoCollectionV.width, 100)];
        videoNothingView.hidden = YES;
        [_videoCollectionV addSubview:videoNothingView];
        UIImageView *nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(videoNothingView.width/2-40, 0, 80, 80)];
        nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
        [videoNothingView addSubview:nothingImgV];
        UILabel *nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImgV.bottom, _window_width, 20)];
        nothingTitleL.font = [UIFont systemFontOfSize:11];
        nothingTitleL.textColor = color96;
        nothingTitleL.textAlignment = NSTextAlignmentCenter;
        nothingTitleL.text = YZMsg(@"TA还没有上传过视频");
        [videoNothingView addSubview:nothingTitleL];

    }
    return _videoCollectionV;
}
- (UICollectionView *)picCollectionV{
    if (!_picCollectionV) {
        _picArray = [NSMutableArray array];
        picPage = 1;

        UICollectionViewFlowLayout *flowwwww = [[UICollectionViewFlowLayout alloc]init];
        flowwwww.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowwwww.itemSize = CGSizeMake((_window_width-40-4)/3, (_window_width-40-4)/3*1.33); //CGSizeMake((_window_width-30-4)/3, (_window_width-30-4)/3*1.33);
        flowwwww.minimumLineSpacing = 2;
        flowwwww.minimumInteritemSpacing = 2;
        flowwwww.sectionInset = UIEdgeInsetsMake(2, 0,2, 0);
        
        _picCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(_window_width*2+15, 10, _window_width-34, _window_height-64-60-statusbarHeight-ShowDiff-40-30-10) collectionViewLayout:flowwwww];

//        _picCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(_window_width*2+15, 10, _window_width-30, _window_height-64-60-statusbarHeight-ShowDiff-40-10) collectionViewLayout:flowwwww];
        _picCollectionV.backgroundColor = [UIColor whiteColor];
        _picCollectionV.delegate   = self;
        _picCollectionV.dataSource = self;
        //_picCollectionV.scrollEnabled = NO;
        _picCollectionV.showsHorizontalScrollIndicator = NO;
        _picCollectionV.showsVerticalScrollIndicator = NO;
        [_picCollectionV registerNib:[UINib nibWithNibName:@"picShowCell" bundle:nil] forCellWithReuseIdentifier:@"picShowCELL"];
        _picCollectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            picPage ++;
            [self pullPicList];
        }];
        picNothingView = [[UIView alloc]initWithFrame:CGRectMake(0, _videoCollectionV.height/2-100, _videoCollectionV.width, 100)];
        picNothingView.hidden = YES;
        [_picCollectionV addSubview:picNothingView];
        UIImageView *nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(videoNothingView.width/2-40, 0, 80, 80)];
        nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
        [picNothingView addSubview:nothingImgV];
        UILabel *nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImgV.bottom, _window_width, 20)];
        nothingTitleL.font = [UIFont systemFontOfSize:11];
        nothingTitleL.textColor = color96;
        nothingTitleL.textAlignment = NSTextAlignmentCenter;
        nothingTitleL.text = YZMsg(@"TA还没有上传过照片");
        [picNothingView addSubview:nothingTitleL];


    }
    return _picCollectionV;
}

- (void)showAlertView:(NSString *)message andIsVideo:(BOOL)isvideo andModel:(id)model andPicCell:(picShowCell *)cell{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:message andButtonArrays:@[YZMsg(@"开通会员"),YZMsg(@"付费观看")] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf doPayWithIsVideo:isvideo andModel:model andPicCell:cell];
        }else if (type == 1) {
            [weakSelf doVIP];
        }
        
        [weakSelf removeAlertView];
        
    }];
    [self.view addSubview:alert];
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
        NSDictionary *newDic = @{@"cansee":@"1"};
        [videoDic addEntriesFromDictionary:newDic];
        [allVideoArr replaceObjectAtIndex:currentIndex.row withObject:videoDic];

    };
    [[YBAppDelegate sharedAppDelegate] pushViewController:vip animated:YES];
}

- (void)addLookPicViews:(picModel *)model{
    NSString *sign = [YBToolClass sortString:@{@"uid":[Config getOwnID],@"photoid":model.picID}];

    [YBToolClass postNetworkWithUrl:@"Photo.addView" andParameter:@{@"photoid":model.picID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            model.views = minstr([dic valueForKey:@"nums"]);
            [_picCollectionV reloadData];
        }
    } fail:^{
        
    }];

}
- (void)doPayWithIsVideo:(BOOL)isvideo andModel:(id)model andPicCell:(picShowCell *)cell{
    NSString *url;
    videoModel *vModel;
    picModel *pModel;
    if (isvideo) {
        vModel = model;
        url = [NSString stringWithFormat:@"Video.BuyVideo&videoid=%@",vModel.videoID];
    }else{
        pModel = model;
        url = [NSString stringWithFormat:@"Photo.buyPhoto&photoid=%@",pModel.picID];
    }
    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if (isvideo) {
                vModel.cansee = @"1";
                NSDictionary *infoDic = [info firstObject];
                vModel.href = minstr([infoDic valueForKey:@"href"]);
                [self goLookVideo:vModel];
            }else{
                pModel.cansee = @"1";
                [self showBigPhoto:cell andModel:pModel];
            }
        }else if (code == 1005){
            [self pushCoinV];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}
- (void)showBigPhoto:(picShowCell *)cell andModel:(picModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        YBImageView *sss = [[YBImageView alloc]initWithImgView:cell.thumbImgV];
        [[UIApplication sharedApplication].delegate.window addSubview:sss];
    });
    [self addLookPicViews:model];
}
- (void)goLookVideo:(videoModel *)model{
    
//    if ([model.isprivate isEqual:@"1"] && ![minstr([model.userDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
    if ([model.cansee isEqual:@"0"]) {

        NSString *msgTitle = [NSString stringWithFormat:YZMsg(@"该视频为私密视频，需支付%@%@观看\n开通VIP后可免费观看"),model.coin,[common name_coin]];

        WeakSelf;
        alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:msgTitle andButtonArrays:@[YZMsg(@"开通会员"),YZMsg(@"付费观看")] andButtonClick:^(int type) {
            if (type == 2) {
                
                NSString *url  = [NSString stringWithFormat:@"Video.BuyVideo&videoid=%@",model.videoID];
                [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                    if (code == 0) {
                        NSDictionary *infoDic = [info firstObject];
                        NSDictionary *newDic = @{@"cansee":@"1",@"href":minstr([infoDic valueForKey:@"href"])};
                        [videoDic addEntriesFromDictionary:newDic];
                        [allVideoArr replaceObjectAtIndex:currentIndex.row withObject:videoDic];
//
                        YBLookVideoVC *ybLook = [[YBLookVideoVC alloc]init];
                        ybLook.pushPlayIndex = currentIndex.item;
                        NSString *baseUrl =  [NSString stringWithFormat:@"Video.GetHomeVideo&liveuid=%@",minstr([_liveDic valueForKey:@"id"])];
                        ybLook.sourceBaseUrl  =baseUrl;// minstr([infoDic valueForKey:@"href"]);
                        ybLook.videoList = allVideoArr;
                        ybLook.pages =page;
                        [[YBAppDelegate sharedAppDelegate] pushViewController:ybLook animated:YES];

                    }else if (code == 1005){
                        [weakSelf doVIP];
                    }
                    [MBProgressHUD showError:msg];
                } fail:^{
                    
                }];

                
                
            }else if (type == 1) {
                [weakSelf doVIP];
            }
            
            [weakSelf removeAlertView];
            
        }];
        [self.view addSubview:alert];

    }else{
        NSDictionary *newDic = @{@"cansee":@"1"};
        [videoDic addEntriesFromDictionary:newDic];
        [allVideoArr replaceObjectAtIndex:currentIndex.row withObject:videoDic];

        YBLookVideoVC *ybLook = [[YBLookVideoVC alloc]init];
        ybLook.pushPlayIndex = currentIndex.item;
        NSString *baseUrl =  [NSString stringWithFormat:@"Video.GetHomeVideo&liveuid=%@",minstr([_liveDic valueForKey:@"id"])];
        ybLook.sourceBaseUrl  =baseUrl;
        ybLook.videoList = allVideoArr;
        ybLook.pages =page;
        [[YBAppDelegate sharedAppDelegate] pushViewController:ybLook animated:YES];

    }
}

//举报
-(void)doReport{
    ReportUserVC *report = [[ReportUserVC alloc]init];
    report.touid =minstr([_liveDic valueForKey:@"id"]);
    [[YBAppDelegate sharedAppDelegate]pushViewController:report animated:YES];
}
- (void)setBlack{
    [YBToolClass postNetworkWithUrl:@"User.SetBlack" andParameter:@{@"touid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isblack"]) isEqual:@"1"]) {
                blackActionTitle = YZMsg(@"解除拉黑");
            }else{
                blackActionTitle = YZMsg(@"拉黑");
            }
            NSMutableDictionary * a=[NSMutableDictionary dictionaryWithDictionary:_liveDic];

            [a setValue:minstr([infoDic valueForKey:@"isblack"]) forKey:@"isblack"];
            _liveDic = a;
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}

- (void)playerPlay{
    WeakSelf;
    self.player.assetURL =[NSURL URLWithString:[[topImgArr firstObject] valueForKey:@"href"]];

    //功能
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"准备");
    };

    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        NSLog(@"结束");
       
        [weakSelf.player.currentPlayerManager replay];
    };
//    self.player.assetURLs = self.videoUrls;

//    [playerImgview jp_playVideoWithURL:[NSURL URLWithString:[[topImgArr firstObject] valueForKey:@"href"]] bufferingIndicator:nil controlView:nil progressView:nil configuration:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
//                playerModel.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//
//    }];
}
-(void)playerStop {
   
  // [[JPVideoPlayerManager sharedManager] pause];
    [self.player stop];
 
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAllSound" object:nil];
    [self playerStop];
    [self playFinished:nil];

}
- (void)viewWillAppear:(BOOL)animated{
    if (playerImgview) {
        if (_backScroll.contentOffset.y == 0 && pageControl.currentPage == 0) {
            [self playerPlay];
        }else{
            [self playerStop];
        }
    }

}

-(CGSize)imagesizeurl:(NSString *)urlStr{
    NSURL *imageUrl = [NSURL URLWithString:urlStr];
     NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
     UIImage *image = [UIImage imageWithData:imageData];
    return image.size;
}

#pragma mark ==播放音频===
-(void)audioImgClick{
    WeakSelf;
    int floattotal = self.voicetime;
    
    islisten = !islisten;
    if (islisten) {
        voiceEnd = NO;
        if (_voicePlayer) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
            [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
            [_voicePlayer removeObserver:self forKeyPath:@"status"];
            [_voicePlayer pause];
            _voicePlayer = nil;
        }else{
        }
        NSURL * url;
//        if (isRecordVoice) {
//            url= [NSURL fileURLWithPath:self.audioPath isDirectory:NO];
//        }else{
            url = [NSURL URLWithString:minstr([_liveDic valueForKey:@"audio"])];
//        }
        
        AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
        _voicePlayer = [[AVPlayer alloc]initWithPlayerItem:songItem];
        [_voicePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        WeakSelf;
        _playbackTimeObserver = [_voicePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            //当前播放的时间
            CGFloat floatcurrent = CMTimeGetSeconds(time);
            NSLog(@"floatcurrent = %.1f",floatcurrent);
            //总时间
            
            weakSelf.voiceTimeLb.text =[NSString stringWithFormat:@"%.0fs",(floattotal-floatcurrent) > 0 ? (floattotal-floatcurrent) : 0];
            
        }];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        _voicePlayer.volume = 1;

        [_voicePlayer play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        
    }else{
        _vioceImgNormal.hidden = NO;
        
        _animationView.hidden = YES;
        if (_voicePlayer) {
            [_voicePlayer pause];
        }
    }

}

- (void)playFinished:(NSNotification *)not{

    voiceEnd = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
    [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
    [_voicePlayer removeObserver:self forKeyPath:@"status"];
    [_voicePlayer pause];
    _voicePlayer = nil;
    
    _animationView.hidden = YES;
    _voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
    _vioceImgNormal.hidden = NO;
    
}
- (void)appDidEnterBackground:(NSNotification *)not{
    if (_voicePlayer) {
        [_voicePlayer pause];
        [self playFinished:not];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"----播放失败----------");
                [MBProgressHUD showError:YZMsg(@"播放失败")];
                voiceEnd = NO;
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                voiceEnd = YES;
                _vioceImgNormal.hidden = YES;
                _animationView.hidden = NO;
            }
                break;
            case AVPlayerStatusFailed:
            {
                [MBProgressHUD showError:YZMsg(@"播放失败")];
                voiceEnd = NO;
            }
                break;
        }
    }
}

-(void)voicedaojishi{
    oldVoiceTime--;
    _voiceTimeLb.text = [NSString stringWithFormat:@"%ds",oldVoiceTime];
}

-(void)timerPause{
    [voicetimer setFireDate:[NSDate distantFuture]];
}
-(void)timerBegin{
    [voicetimer setFireDate:[NSDate date]];
}
-(void)timerEnd{
    [voicetimer invalidate];
}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//
//    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
//    CGPoint pos = [pan velocityInView:pan.view];
//        NSLog(@"=-=-=-=-=-=-======:%f",pos.y);
//    if (pos.y > 0) {
//        if (scrollView.contentOffset.y<0) {
//            [self isscrolltop];
//        }
//    return YES;
//    }
//    }
//
//    return NO;
//}


@end
