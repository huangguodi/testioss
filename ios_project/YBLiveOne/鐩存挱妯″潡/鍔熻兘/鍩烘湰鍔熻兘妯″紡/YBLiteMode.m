//
//  YBLiteMode.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/23.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBLiteMode.h"

#import "AppDelegate.h"
#import "YBTabBarController.h"
#import "PreLoginVC.h"

@interface YBLiteMode()
{
    CGFloat _popWidth;
}

@property(nonatomic,assign)PageFrom pageFrom;

@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UILabel *titleL;
@property(nonatomic,strong)YYLabel *contentL;
@property(nonatomic,strong)UIButton *agreeBtn;          // 同意
@property(nonatomic,strong)UIButton *refuseBtn;         // 拒绝
@property(nonatomic,strong)UIButton *baseModeBtn;       // 不同意并进入基本模式
@property(nonatomic,strong)UIButton *baseDesBtn;        // 基本模式解释


@property(nonatomic,strong)UIButton *allFunBtn;         // 进入全功能模式

@end

@implementation YBLiteMode

static YBLiteMode *_singleton = nil;

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[super allocWithZone:NULL] init];
    });
    return _singleton;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch; {
    if ([touch.view isDescendantOfView:self.bgView]) {
        return NO;
    }
    return YES;
}
-(void)dissmissView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}
-(BOOL)checkShow; {

    NSString *baseStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"yb_base_mode_agree"];
    if([YBToolClass checkNull:baseStatus] || [baseStatus isEqual:@"0"]){
        return YES;
    }
    return NO;
}
-(void)showBaseModeAlert:(PageFrom)from; {
    _pageFrom = from;
    [self createUI];
    [self requesContent];
    [self netMonitoring];
}

-(void)createUI {
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    [[YBAppDelegate sharedAppDelegate].topViewController.view addSubview:self];
    /*
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissmissView)];
     tap.delegate = self;
     [self addGestureRecognizer:tap];
     */
    _popWidth = _window_width * 0.7;
    self.backgroundColor = RGB_COLOR(@"#000000", 0.4);
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = UIColor.whiteColor;
    _bgView.layer.cornerRadius = 10;
    _bgView.layer.masksToBounds = YES;
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_popWidth);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_centerY).multipliedBy(1.0);
    }];
    
    _titleL = [[UILabel alloc]init];
    _titleL.font = [UIFont boldSystemFontOfSize:15];
    _titleL.textColor = UIColor.blackColor;
    _titleL.numberOfLines = 0;
    [_bgView addSubview:_titleL];
    [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bgView);
        make.top.equalTo(_bgView.mas_top).offset(20);
        make.width.lessThanOrEqualTo(_bgView.mas_width).offset(-40);
    }];
    
    _contentL = [[YYLabel alloc]init];
    _contentL.numberOfLines = 0;
    _contentL.textColor = RGB_COLOR(@"#323232", 1);
    _contentL.font = SYS_Font(15);
    _contentL.preferredMaxLayoutWidth = _popWidth-30;
    [_bgView addSubview:_contentL];
    [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_bgView.mas_width).offset(-30);
        make.centerX.equalTo(_bgView);
        make.top.equalTo(_titleL.mas_bottom).offset(20);
    }];
    
    CGFloat btnHeight = 40;
    // 同意
    _agreeBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [_agreeBtn setTitle:YZMsg(@"同意") forState:0];
    _agreeBtn.titleLabel.font = SYS_Font(15);
    [_agreeBtn setTitleColor:RGB_COLOR(@"#ffffff", 1) forState:0];
    _agreeBtn.backgroundColor = normalColors;
    _agreeBtn.layer.cornerRadius = btnHeight/2;
    _agreeBtn.layer.masksToBounds = YES;
    [_agreeBtn addTarget:self action:@selector(clickAgreeBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_agreeBtn];
    [_agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_bgView.mas_width).offset(-30);
        make.height.mas_equalTo(btnHeight);
        make.top.equalTo(_contentL.mas_bottom).offset(20);
        make.centerX.equalTo(_bgView);
    }];
    
    // 不同意
    _refuseBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [_refuseBtn setTitle:YZMsg(@"不同意") forState:0];
    _refuseBtn.titleLabel.font = SYS_Font(15);
    [_refuseBtn setTitleColor:RGB_COLOR(@"#7d7d7d", 1) forState:0];
    _refuseBtn.backgroundColor = RGB_COLOR(@"#efefef", 1);
    _refuseBtn.layer.cornerRadius = btnHeight/2;
    _refuseBtn.layer.masksToBounds = YES;
    [_refuseBtn addTarget:self action:@selector(clickRefuseBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_refuseBtn];
    [_refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.height.equalTo(_agreeBtn);
        make.top.equalTo(_agreeBtn.mas_bottom).offset(10);
    }];
    
    // 不同意并进入基本模式
    _baseModeBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [_baseModeBtn setTitle:YZMsg(@"不同意并进入基本功能模式") forState:0];
    _baseModeBtn.titleLabel.font = SYS_Font(15);
    [_baseModeBtn setTitleColor:RGB_COLOR(@"#7d7d7d", 1) forState:0];
    _baseModeBtn.backgroundColor =  RGB_COLOR(@"#efefef", 1);;
    _baseModeBtn.layer.cornerRadius = btnHeight/2;
    _baseModeBtn.layer.masksToBounds = YES;
    [_baseModeBtn addTarget:self action:@selector(clickBaseModeBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_baseModeBtn];
    [_baseModeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.height.equalTo(_agreeBtn);
        make.top.equalTo(_refuseBtn.mas_bottom).offset(10);
    }];
    
    // 基本模式解释
    _baseDesBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [_baseDesBtn setTitle:YZMsg(@"什么是基本功能模式？") forState:0];
    _baseDesBtn.titleLabel.font = SYS_Font(13);
    [_baseDesBtn setTitleColor:RGB_COLOR(@"#7d7d7d", 1) forState:0];
    [_baseDesBtn addTarget:self action:@selector(clickDesBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_baseDesBtn];
    [_baseDesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.centerX.equalTo(_agreeBtn);
        make.top.equalTo(_baseModeBtn.mas_bottom).offset(10);
        make.bottom.equalTo(_bgView.mas_bottom).offset(-10);
    }];
    
    [self layoutBtns];
}
-(void)layoutBtns {
    
    if(_pageFrom == PageFrom_AppDelegate){
        _refuseBtn.hidden = YES;
        _baseModeBtn.hidden = _baseDesBtn.hidden = NO;
        [_refuseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(_agreeBtn);
            make.top.equalTo(_agreeBtn.mas_bottom);
            make.height.mas_equalTo(0);
        }];
        
    }else{
        _refuseBtn.hidden = NO;
        _baseModeBtn.hidden = _baseDesBtn.hidden = YES;
        [_baseModeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(_agreeBtn);
            make.top.equalTo(_refuseBtn.mas_bottom);
            make.height.mas_equalTo(0);
        }];
        [_baseDesBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(_agreeBtn);
            make.top.equalTo(_baseModeBtn.mas_bottom);
            make.height.mas_equalTo(0);
            make.bottom.equalTo(_bgView.mas_bottom).offset(-15);
        }];
    }
}
// 同意
-(void)clickAgreeBtn {
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"yb_base_mode_agree"];
    [self dissmissView];
    [self clearLiteAllBtn];
    if(_pageFrom == PageFrom_AppDelegate){
        if(self.liteEvent){
            self.liteEvent(1);
        }
    }else{
        // 去登录
        /*
        UIApplication *app =[UIApplication sharedApplication];
        AppDelegate *app2 = (AppDelegate *)app.delegate;
        PreLoginVC *login = [[PreLoginVC alloc]init];
        app2.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:login];
        */
        UIApplication *app =[UIApplication sharedApplication];
        AppDelegate *app2 = (AppDelegate *)app.delegate;
        NSString *uid = minstr([Config getOwnID]);
        if (uid && [uid integerValue] > 0) {
            if(!app2.ybtab){
                [YBToolClass needRegNot:YES];
                YBTabBarController *tabbar = [[YBTabBarController alloc] init];
                app2.ybtab = tabbar;
            }
            app2.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:app2.ybtab];
        }
        else{
            PreLoginVC *login = [[PreLoginVC alloc]init];
            app2.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:login];
        }
        
    }
    
}
// 不同意
-(void)clickRefuseBtn {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"yb_base_mode_agree"];
    [self dissmissView];
}
// 进入基本模式
-(void)clickBaseModeBtn {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"yb_base_mode_agree"];
    [self dissmissView];
    
    if(_pageFrom == PageFrom_AppDelegate){
        if(self.liteEvent){
            self.liteEvent(1);
        }
    }else{
        /*
        UIApplication *app =[UIApplication sharedApplication];
        AppDelegate *app2 = (AppDelegate *)app.delegate;
        [YBToolClass needRegNot:NO];
        YBTabBarController *tabbar = [[YBTabBarController alloc] init];
        app2.ybtab = tabbar;
        app2.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:app2.ybtab];
        */
        UIApplication *app =[UIApplication sharedApplication];
        AppDelegate *app2 = (AppDelegate *)app.delegate;
        NSString *uid = minstr([Config getOwnID]);
        if (uid && [uid integerValue] > 0) {
            if(!app2.ybtab){
                [YBToolClass needRegNot:YES];
                YBTabBarController *tabbar = [[YBTabBarController alloc] init];
                app2.ybtab = tabbar;
            }
            app2.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:app2.ybtab];
        }
        else{
            PreLoginVC *login = [[PreLoginVC alloc]init];
            app2.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:login];
        }
    }
}
// 解释说明
-(void)clickDesBtn {
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingFormat:@"/appapi/page/detail?id=12"];
    paths = [paths stringByAppendingFormat:@"&lang=%@",[RookieTools serviceLang]];
    VC.urls = paths;
    [[YBAppDelegate sharedAppDelegate] pushViewController:VC animated:YES];
}

#pragma mark - 网络
-(void)netMonitoring {
    WeakSelf;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:{
                NSLog(@"未识别的网络");
            }break;
            case AFNetworkReachabilityStatusNotReachable:{
                NSLog(@"不可达的网络(未连接)");
            }break;
            case  AFNetworkReachabilityStatusReachableViaWWAN:{
                [weakSelf requesContent];
            } break;
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                [weakSelf requesContent];
            } break;
            default:
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(void)requesContent {
    WeakSelf
    [YBToolClass postNetworkWithUrl:@"Home.getConfig" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 0){
            NSDictionary *infoDic = [info firstObject];
            [weakSelf setDataUI:infoDic];
        }
    } fail:^{ }];
}

-(void)setDataUI:(NSDictionary *)infoDic {
    _titleL.text = minstr([infoDic valueForKey:@"login_alert_title"]);
    _contentL.text = minstr([infoDic valueForKey:@"login_alert_content"]);
    
    NSArray *ppA = @[
        @{
            @"title":minstr([infoDic valueForKey:@"login_private_title"]),
            @"url":minstr([infoDic valueForKey:@"login_private_url"]),
        },
        @{
            @"title":minstr([infoDic valueForKey:@"login_service_title"]),
            @"url":minstr([infoDic valueForKey:@"login_service_url"]),
        }
    ];
    
    NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",_contentL.text]];
    [textAtt addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#6F6F6F", 1) range:textAtt.yy_rangeOfAll];
    
    for (int i=0; i<ppA.count; i++) {
        NSDictionary *subDic = ppA[i];
        NSRange clickRange = [[textAtt string]rangeOfString:minstr([subDic valueForKey:@"title"])];
        //RGB_COLOR(@"#5C94E7", 1)
        [textAtt yy_setTextHighlightRange:clickRange color:Pink_Cor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"协议");
            if ([YBToolClass checkNull:minstr([subDic valueForKey:@"url"])]) {
                [MBProgressHUD showError:YZMsg(@"链接不存在")];
                return;
            }
            YBWebViewController *VC = [[YBWebViewController alloc]init];
            NSString *paths = minstr([subDic valueForKey:@"url"]);
            if(![paths hasPrefix:@"http"]){
                paths = [h5url stringByAppendingFormat:@"%@",paths];
            }
            VC.urls = paths;
            [[YBAppDelegate sharedAppDelegate] pushViewController:VC animated:YES];
        }];
    }
    textAtt.yy_alignment = NSTextAlignmentCenter;
    _contentL.attributedText = textAtt;
}



#pragma mark - 进入全功能模式按钮
-(void)showLiteAllBtn {
    [self clearLiteAllBtn];
    _allFunBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allFunBtn setTitle:YZMsg(@"进入全功能模式") forState:0];
    _allFunBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    _allFunBtn.titleLabel.font = SYS_Font(15);
    [_allFunBtn setTitleColor:RGB_COLOR(@"#ffffff", 1) forState:0];
    _allFunBtn.backgroundColor = normalColors;
    _allFunBtn.layer.cornerRadius = 20;
    _allFunBtn.layer.masksToBounds = YES;
    [_allFunBtn addTarget:self action:@selector(clickAllFunBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *superWindow = [YBAppDelegate sharedAppDelegate].topViewController.view;
    [superWindow addSubview:_allFunBtn];
    [_allFunBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.centerX.equalTo(superWindow);
        make.bottom.equalTo(superWindow.mas_bottom).offset(-ShowDiff-70);
    }];
}
-(void)clickAllFunBtn {
    [[YBLiteMode shareInstance] showBaseModeAlert:PageFrom_Home];
}

-(void)clearLiteAllBtn {
    if(_allFunBtn){
        [_allFunBtn removeFromSuperview];
        _allFunBtn = nil;
    }
}
@end
