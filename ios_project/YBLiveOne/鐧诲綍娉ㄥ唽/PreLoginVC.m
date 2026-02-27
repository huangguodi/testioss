//
//  PreLoginVC.m
//  iphoneLive
//
//  Created by Apple on 2018/11/10.
//  Copyright © 2018 cat. All rights reserved.
//

#import "PreLoginVC.h"
#import "PhoneLoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "YBTabBarController.h"
#import "TUIKit.h"
#import <YYText/YYLabel.h>
#import <YYText/NSAttributedString+YYText.h>
#import "RegAlertView.h"
#import "YBSetInforMationVC.h"
#import "GDYLimitAlert.h"

@interface PreLoginVC ()
{
    BOOL loginAgreementBool;

}
@property (nonatomic,strong) UIActivityIndicatorView *testActivityIndicator;
@property (strong, nonatomic) IBOutlet YYLabel *newnRulesL;

@end

@implementation PreLoginVC
{
    UIImageView *_gifImage;
    UIImageView *_logo;
    
    UIButton *_mobileBtn;
    UILabel *_mobileLabel;
    UIButton *_qqBtn;
    UILabel *_qqLabel;
    UIButton *_wechatBtn;
    UILabel *_wechatLabel;
    
    UIButton *_appleBtn;
    UILabel *_appleLabel;

    YYLabel *_newnRulesL;
    UIButton *_xyBtn;
    NSArray *platformsarray;
    NSDictionary *rulesDic;

    NSString *_isreg;
    RegAlertView *_alerView;
    GDYLimitAlert *_showAlert;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    loginAgreementBool = NO;
    [self createSubviews];
    //上下浮动
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat duration = 6.0f;
    animation.duration = duration;
    animation.values = @[@0,@-7.5,@-15,@-22.5,@-30,@-37.5,@-45,@-52.5,@-60,@-67.5,@-75,@-82.5,@-90,@-97.5,@-105,@-112.5,@-120,@-127.5,@-134,@-142.5,@-150,@-157.5,@-165,@-172.5,@-180,@-187.5,@-195,@-202.5,@-210,@-210,@-202.5,@-195,@-187.5,@-180,@-172.5,@-165,@-157.5,@-150,@-142.5,@-134,@-127.5,@-120,@-112.5,@-105,@-97.5,@-90,@-82.5,@-75,@-67.5,@-60,@-52.5,@-45,@-37.5,@-30,@-22.5,@-15,@-7.5,@0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    [_gifImage.layer addAnimation:animation forKey:@"1111"];
    
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听 防止第一次安装不显示
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            [self getLoginThird];
            return;
        }else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable){
            NSLog(@"nonetwork-------");
            [self getLoginThird];
        }else if ((status == AFNetworkReachabilityStatusReachableViaWWAN)||(status == AFNetworkReachabilityStatusReachableViaWiFi)){
            [self getLoginThird];
            NSLog(@"wifi-------");
        }
    }];

    
}


-(void)getLoginThird{
    [YBToolClass postNetworkWithUrl:@"Login.GetLoginType" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infos = [info firstObject];
            platformsarray = [infos valueForKey:@"login_type_ios"];
            rulesDic = [infos valueForKey:@"login_alert"];

//            platformsarray = info;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setthirdview];
                [self setNewInfo];
            });

        }
    } fail:^{
        
    }];
}
-(void)setNewInfo{
    WeakSelf;
    _newnRulesL.hidden = NO;
    _newnRulesL.text =minstr([rulesDic valueForKey:@"login_title"]);// @"登录即代表你同意";
    _newnRulesL.textColor = RGB_COLOR(@"#323232", 1);
    _newnRulesL.font = SYS_Font(15);
    _newnRulesL.numberOfLines = 0;
    
    NSArray *ppA = [NSArray arrayWithArray:[rulesDic valueForKey:@"message"]];
    
    
    NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",_newnRulesL.text]];
    [textAtt addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#6F6F6F", 1) range:textAtt.yy_rangeOfAll];
    
    for (int i=0; i<ppA.count; i++) {
        NSDictionary *subDic = ppA[i];
        NSRange clickRange = [[textAtt string]rangeOfString:minstr([subDic valueForKey:@"title"])];
        [textAtt yy_setTextHighlightRange:clickRange color:RGB_COLOR(@"#5C94E7", 1) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"协议");
            if ([YBToolClass checkNull:minstr([subDic valueForKey:@"url"])]) {
                [MBProgressHUD showError:YZMsg(@"链接不存在")];
                return;
            }
            YBWebViewController *h5vc = [[YBWebViewController alloc]init];
            h5vc.urls = minstr([subDic valueForKey:@"url"]);;
            [[YBAppDelegate sharedAppDelegate]pushViewController:h5vc animated:YES];
        }];
    }
    _newnRulesL.attributedText = textAtt;

    [_xyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_newnRulesL.mas_left).offset(-5);
        make.centerY.equalTo(_newnRulesL.mas_centerY);
        make.height.width.mas_equalTo(12);
        }];

//    if (!_alerView) {
//        _alerView = [RegAlertView showRegAler:rulesDic complete:^(int code) {
//            [weakSelf showAler:code];
//        }];
//    }

}
-(void)showAler:(int)code {
    if (code == -1) {
//        exit(0);
//        [[YBAppDelegate sharedAppDelegate]popViewController:YES];
        if([[UIApplication sharedApplication] respondsToSelector:@selector(terminateWithSuccess)]){
            [[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
        }

    }
}

- (void)setthirdview{
    //
    NSMutableArray *thirdArr = [NSMutableArray arrayWithObject:@"手机"];
    for (int i = 0; i < platformsarray.count; i ++) {
        [thirdArr addObject:platformsarray[i]];
    }
    CGFloat w = 40;
    CGFloat space = _window_width-([thirdArr count] - 1)*40-[thirdArr count]*40;

    for (int i = 0; i < thirdArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.tag = 1000 + i;
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"login_%@",thirdArr[i]]] forState:UIControlStateNormal];
        [btn setTitle:thirdArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(thirdlogin:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(space/2+i*80,_window_height-120-ShowDiff,w,w);
        [self.view addSubview:btn];

        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn.mas_bottom).offset(10);
            make.centerX.equalTo(btn);
        }];
        if ([thirdArr[i] isEqual:@"手机"]) {
            label.text = YZMsg(@"手机登录");
        }else if ([thirdArr[i] isEqual:@"qq"]){
            label.text = YZMsg(@"QQ登录");

        }else if ([thirdArr[i] isEqual:@"wx"]){
            label.text = YZMsg(@"微信登录");

        }else if ([thirdArr[i] isEqual:@"ios"]){
            label.text = YZMsg(@"苹果登录");
        }
        if ([YBToolClass isUp]) {
            label.hidden = YES;
        }

    }
}
//若要添加登陆方式，在此处添加
-(void)thirdlogin:(UIButton *)sender{

    if ([sender.titleLabel.text isEqual:@"手机"]) {
        [self mobileLogin];
    }else if ([sender.titleLabel.text isEqual:@"qq"]) {
        if (loginAgreementBool == NO) {
            [MBProgressHUD showError:YZMsg(@"请仔细阅读用户协议并勾选")];
            return;
        }

        [self qqLogin];
    }else if ([sender.titleLabel.text isEqual:@"wx"]) {
        if (loginAgreementBool == NO) {
            [MBProgressHUD showError:YZMsg(@"请仔细阅读用户协议并勾选")];
            return;
        }

        [self wechatLogin];
    }else if ([sender.titleLabel.text isEqual:@"ios"]) {
        if (loginAgreementBool == NO) {
            [MBProgressHUD showError:YZMsg(@"请仔细阅读用户协议并勾选")];
            return;
        }

        [self appleLogin];
    }
    
}
- (void)createSubviews{
    [self.navigationController setNavigationBarHidden:YES];
    _gifImage = ({
        UIImageView *image = [[UIImageView alloc] init];
        image.frame = CGRectMake(0, 0, _window_width, _window_height + 300);
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.image = [UIImage imageNamed:@"登录静态"];
        [self.view addSubview:image];
        image;
    });
    
    _logo = ({
        UIImageView *image = [[UIImageView alloc] init];
        image.image = [UIImage imageNamed:getImagename(@"logo")];
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([lagType isEqual:ZH_CN]) {
                make.edges.equalTo(self.view);
            }else{
                make.width.equalTo(self.view).offset(-30);
                make.centerX.centerY.height.equalTo(self.view);
            }
        }];
        image;
    });
    
    CGFloat xbottom;
    if (@available(iOS 11.0, *)) {
        xbottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        xbottom = 0;
    }
//    NSString *xieyiStr = [NSString stringWithFormat:@"《%@%@》",protocolName,YZMsg(@"平台协议")];

//    UILabel *label = [[UILabel alloc] init];
//    label.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"登录即代表同意"),xieyiStr];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:13];
//    [self.view addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.bottom.equalTo(self.view).offset(- 10 - xbottom);
//    }];
//    NSRange range = [label.text rangeOfString:xieyiStr];
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
//    [str addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
//    label.attributedText = str;
//    label.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eula)];
//    [label addGestureRecognizer:tap];
    
    _newnRulesL = [[YYLabel alloc]init];
    _newnRulesL.textAlignment = NSTextAlignmentCenter;
    _newnRulesL.font = [UIFont systemFontOfSize:13];
    _newnRulesL.preferredMaxLayoutWidth = _window_width-50;
    [self.view addSubview:_newnRulesL];
    [_newnRulesL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(self.view.mas_width).offset(-50);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- 10 - xbottom);
    }];

    _xyBtn = [UIButton buttonWithType:0];
    [_xyBtn addTarget:self action:@selector(protocolBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_xyBtn setImage:[UIImage imageNamed:@"xieyi"] forState:0];
    [_xyBtn setImage:[UIImage imageNamed:@"xieyi_sel"] forState:UIControlStateSelected];
    [self.view addSubview:_xyBtn];
    [_xyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_newnRulesL.mas_centerY);
        make.right.equalTo(_newnRulesL.mas_left).offset(-10);
        make.height.width.mas_equalTo(12);
    }];
    
    [self.view layoutIfNeeded];
    [self setlogoImage];
}
-(void)protocolBtnClick{
    loginAgreementBool = !loginAgreementBool;
    if (loginAgreementBool) {
//        [_xyBtn setBackgroundImage:[UIImage imageNamed:@"xieyi_sel"]];
        _xyBtn.selected = YES;
    }else{
//        [_xyBtn setBackgroundImage:[UIImage imageNamed:@"xieyi"]];
        _xyBtn.selected = NO;
    }

}
- (void)mobileLogin{
    PhoneLoginViewController *nl = [[PhoneLoginViewController alloc] init];
    nl.rulesDic = rulesDic;
    [self.navigationController pushViewController:nl animated:YES];
}
- (void)qqLogin{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ result:nil];
    [self indicator];
    [self login:@"1" platforms:SSDKPlatformTypeQQ];
}
- (void)wechatLogin{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat result:nil];
    [self indicator];
    [self login:@"2" platforms:SSDKPlatformTypeWechat];
}
-(void)appleLogin{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeAppleAccount result:nil];
    [self indicator];
    [self login:@"3" platforms:SSDKPlatformTypeAppleAccount];

}
- (void)indicator{
    _testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _testActivityIndicator.center = CGPointMake(_window_width/2 - 10, _window_height/2 - 10);
    [self.view addSubview:_testActivityIndicator];
    _testActivityIndicator.color = [UIColor whiteColor];
}
- (void)eula{
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingString:@"/appapi/page/detail?id=1"];
    paths = [paths stringByAppendingFormat:@"&lang=%@",[RookieTools serviceLang]];
    VC.urls = paths;
    [self.navigationController pushViewController:VC animated:YES];
}
//-------------------
-(void)RequestLogin:(SSDKUser *)user LoginType:(NSString *)LoginType
{
    NSString *icon = nil;
    NSString *access_token= @"";
    if ([LoginType isEqualToString:@"1"]) {
        icon = [user.rawData valueForKey:@"figureurl_qq_2"];
        access_token = user.credential.token;
    }
    else if ([LoginType isEqualToString:@"3"]){

        icon =@"";
    }

    else
    {
        icon = user.icon;
    }
    NSString *unionid;
    if ([LoginType isEqual:@"2"]) {
        unionid = [user.rawData valueForKey:@"unionid"];
        access_token = user.credential.token;

    }
    else{
        unionid = user.uid;
    }
    if (!icon) {
        [MBProgressHUD showError:YZMsg(@"未获取到授权，请重试")];
        return;
    }
    NSString *sign = [NSString stringWithFormat:@"openid=%@&400d069a791d51ada8af3e6c2979bcd7",unionid];

    NSDictionary *dic = @{
                          @"openid":[self encodeString:unionid],
                          @"type":[self encodeString:LoginType],
                          @"nicename":[self encodeString:user.nickname]?[self encodeString:user.nickname]:@"",
                          @"avatar":[self encodeString:icon],
                          @"source":@"ios",
                          @"sign":[[YBToolClass sharedInstance] md5:sign],
                          @"pushid":@"",
                          @"access_token":access_token
                          };
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Login.userLoginByThird" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [weakSelf.testActivityIndicator stopAnimating]; // 结束旋转
        [weakSelf.testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            //NSString *isreg = minstr([dic valueForKey:@"isreg"]);
            NSString *sexstr = minstr([dic valueForKey:@"issexrecommend"]);
           
            if ([sexstr isEqual:@"1"]) {
                YBSetInforMationVC *VC = [[YBSetInforMationVC alloc] init];
                    VC.dic = dic;
                    [[YBAppDelegate sharedAppDelegate ] pushViewController:VC animated:YES];
            }else{

                LiveUser *userInfo = [[LiveUser alloc] initWithDic:dic];
                [Config saveProfile:userInfo];
                [self IMLogin];
                UIApplication *app =[UIApplication sharedApplication];
                AppDelegate *app2 = (AppDelegate *)app.delegate;
                if (!app2.ybtab) {
                    [YBToolClass needRegNot:YES];
                    YBTabBarController *tabbarV = [[YBTabBarController alloc]init];
                    app2.ybtab = tabbarV;
                }
                app2.ybtab.selectedIndex =0;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:app2.ybtab];
                app2.window.rootViewController = nav;
                [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Home];

            }

            //ray begin
        }else if (code == 110){
            [weakSelf showAlertMsg:msg];
            //ray end
        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^{
        [weakSelf.testActivityIndicator stopAnimating]; // 结束旋转
        [weakSelf.testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

    }];
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    NSString *url = [purl stringByAppendingFormat:@"/?service=Login.userLoginByThird"];
//    [session POST:url parameters:@{
//                                   @"openid":[self encodeString:unionid],
//                                   @"type":[self encodeString:LoginType],
//                                   @"nicename":[self encodeString:user.nickname],
//                                   @"avatar":[self encodeString:icon],
//                                   }
//         progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//             NSNumber *number = [responseObject valueForKey:@"ret"] ;
//             if([number isEqualToNumber:[NSNumber numberWithInt:200]])
//             {
//                 NSArray *data = [responseObject valueForKey:@"data"];
//                 NSNumber *code = [data valueForKey:@"code"];
//                 if([code isEqualToNumber:[NSNumber numberWithInt:0]])
//                 {
//                     NSDictionary *info = [[data valueForKey:@"info"] firstObject];
//                     LiveUser *userInfo = [[LiveUser alloc] initWithDic:info];
//                     [Config saveProfile:userInfo];
//                     [self LoginJM];
//                     //判断第一次登陆
//                     NSString *isreg = minstr([info valueForKey:@"isreg"]);
//                     _isreg = isreg;
//                     [self heartbeats];
//                     if ([minstr([info valueForKey:@"mobile"]) length] > 1) {
//                         [self login];
//                     }else{
//                         [self qubangding];
//                     }
//
//                 }
//                 else{
//                     [MBProgressHUD showError:[data valueForKey:@"msg"]];
//                 }
//             }
//             [_testActivityIndicator stopAnimating]; // 结束旋转
//             [_testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
//         }
//          failure:^(NSURLSessionDataTask *task, NSError *error)
//     {
//         [MBProgressHUD showError:@"请重试"];
//         [_testActivityIndicator stopAnimating]; // 结束旋转
//         [_testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
//     }];
}
//- (void)heartbeats{
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
////    [delegate onlineTimer];
//}
//- (void)login{
//    [self getConfig];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"getBonus" object:nil];
//}
- (void)IMLogin{
    [YBToolClass setServerPushLang];
    [[YBImManager shareInstance] imLogin];

//    [[TUIKit sharedInstance] loginKit:[Config getOwnID] userSig:[Config lgetUserSign] succ:^{
//        NSLog(@"IM登录成功");
//    } fail:^(int code, NSString *msg) {
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
////        [alert show];
//    }];
}

-(NSString*)encodeString:(NSString*)unencodedString{
    NSString*encodedString=(NSString*)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}
-(void)login:(NSString *)types platforms:(SSDKPlatformType)platform{

    WeakSelf;
    [_testActivityIndicator startAnimating]; // 开始旋转
    [ShareSDK getUserInfo:platform
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {

             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             [self RequestLogin:user LoginType:types];

         } else if (state == 2 || state == 3) {
             [weakSelf.testActivityIndicator stopAnimating]; // 结束旋转
             [weakSelf.testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
         }

     }];
}
- (void)dealloc{
    NSLog(@"b dealloc");
}
//-(void)getConfig{
//    //在这里加载后台配置文件
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    NSString *url = [purl stringByAppendingFormat:@"?service=Home.getConfig"];
//    [session POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSNumber *number = [responseObject valueForKey:@"ret"] ;
//        if([number isEqualToNumber:[NSNumber numberWithInt:200]])
//        {
//            NSArray *data = [responseObject valueForKey:@"data"];
//            NSNumber *code = [data valueForKey:@"code"];
//            if([code isEqualToNumber:[NSNumber numberWithInt:0]])
//            {
//                NSDictionary *subdic = [[data valueForKey:@"info"] firstObject];
////                liveCommon *commons = [[liveCommon alloc]initWithDic:subdic];
////                [common saveProfile:commons];
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//    }];
//}
- (void)setlogoImage{
//    UIImage * image1 = [UIImage imageNamed:@"logo"];
    UIImage * image2 = [YBToolClass getAppIcon];
//    CGSize size = image1.size;
//    UIGraphicsBeginImageContext(size);
//    [image1 drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    [image2 drawInRect:CGRectMake(305, 236, 140, 140)];
//    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
//    _logo.image = resultingImage;
//    UIGraphicsEndImageContext();
    
    [self.view layoutSubviews];
    UIImageView *topImg = [[UIImageView alloc]init];
    topImg.frame = CGRectMake(0, 100+ShowDiff, 70, 70);
    topImg.layer.cornerRadius = 10;
    topImg.layer.masksToBounds = YES;
    topImg.image = image2;
    topImg.centerX =self.view.centerX;
    [self.view addSubview:topImg];
//
//    UIImageView *bottomImg =  [[UIImageView alloc]init];
//    bottomImg.image = image1;
//    bottomImg.frame = CGRectMake(0, topImg.bottom+10, image1.size.width, image1.size.height);
//    bottomImg.centerX = topImg.centerX;
//    [self.view addSubview:bottomImg];
}

//ray begin
-(void)showAlertMsg:(NSString *)msg {
    [self destraoyAlert];
    NSDictionary *alertDic = @{
        @"title":@"提示",
        @"msg":msg,
    };
    _showAlert = [GDYLimitAlert showLimitWithDic:alertDic complete:^{
        
    }];
}

-(void)destraoyAlert {
    if (_showAlert) {
        [_showAlert removeFromSuperview];
        _showAlert = nil;
    }
}
//ray end
@end
