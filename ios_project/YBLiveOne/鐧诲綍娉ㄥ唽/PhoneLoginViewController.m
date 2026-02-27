//
//  PhoneLoginViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/29.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "PhoneLoginViewController.h"
#import "YBTabBarController.h"
#import "AppDelegate.h"
#import "TUIKit.h"
#import <YYText/YYLabel.h>
#import <YYText/NSAttributedString+YYText.h>
#import "LoginCountryCodeVC.h"
#import "YBSetInforMationVC.h"
#import "GDYLimitAlert.h"

@interface PhoneLoginViewController (){
    UILabel *countryNumL;
    UITextField *phoneNumT;
    UITextField *codeNumT;
    UIButton *codeBtn;
    NSTimer *codeTimer;
    int countt;
    UIButton *submitBtn;
    YYLabel *_newnRulesL;
    UILabel *_countryNumLl;
    NSString *_selCode;
    
    BOOL loginAgreementBool;
    UIButton *_xyBtn;
    GDYLimitAlert *_showAlert;
}

@end

@implementation PhoneLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeBtnBackground) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)creatUI{
    UILabel *logoLabel = [[UILabel alloc]init];
    logoLabel.font = SYS_Font(20);
    logoLabel.text = YZMsg(@"登录后体验更多精彩瞬间！");
    logoLabel.textColor = color32;
    [self.view addSubview:logoLabel];
    [logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(60+statusbarHeight+64);
    }];
    UIView *view1 = [[UIView alloc]init];
    view1.backgroundColor = colorf5;
    view1.layer.cornerRadius = 20;
    view1.layer.masksToBounds = YES;
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(logoLabel.mas_bottom).offset(33);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.mas_equalTo(40);
    }];
    _selCode = @"86";
    _countryNumLl = [[UILabel alloc]init];
    _countryNumLl.textColor = RGB_COLOR(@"#646464", 1);
    _countryNumLl.textAlignment = NSTextAlignmentCenter;
    _countryNumLl.text = @"+86";
    _countryNumLl.font = SYS_Font(15);
    [view1 addSubview:_countryNumLl];
    countryNumL = _countryNumLl;
    [_countryNumLl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(view1);
        make.width.mas_equalTo(55);
    }];
    UIImageView *arrowImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_arrow"]];
    [view1 addSubview:arrowImgV];
    [arrowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_countryNumLl);
        make.left.equalTo(_countryNumLl.mas_right);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(8);
    }];
    UIButton *telShadowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [telShadowBtn addTarget:self action:@selector(clikcTelShadowBtn) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:telShadowBtn];
    [telShadowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_countryNumLl.mas_left);
        make.height.centerY.equalTo(view1);
        make.right.equalTo(arrowImgV.mas_right);
    }];
    
    phoneNumT = [[UITextField alloc]init];
    phoneNumT.placeholder = YZMsg(@"输入手机号码");
    phoneNumT.font = SYS_Font(15);
    phoneNumT.keyboardType = UIKeyboardTypeNumberPad;
    [view1 addSubview:phoneNumT];
    [phoneNumT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_countryNumLl);
        make.left.equalTo(arrowImgV.mas_right).offset(10);
        make.height.equalTo(view1);
        make.right.equalTo(view1).offset(-20);
    }];
    
    UIView *view2 = [[UIView alloc]init];
    view2.backgroundColor = colorf5;
    view2.layer.cornerRadius = 20;
    view2.layer.masksToBounds = YES;
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(view1.mas_bottom).offset(15);
        make.width.height.equalTo(view1);
    }];
    
    UITextField *codeT = [[UITextField alloc]init];
    codeT.placeholder = YZMsg(@"输入验证码");
    codeT.font = SYS_Font(15);
    codeT.keyboardType = UIKeyboardTypeNumberPad;
    [view2 addSubview:codeT];
    codeNumT = codeT;
    [codeT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(view2);
        make.left.equalTo(view2).offset(18);
        make.width.equalTo(view2).multipliedBy(0.5);
    }];
    
    UIButton *codeButton = [UIButton buttonWithType:0];
    [codeButton setTitle:YZMsg(@"获取验证码") forState:0];
    [codeButton setTitleColor:color32 forState:0];
    codeButton.titleLabel.font = SYS_Font(13);
    [codeButton addTarget:self action:@selector(codeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:codeButton];
    codeBtn = codeButton;
    
    [codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(view2);
        make.width.mas_equalTo(100);
    }];

    UILabel *tapsLb = [[UILabel alloc]init];
    tapsLb.textColor = [UIColor grayColor];
    tapsLb.font = [UIFont systemFontOfSize:13];
    tapsLb.text = YZMsg(@"*短信验证保障账户安全的同时短信费用将由平台支付");
    tapsLb.numberOfLines = 0;
    [self.view addSubview:tapsLb];
    [tapsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(codeT.mas_left);
        make.right.lessThanOrEqualTo(view2.mas_right);
        make.top.equalTo(view2.mas_bottom).offset(10);
    }];
    
    submitBtn = [UIButton buttonWithType:0];
    [submitBtn setTitle:YZMsg(@"立即登录") forState:0];
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setBackgroundColor:normalColors];
    submitBtn.userInteractionEnabled = NO;
    submitBtn.layer.cornerRadius = 20;
    submitBtn.layer.masksToBounds = YES;
    [self.view addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(view2.mas_bottom).offset(60);
        make.width.height.equalTo(view1);
    }];

    CGFloat xbottom;
    if (@available(iOS 11.0, *)) {
        xbottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        xbottom = 0;
    }
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
    _newnRulesL.text =minstr([_rulesDic valueForKey:@"login_title"]);// @"登录即代表你同意";
    _newnRulesL.textColor = RGB_COLOR(@"#323232", 1);
    _newnRulesL.font = SYS_Font(15);
    _newnRulesL.numberOfLines = 0;
    
    NSArray *ppA = [NSArray arrayWithArray:[_rulesDic valueForKey:@"message"]];
    
    
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

}
-(void)protocolBtnClick{
    loginAgreementBool = !loginAgreementBool;
    if (loginAgreementBool) {
        _xyBtn.selected = YES;
    }else{
        _xyBtn.selected = NO;
    }

}

-(void)clikcTelShadowBtn {
    LoginCountryCodeVC *vc = [[LoginCountryCodeVC alloc]init];
    vc.countryEvent = ^(NSString *selCode) {
        _countryNumLl.text = [NSString stringWithFormat:@"+%@",selCode];
        _selCode = selCode;
    };
    [[YBAppDelegate sharedAppDelegate]pushViewController:vc animated:YES];
}

#pragma mark ============获取验证码=============

- (void)codeBtnClick{
    NSString *phoneStr = [phoneNumT.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (phoneStr.length <= 0) {
        [MBProgressHUD showError:YZMsg(@"请输入正确的手机号码")];
        return;
    }
    WeakSelf;
    
    codeBtn.userInteractionEnabled = NO;
    NSString *sign = [NSString stringWithFormat:@"mobile=%@&400d069a791d51ada8af3e6c2979bcd7",phoneNumT.text];
    [YBToolClass postNetworkWithUrl:@"Login.GetCode" andParameter:@{@"mobile":phoneNumT.text,@"sign":[[YBToolClass sharedInstance] md5:sign],@"country_code":_selCode} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 0) {
            [codeNumT becomeFirstResponder];
            countt = 60;
            if (!codeTimer) {
                codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];
            }
            //ray begin
        }else if (code == 110){
            codeBtn.userInteractionEnabled = YES;
            [weakSelf showAlertMsg:msg];
            //ray end
        }else{
            [codeNumT becomeFirstResponder];
            codeBtn.userInteractionEnabled = YES;
        }
    } fail:^{
        codeBtn.userInteractionEnabled = YES;
    }];
}
- (void)daojishi{
    [codeBtn setTitle:[NSString stringWithFormat:@"%ds",countt] forState:UIControlStateNormal];
    if (countt<=0) {
        [codeBtn setTitle:YZMsg(@"获取验证码") forState:UIControlStateNormal];
        codeBtn.userInteractionEnabled = YES;
        [codeTimer invalidate];
        codeTimer = nil;
        countt = 60;
    }
    countt-=1;

}
- (void)doReturn{
    
    if (codeTimer) {
        [codeTimer invalidate];
        codeTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//ray begin
-(void)showAlertMsg:(NSString *)msg {
    [self.view endEditing:YES];
    
    [self destraoyAlert];
    NSDictionary *alertDic = @{
        @"title":YZMsg(@"提示"),
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
#pragma mark ============立即登录=============

- (void)submitBtnClick{

    if (loginAgreementBool == NO) {
        [MBProgressHUD showError:YZMsg(@"请仔细阅读用户协议并勾选")];
        return;
    }

    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Login.UserLogin" andParameter:@{@"user_login":phoneNumT.text,@"code":codeNumT.text,@"source":@"ios",@"pushid":@"",@"country_code":_selCode} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            
           // NSString *isreg = minstr([dic valueForKey:@"isreg"]);
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
        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}
#pragma mark ============输入变化通知=============

- (void)ChangeBtnBackground{
    if (phoneNumT.text.length > 0 && codeNumT.text.length > 0) {
        submitBtn.userInteractionEnabled = YES;
    }else{
        submitBtn.userInteractionEnabled = NO;
    }
}
#pragma mark ============隐私协议=============

- (void)eula{
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingString:@"/appapi/page/detail?id=1"];
    paths = [paths stringByAppendingFormat:@"&lang=%@",[RookieTools serviceLang]];
    VC.urls = paths;
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark ============IM=============

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
