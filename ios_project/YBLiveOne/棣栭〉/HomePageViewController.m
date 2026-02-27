//
//  HomePageViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "HomePageViewController.h"
#import "RecommendViewController.h"
#import "FollowViewController.h"
#import "NearByViewController.h"
#import "SearchViewController.h"
#import "UIImage+GIF.h"
#import "InvitationView.h"
#import "HomeNewViewController.h"
#import "AnchorViewController.h"
#import "YBSayHelloView.h"
#import "UserListViewController.h"
#import "ChatPageViewController.h"
#import "HomeVideoVC.h"
#import "OpenInstallSDK.h"
#import "RankVC.h"
#import "YBLiveVC.h"
#import <TYTabPagerBar.h>
#import <TYTabPagerController.h>
#import "YBLiveListVC.h"
#import "Loginbonus.h"  //每天第一次登录

@interface HomePageViewController ()<TYTabPagerBarDelegate,TYTabPagerBarDataSource,TYPagerControllerDelegate,TYPagerControllerDataSource,FirstLogDelegate>
{
    RecommendViewController *recommend;
    UserListViewController *userlist;
    UIButton *screenBtn;
    UIButton *searchBTN;
    InvitationView *invitationV;
    YBSayHelloView *sayhelloView;
    
    NSString *titleStr;
    NSDictionary *checkinfodic;
    
    UIView *_topRightSubView; // 搜索、排行、直播父视图
    UIView *searchView;
    UIButton *rankBtn;
    UIButton *_liveBtn;
    
    /********* firstLV -> ************/
    Loginbonus *firstLV;
    NSString *bonus_switch;
    NSString *bonus_day;
    NSArray  *bonus_list;
    NSString *dayCount;
    NSMutableArray  *coins;
    NSMutableArray  *days;

}
@property(nonatomic,strong)UIView *topNavView;
@property(nonatomic,strong)TYTabPagerBar *tabBar;
@property(nonatomic,strong)TYPagerController *pagerController;
@property(nonatomic,strong)NSArray *infoArrays;
@property (nonatomic,strong) CABasicAnimation *animation;

@end

@implementation HomePageViewController
- (void)checkAgent{
    [YBToolClass postNetworkWithUrl:@"Agent.Check" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            checkinfodic = [info firstObject];
           /*
            openinstall_switch  开关 0关 1开
            is_firstlogin 是否第一次登录   1 第一次登录
            isfill   是否填过邀请码  0未填。 1填过
            */
            if (![minstr([checkinfodic valueForKey:@"isfill"]) isEqual:@"1"] && [minstr([checkinfodic valueForKey:@"is_firstlogin"]) isEqual:@"1"]) {
                if ([minstr([checkinfodic valueForKey:@"openinstall_switch"]) isEqual:@"1"]) {
                    [self showCodeInstall];
                }else{
                    if ([minstr([checkinfodic valueForKey:@"ismust"]) isEqual:@"1"]) {
                        [Config saveRegisterlogin:@"0"];
                        [self showInvitationView:YES];
                    }else{
                        if ([[Config getIsRegisterlogin] isEqual:@"1"]) {
                            [Config saveRegisterlogin:@"0"];
                            [self showInvitationView:NO];
                        }
                    }
                }
            }
        }
        if ([[Config getIsrecomment] isEqual:@"1"]) {
            //打招呼
            [self sayhelloclick];
        }
    } fail:^{
        if ([[Config getIsrecomment] isEqual:@"1"]) {
            //打招呼
            [self sayhelloclick];
        }
    }];
}

-(void)showCodeInstall{
    WeakSelf;
    [[OpenInstallSDK defaultManager] getInstallParmsCompleted:^(OpeninstallData*_Nullable appData) {
        //在主线程中回调
        if (appData.data) {//(动态安装参数)
           //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
            [weakSelf uploadInvitationV:minstr([appData.data valueForKey:@"code"])];
            [Config saveRegisterlogin:@"0"];
        }else {
            if ([minstr([checkinfodic valueForKey:@"ismust"]) isEqual:@"1"]) {
                [Config saveRegisterlogin:@"0"];
                [self showInvitationView:YES];
            }else{
                if ([[Config getIsRegisterlogin] isEqual:@"1"]) {
                    [Config saveRegisterlogin:@"0"];
                    [self showInvitationView:NO];
                }
            }
        }
        if (appData.channelCode) {//(通过渠道链接或二维码安装会返回渠道编号)
            //e.g.可自己统计渠道相关数据等
        }
        NSLog(@"OpenInstallSDK:\n动态参数：%@;\n渠道编号：%@",appData.data,appData.channelCode);
    }];
}
-(void)uploadInvitationV:(NSString *)codeStr{
    [YBToolClass postNetworkWithUrl:@"Agent.SetAgent" andParameter:@{@"code":codeStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
//            [self hideSelf];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}
-(void)sayhelloclick{
    NSDictionary *dics = @{
        @"p":@"1",
    };
    [YBToolClass postNetworkWithUrl:@"User.getRecommendlist" andParameter:dics success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [Config saveRrecomment:@"0"];
        if (code == 0) {
            NSLog(@"获取参数==%@",info);
            NSArray *modelarray = info[@"recommendlist"];
            if (modelarray.count > 0) {
                [self showSayHView:info];
            }
        }
       
        } fail:^{
            
        }];
}
- (void)showInvitationView:(BOOL)isForce{
    invitationV = [[InvitationView alloc]initWithType:isForce];
    [[UIApplication sharedApplication].delegate.window addSubview:invitationV];
}
-(void)showSayHView:(NSDictionary *)dics{
    sayhelloView = [[YBSayHelloView alloc] init:dics];
    [[UIApplication sharedApplication].delegate.window addSubview:sayhelloView];
}
- (void)pipeiBtnClick{
    NSArray * sss = _tabbarContro.tabBar.subviews;
    for (UIView *tabbarbutton in sss) {
        for (UIView *view in tabbarbutton.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                
                [view removeAllSubViews];
            }
        }
    }
    [self showTabBar];
    [_tabbarContro setSelectedIndex:1];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if([[Config getIsauth] isEqual:@"1"]){
        [self changeLiveBtnShow:YES];
    }else{
        [self changeLiveBtnShow:NO];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topNavView];
    self.infoArrays = [NSArray arrayWithObjects:YZMsg(@"聊场"),YZMsg(@"视频"),YZMsg(@"直播"), nil];
    [_tabBar reloadData];
    [_pagerController reloadData];
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    if(!showLite){
        [self checkAgent];
    }
    // [self sayhelloclick];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openYongnotification) name:@"openYoung_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeYongnotification) name:@"closeYoung_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConfigData) name:@"HOMECONFIGDATA" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAgent) name:@"HomeCheckAgent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickLiveBtn) name:@"Golive" object:nil];

    // 进入全功能模式按钮
    if(showLite){
        [[YBLiteMode shareInstance] showLiteAllBtn];
    }
    //每天第一次登录
    if ([[Config getOwnID]intValue] < 0 ) {
    }else{
        [self pullInternet];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pullInternet) name:@"showBonus" object:nil];
    
}
/**********************每天第一次登录-->>**********************/
-(void)pullInternet {
    [YBToolClass postNetworkWithUrl:@"User.Bonus" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSArray *infos = info;
            bonus_switch = [NSString stringWithFormat:@"%@",[[infos lastObject] valueForKey:@"bonus_switch"]];
            bonus_day = [[infos lastObject] valueForKey:@"bonus_day"];
            bonus_list = [[infos lastObject] valueForKey:@"bonus_list"];
            
            //测试
            //bonus_day = testDay;
            
            int day = [bonus_day intValue];
            dayCount = minstr([[infos lastObject] valueForKey:@"count_day"]);
            if ([[YBYoungManager shareInstance]isOpenYoung]) {
                
            }else{
                if ([bonus_switch isEqual:@"1"] && day > 0 ) {
                    [self firstLog];
                }
            }
        }
    } fail:^{
        
    }];
}
-(void)firstLog{

    firstLV = [[Loginbonus alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)AndNSArray:bonus_list AndDay:bonus_day andDayCount:dayCount];
    firstLV.tag = 100099;
    firstLV.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:firstLV];
}
#pragma mark - 代理  动画结束释放空视图
-(void)removeView:(NSDictionary*)dic{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:100099]removeFromSuperview];
//    [firstLV removeFromSuperview];
    firstLV = nil;
}


-(void)openYongnotification{
    // 青少年模式只处理排行榜
    // [self changeLiveBtnShow:NO];
    [self changeRankBtnShow:NO];
}
-(void)closeYongnotification{
    if(![YBToolClass isUp]){
        if([[Config getIsauth] isEqual:@"1"]){
            [self changeLiveBtnShow:YES];
        }
        if(![[common getLeaderboard_switch] isEqual:@"0"]){
            [self changeRankBtnShow:YES];
        }
    }
}
-(void)getConfigData{
    if(![[common getLeaderboard_switch] isEqual:@"0"] && ![[YBYoungManager shareInstance]isOpenYoung] && ![YBToolClass isUp]){
        [self changeRankBtnShow:YES];
    }else{
        [self changeRankBtnShow:NO];
    }
}
// 改变现实状态
-(void)changeLiveBtnShow:(BOOL)isShow {
    _liveBtn.hidden = !isShow;
    CGFloat btn_width = 30;
    CGFloat btn_right = -10;
    if(!isShow){
        btn_width = 0;
        //btn_right = 0;
    }
    [_liveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(btn_width);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(_tabBar.mas_centerY);
        make.right.equalTo(_topRightSubView.mas_right).offset(btn_right);
    }];
}
-(void)changeRankBtnShow:(BOOL)isShow {
    rankBtn.hidden = !isShow;
    CGFloat btn_width = 30;
    CGFloat btn_right = -5;
    if(!isShow){
        btn_width = 0;
        btn_right = 0;
    }
    [rankBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(btn_width);
        make.height.centerY.mas_equalTo(_liveBtn);
        make.right.equalTo(_liveBtn.mas_left).offset(btn_right);
    }];
}
// 开播
-(void)clickLiveBtn {
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Zlive.getSDK" andParameter:@{} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0){
            NSDictionary *infoDic = [info firstObject];
            YBLiveVC *liveVC = [[YBLiveVC alloc]init];
            liveVC.live_isban = minstr([infoDic valueForKey:@"live_isban"]);
            liveVC.liveban_title = minstr([infoDic valueForKey:@"liveban_title"]);
            liveVC.pushSettingDic = [infoDic valueForKey:@"ios"];
            [[YBAppDelegate sharedAppDelegate] pushViewController:liveVC animated:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
    
}
// 排行
-(void)rankBtnClick{
    RankVC *rank = [[RankVC alloc] init];
    rank.topIndex = 0;
    [[YBAppDelegate sharedAppDelegate] pushViewController:rank animated:YES];

}
// 搜索
- (void)search{
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        return;
    }
    SearchViewController *search = [[SearchViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:search animated:YES];
}

- (UIView *)topNavView{
    if(!_topNavView){
        _topNavView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
        _topNavView.backgroundColor = [UIColor whiteColor];
        TYTabPagerBar *tabBar = [[TYTabPagerBar alloc]init];
        tabBar.dataSource = self;
        tabBar.delegate = self;
        tabBar.layout.barStyle = TYPagerBarStyleProgressView;
        tabBar.layout.selectedTextColor = [UIColor blackColor];
        tabBar.layout.normalTextColor = [UIColor blackColor];
        tabBar.layout.selectedTextFont = [UIFont boldSystemFontOfSize:22];
        tabBar.layout.normalTextFont = [UIFont boldSystemFontOfSize:19];
        tabBar.layout.progressColor = normalLightColors;
        tabBar.layout.progressHeight = 10;
        tabBar.layout.progressRadius = 5;
        tabBar.layout.progressHorEdging = 10;
        tabBar.layout.progressVerEdging = 10;
        tabBar.layout.cellWidth = 0;
        tabBar.layout.cellSpacing = 0;
        tabBar.backgroundColor = UIColor.clearColor;
        [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
        [_topNavView addSubview:tabBar];
        [tabBar.collectionView sendSubviewToBack:tabBar.progressView];
        tabBar.progressView.layer.zPosition = -1;
        _tabBar = tabBar;
        TYPagerController *pagerController = [[TYPagerController alloc] init];
        pagerController.dataSource = self;
        pagerController.delegate = self;
        pagerController.view.backgroundColor = [UIColor clearColor];
        [self addChildViewController:pagerController];
        [self.view addSubview:pagerController.view];
        _pagerController = pagerController;
        
        _tabBar.frame = CGRectMake(0,20+statusbarHeight,_window_width-185,44);
        _pagerController.view.frame = CGRectMake(0, 0, _window_width, _window_height);
        
        BOOL showLite = [[YBLiteMode shareInstance] checkShow];
        // 基本模式禁止滚动
        if(showLite){
            _pagerController.scrollView.scrollEnabled = NO;
        }
        
        //开播 排行、搜索
        _topRightSubView = [[UIView alloc]init];
        [_topNavView addSubview:_topRightSubView];
        [_topRightSubView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerY.equalTo(_tabBar);
            make.right.equalTo(_topNavView.mas_right);
            make.left.equalTo(_tabBar.mas_right);
        }];
        
        _liveBtn = [UIButton buttonWithType:0];
        [_liveBtn setImage:[UIImage imageNamed:@"home_live"] forState:0];
        [_liveBtn addTarget:self action:@selector(clickLiveBtn) forControlEvents:UIControlEventTouchUpInside];
        [_topRightSubView addSubview:_liveBtn];
        [_liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.centerY.equalTo(_tabBar.mas_centerY);
            make.right.equalTo(_topRightSubView.mas_right).offset(-10);
        }];
        
        rankBtn = [UIButton buttonWithType:0];
        //rankBtn.frame = CGRectMake(_window_width-40, 30+statusbarHeight, 26, 26);
        [rankBtn setImage:[UIImage imageNamed:@"home_rank"] forState:0];
        [rankBtn addTarget:self action:@selector(rankBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_topRightSubView addSubview:rankBtn];
        [rankBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.mas_equalTo(_liveBtn);
            make.right.equalTo(_liveBtn.mas_left).offset(-5);
        }];
        
        searchView = [[UIView alloc]init];
        //searchView.frame = CGRectMake(_window_width-145-40, 30 +statusbarHeight, 131, 26);
        searchView.backgroundColor = RGBA(238,238,238,1);
        searchView.layer.cornerRadius = 13;
        searchView.layer.masksToBounds = YES;
        [_topRightSubView addSubview:searchView];
        [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.width.mas_equalTo(75);
            make.height.mas_equalTo(26);
            make.centerY.equalTo(_liveBtn);
            make.right.equalTo(rankBtn.mas_left).offset(-10);
        }];

        UIImageView *searchImg = [[UIImageView alloc]init];
        searchImg.image = [UIImage imageNamed:@"home_search"];
        searchImg.contentMode = UIViewContentModeScaleAspectFit;
        [searchView addSubview:searchImg];
        [searchImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(searchView).offset(12);
            make.centerY.equalTo(searchView);
            make.width.height.mas_equalTo(16);
        }];
        
        UILabel *searchLb = [[UILabel alloc]init];
        searchLb.font = [UIFont systemFontOfSize:14];
        searchLb.text = YZMsg(@"搜索");
        searchLb.textColor = UIColor.grayColor;
        [searchView addSubview:searchLb];
        [searchLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(searchImg.mas_right).offset(5);
            make.centerY.equalTo(searchImg.mas_centerY);
            make.right.equalTo(searchView.mas_right).offset(-12);
        }];
        
        UIButton *searchBtn =[UIButton buttonWithType:0];
        [searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
        [searchView addSubview:searchBtn];
        [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(searchView);
        }];
        
        if([[Config getIsauth] isEqual:@"1"]){
            [self changeLiveBtnShow:YES];
        }else{
            [self changeLiveBtnShow:NO];
        }
        if([YBToolClass isUp]){
            [self changeLiveBtnShow:NO];
            [self changeRankBtnShow:NO];
        }
    }
    return _topNavView;
}


#pragma mark - TYTabPagerBarDataSource
- (NSInteger)numberOfItemsInPagerTabBar {
    return self.infoArrays.count;
}
- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = _infoArrays[index];
    return cell;
}

#pragma mark - TYTabPagerBarDelegate
- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = _infoArrays[index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [_pagerController scrollToControllerAtIndex:index animate:YES];
}

#pragma mark - TYPagerControllerDataSource
- (NSInteger)numberOfControllersInPagerController {
    return _infoArrays.count;
}
- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    
    if (index == 0) {
        ChatPageViewController *chatPage = [[ChatPageViewController alloc]init];
        chatPage.pageView = _topNavView;
        return chatPage;
    }else if (index == 1){
        HomeVideoVC *video = [[HomeVideoVC alloc] init];
        video.pageView = _topNavView;
        return video;
    }else{
        YBLiveListVC *liveVC = [[YBLiveListVC alloc] init];
        liveVC.pageView = _topNavView;
        return liveVC;
    }
}

// transition from index to index with animated
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated{
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        [_pagerController scrollToControllerAtIndex:0 animate:NO];
        return;
    }
    
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
    
    [self showTabBar];
    NSLog(@"rk==>动画1：from:%ld-to:%ld",(long)fromIndex,(long)toIndex);
    
    if (_tabBar.curIndex == 1) {
        _topRightSubView.hidden = YES;
    }else{
        _topRightSubView.hidden = NO;
    }
}

// transition from index to index with progress
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress{
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
    
    [self showTabBar];
    NSLog(@"rk==>动画2：from:%ld-to:%ld",(long)fromIndex,(long)toIndex);
}

- (void)showTabBar {
    if (self.tabBarController.tabBar.hidden == NO){
        return;
    }
    _topNavView.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
}


@end
