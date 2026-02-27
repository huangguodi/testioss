//
//  RechargeViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/4.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "RechargeViewController.h"
#import "applePay.h"
#import <WXApi.h>
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "DataVerifier.h"

@interface RechargeViewController ()<applePayDelegate,WXApiDelegate>{
    UILabel *coinL;
    UIImageView *headerImgV;
    NSDictionary *subDic;
    NSArray *allArray;
    UIScrollView *backScroll;
    NSMutableArray *payTypeArray;
    NSMutableArray *coinArray;
    applePay *applePays;//苹果支付
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSString *payTypeID;
    BOOL isCreatUI;
    NSString *yTitleStr;
}
@property(nonatomic,strong)NSDictionary *seleDic;//选中的钻石字典
//支付宝
@property(nonatomic,copy)NSString *aliapp_key_ios;
@property(nonatomic,copy)NSString *aliapp_partner;
@property(nonatomic,copy)NSString *aliapp_seller_id;
//微信
@property(nonatomic,copy)NSString *wx_appid;

//paypal
@property(nonatomic,strong)NSString *paypal_sandbox;
@property(nonatomic,strong)NSString *sandbox_clientid;
@property(nonatomic,strong)NSString *product_clientid;

@end

@implementation RechargeViewController
- (void)viewWillAppear:(BOOL)animated{
    [self requestData];

}
- (void)doReturn {
    [[YBRechargeType chargeManeger]removePayNotice];
    [super doReturn];
}
-(void)rightBtnClick {
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingFormat:@"/appapi/Charge/index?uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    paths = [paths stringByAppendingFormat:@"&lang=%@",[RookieTools serviceLang]];
    VC.urls = paths;
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    yTitleStr = YZMsg(@"未成年人禁止充值消费");

    [[YBRechargeType chargeManeger]addPayNotice];
    
    self.titleL.text = YZMsg(@"充值");
    self.rightBtn.hidden = NO;
    [self.rightBtn setImage:[UIImage imageNamed:@"钱包-记录"] forState:0];
    
    payTypeArray = [NSMutableArray array];
    coinArray = [NSMutableArray array];
    applePays = [[applePay alloc]init];
    applePays.delegate = self;

    backScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-50-ShowDiff)];
    [self.view addSubview:backScroll];
    backScroll.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];
    headerImgV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, _window_width-30, (_window_width-30)*0.38)];
    headerImgV.userInteractionEnabled = YES;
    headerImgV.image = [UIImage imageNamed:@"recharge_背景"];
    [backScroll addSubview:headerImgV];
    UILabel *labelll = [[UILabel alloc]init];
    labelll.textColor = [UIColor whiteColor];
    labelll.font = SYS_Font(12);
    labelll.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"我的"),[common name_coin]];
    [headerImgV addSubview:labelll];
    [labelll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(0.65);
    }];
    coinL = [[UILabel alloc]init];
    coinL.textColor = [UIColor whiteColor];
    coinL.font = [UIFont boldSystemFontOfSize:28];
    coinL.text = @"0";
    [headerImgV addSubview:coinL];
    [coinL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(1.11);
    }];
    NSString *xieyiStr = [NSString stringWithFormat:@"《%@%@》",protocolName,YZMsg(@"充值协议")];
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"已阅读并同意"),xieyiStr];
    label.textColor = color66;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backScroll);
        make.top.equalTo(backScroll.mas_bottom).offset(20);
    }];
    NSRange range = [label.text rangeOfString:xieyiStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    [str addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
    label.attributedText = str;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eula)];
    [label addGestureRecognizer:tap];

    
    UILabel *youngLb = [[UILabel alloc]init];
    youngLb.text =yTitleStr;
    youngLb.textColor = normalColors_live;
    youngLb.font =[UIFont systemFontOfSize:12];
    [self.view addSubview:youngLb];
    [youngLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(label.mas_top).offset(-5);
        make.centerX.equalTo(self.view);
    }];
    
    UIImageView *tanImg =[[UIImageView alloc]init];
    tanImg.image = [UIImage imageNamed:@"young-叹号"];
    [self.view addSubview:tanImg];
    [tanImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(youngLb.mas_centerY);
        make.width.height.mas_equalTo(13);
        make.right.equalTo(youngLb.mas_left);
    }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

}
- (void)appWillEnterForeground:(NSNotification*)note{
    [self requestData];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Charge.GetBalance" andParameter:@{@"type":@"2"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [backScroll.mj_header endRefreshing];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            coinL.text = minstr([infoDic valueForKey:@"coin"]);
            LiveUser *user = [Config myProfile];
            user.coin = minstr([infoDic valueForKey:@"coin"]);
            [Config saveProfile:user];
            if (self.block) {
                self.block(minstr([infoDic valueForKey:@"coin"]));
            }
            if (allArray.count == 0) {
                _aliapp_key_ios = [infoDic valueForKey:@"aliapp_key"];
                _aliapp_partner = [infoDic valueForKey:@"aliapp_partner"];
                _aliapp_seller_id = [infoDic valueForKey:@"aliapp_seller_id"];
                //微信的信息
                _wx_appid = [infoDic valueForKey:@"wx_appid"];
                //paypal
                _paypal_sandbox = minstr([infoDic valueForKey:@"paypal_sandbox"]);
                _sandbox_clientid = minstr([infoDic valueForKey:@"sandbox_clientid"]);
                _product_clientid = minstr([infoDic valueForKey:@"product_clientid"]);
                
//                [WXApi registerApp:_wx_appid];
//                [WXApi registerApp:_wx_appid universalLink:WechatUniversalLink];

                
                //            NSMutableArray *a1 = [NSMutableArray array];
                //            [a1 addObjectsFromArray:[infoDic valueForKey:@"paylist"]];
                //            [a1 addObjectsFromArray:[infoDic valueForKey:@"paylist"]];
                //
                //            NSMutableArray *a2 = [NSMutableArray array];
                //            [a2 addObjectsFromArray:[infoDic valueForKey:@"rules"]];
                //            [a2 addObjectsFromArray:[infoDic valueForKey:@"rules"]];
                //            allArray = @[a1,a2];
                
                NSArray *ssssss = [infoDic valueForKey:@"paylist"];
                if ([YBToolClass isUp]) {
                    ssssss = @[@{@"id":@"apple"}];
                }
                NSArray *rulesA = [infoDic valueForKey:@"rules"];
                NSMutableArray *m_rules = [NSMutableArray array];
                for (NSDictionary *subDic in rulesA) {
                    int money = [minstr([subDic valueForKey:@"money"]) intValue];
                    if ([YBToolClass isUp]) {
                        if (money >= 1) {
                            [m_rules addObject:subDic];
                        }
                    }else{
                        [m_rules addObject:subDic];
                    }
                }
                rulesA = [NSArray arrayWithArray:m_rules];
                
                if (ssssss.count > 0) {
                    allArray = @[ssssss,rulesA];
                    if (!isCreatUI) {
                        [self creatUI];
                    }
                }
            }
            
        }
    } fail:^{
        [backScroll.mj_header endRefreshing];
    }];
}
- (void)creatUI{
    isCreatUI = YES;
    CGFloat btnWidth;
    CGFloat btnHeight;
    CGFloat btnSH = 0.0;
    if (IS_IPHONE_5) {
        btnWidth = 90;
        btnHeight = 41;
        btnSH = 49;
    }else{
        btnWidth = 110;
        btnHeight = 50;
        btnSH = 60;
    }
    CGFloat speace = (_window_width-30-btnWidth*3)/2;
    CGFloat y = headerImgV.bottom + 20;
    for (int i = 0; i < allArray.count; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, y, 100, 20)];
        label.font = SYS_Font(12);
        label.textColor = RGB_COLOR(@"#646464", 1);
        NSArray *array = allArray[i];

        [backScroll addSubview:label];
        if (i == 0) {
            
            if (array.count == 0) {
                payTypeID = @"apple";
                continue;
            }
            if (array.count == 1 && [minstr([array[0] valueForKey:@"id"]) isEqual:@"apple"]) {
                payTypeID = @"apple";
                continue;
            }
            
            label.text = YZMsg(@"请选择支付方式");
            UILabel *youngLb = [[UILabel alloc]init];
            
            CGFloat nameWidth = [[YBToolClass sharedInstance] widthOfString:yTitleStr andFont:SYS_Font(12) andHeight:20];
            youngLb.frame = CGRectMake(_window_width-nameWidth-10, y, nameWidth, 20);
            youngLb.text =yTitleStr;
            youngLb.textColor = normalColors_live;
            youngLb.font =[UIFont systemFontOfSize:12];
            [backScroll addSubview:youngLb];
            
            UIImageView *tanImg =[[UIImageView alloc]init];
            tanImg.image = [UIImage imageNamed:@"young-叹号"];
            [backScroll addSubview:tanImg];
            [tanImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(youngLb.mas_centerY);
                make.width.height.mas_equalTo(13);
                make.right.equalTo(youngLb.mas_left);
            }];

            for (int j = 0; j < array.count; j++) {
                UIButton *btn = [UIButton buttonWithType:0];
                btn.frame = CGRectMake(15+j%3 * (btnWidth+speace), label.bottom+10+(j/3)*(btnHeight + 30), btnWidth, btnHeight);
                [btn addTarget:self action:@selector(payTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setBackgroundImage:[UIImage imageNamed:@""] forState:0];
                [btn setBackgroundImage:[UIImage imageNamed:@"recharge_sel"] forState:UIControlStateSelected];
                [backScroll addSubview:btn];
                if (j == 0) {
                    btn.selected = YES;
                    payTypeID = minstr([array[j] valueForKey:@"id"]);
                }
                btn.tag = 1000+j;
                UILabel *titleL = [[UILabel alloc]init];
                titleL.font = SYS_Font(13);
                titleL.textColor = color32;
                titleL.text = minstr([array[j] valueForKey:@"name"]);
                [btn addSubview:titleL];
                [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn);
                    make.centerX.equalTo(btn).multipliedBy(1.21);
                }];
                UIImageView *imgV = [[UIImageView alloc]init];
                [imgV sd_setImageWithURL:[NSURL URLWithString:minstr([array[j] valueForKey:@"thumb"])]];
                [btn addSubview:imgV];
                [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn);
                    make.height.width.mas_equalTo(16);
                    make.right.equalTo(titleL.mas_left).offset(-5);
                }];
                [payTypeArray addObject:btn];
                if (j == array.count-1) {
                    [backScroll layoutIfNeeded];
                    y = btn.bottom + 20;
                }
            }

        }else{
            label.text = YZMsg(@"请选择充值金额");
            for (int j = 0; j < array.count; j++) {
                UIButton *btn = [UIButton buttonWithType:0];
                btn.frame = CGRectMake(15+j%3 * (btnWidth+speace), label.bottom+10+(j/3)*(btnSH + 30), btnWidth, btnSH);
                [btn addTarget:self action:@selector(coinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setBackgroundColor:colorf5];
                btn.clipsToBounds = NO;
                btn.layer.cornerRadius = 5;
                btn.layer.masksToBounds = YES;
                btn.layer.borderWidth = 1;
                btn.tag = 2000+j;
                [backScroll addSubview:btn];
                NSString *give = minstr([array[j] valueForKey:@"give"]);
                if (![give isEqual:@"0"]) {
                    CGFloat widddth = [[YBToolClass sharedInstance] widthOfString:[NSString stringWithFormat:@"%@%@%@",YZMsg(@"赠送"),give,[common name_coin]] andFont:SYS_Font(10) andHeight:15];
                    UIImageView *giveImgV = [[UIImageView alloc]initWithFrame:CGRectMake(btn.right-widddth-5, btn.top-7.5, widddth+10, 20)];
                    giveImgV.image = [UIImage imageNamed:@"recharge_send"];
                    [backScroll addSubview:giveImgV];
                    UILabel *giveLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, widddth, 15)];
                    giveLabel.text = [NSString stringWithFormat:@"%@%@%@",YZMsg(@"赠送"),give,[common name_coin]];
                    giveLabel.font = SYS_Font(10);
                    giveLabel.textColor = [UIColor whiteColor];
                    [giveImgV addSubview:giveLabel];
                }
//                if (j == 0) {
                btn.layer.borderColor = [UIColor clearColor].CGColor;
//                }
                UILabel *titleL = [[UILabel alloc]init];
                titleL.font = SYS_Font(15);
                titleL.textColor = color32;
                titleL.text = minstr([array[j] valueForKey:@"coin"]);
                if ([payTypeID isEqual:@"apple"]) {
                    titleL.text = minstr([array[j] valueForKey:@"coin_ios"]);
                }
                titleL.tag = btn.tag + 3000;
                [btn addSubview:titleL];
                [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn).multipliedBy(0.73);
                    make.centerX.equalTo(btn);
                }];
                UIImageView *imgV = [[UIImageView alloc]init];
                imgV.image = [UIImage imageNamed:@"coin_Icon"];
                [btn addSubview:imgV];
                [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(titleL);
                    make.height.width.mas_equalTo(12);
                    make.left.equalTo(titleL.mas_right).offset(5);
                }];
                UILabel *moneyL = [[UILabel alloc]init];
                moneyL.font = SYS_Font(12);
                moneyL.textColor = color66;
                moneyL.text = [NSString stringWithFormat:@"¥%@",minstr([array[j] valueForKey:@"money"])];
                moneyL.tag = btn.tag + 4000;
                if([payTypeID isEqual:@"paypal"]){
                    titleL.text = minstr([array[j] valueForKey:@"coin_paypal"]);
                    moneyL.text = [NSString stringWithFormat:@"$%@",minstr([array[j] valueForKey:@"money"])];
                }
                [btn addSubview:moneyL];
                [moneyL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(btn).multipliedBy(1.3);
                    make.centerX.equalTo(btn);
                }];
                [coinArray addObject:btn];
                if (j == array.count-1) {
                    [backScroll layoutIfNeeded];
                    y = btn.bottom + 20;
                }

            }

        }
    }
    CGFloat bottomLY;
    if (y > backScroll.height - 40 -ShowDiff) {
        bottomLY = y + 40;
    }else{
        bottomLY = backScroll.height - 40 -ShowDiff;
    }
    backScroll.contentSize = CGSizeMake(0, bottomLY);

}
- (void)payTypeBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in payTypeArray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    NSArray *typearr = allArray[0];
    NSDictionary *dic = typearr[sender.tag - 1000];
    payTypeID = minstr([dic valueForKey:@"id"]);
    for (int i = 0; i < coinArray.count; i++) {
        UIButton *btn = coinArray[i];
        UILabel *label = (UILabel *)[btn viewWithTag:btn.tag+3000];
        UILabel *moneyLL = (UILabel *)[btn viewWithTag:btn.tag+4000];
        moneyLL.text = [NSString stringWithFormat:@"￥%@",minstr([allArray[1][i] valueForKey:@"money"])];
        if ([payTypeID isEqual:@"apple"]) {
            label.text = minstr([allArray[1][i] valueForKey:@"coin_ios"]);
        }else if ([payTypeID isEqual:@"paypal"]){
            label.text = minstr([allArray[1][i] valueForKey:@"coin_paypal"]);
            moneyLL.text = [NSString stringWithFormat:@"$%@",minstr([allArray[1][i] valueForKey:@"money"])];
        }else{
            label.text = minstr([allArray[1][i] valueForKey:@"coin"]);
        }
    }
}
- (void)coinBtnClick:(UIButton *)sender{
    for (UIButton *btn in coinArray) {
        if (btn == sender) {
            btn.layer.borderColor = normalColors.CGColor;
        }else{
            btn.layer.borderColor = colorf5.CGColor;
        }
    }
    _seleDic = allArray[1][sender.tag-2000];
    if ([payTypeID isEqual:@"ali"]) {
        [self doAlipayPay];
    }
    if ([payTypeID isEqual:@"alih5"]) {
        [self doAlih5payPay];
    }
    if ([payTypeID isEqual:@"wx"]) {
        [self WeiXinPay];
    }
    if ([payTypeID isEqual:@"apple"]) {
        //[applePays applePay:_seleDic];
        [self doApplePay];
    }
    if ([payTypeID isEqual:@"paypal"]) {
        [self doPaypal];
    }

}
- (void)eula{
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingString:@"/appapi/page/detail?id=3"];
    paths = [paths stringByAppendingFormat:@"?lang=%@",[RookieTools serviceLang]];
    VC.urls = paths;
    [self.navigationController pushViewController:VC animated:YES];

}
/******************  paypal  ********************/
-(void)doPaypal {
 
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin_paypal"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    [YBToolClass postNetworkWithUrl:@"Charge.getPaypalOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *orderidStr = [[info firstObject] valueForKey:@"orderid"];
            NSDictionary *paypalSDKParam = @{
                                             @"money":minstr([subdic valueForKey:@"money"]),
                                             @"shortDesc":[NSString stringWithFormat:@"%@%@",[subdic valueForKey:@"coin"],[common name_coin]],
                                             @"orderid":orderidStr,
                                             @"type":@"0",
            };
            WeakSelf;
            [[YBRechargeType chargeManeger]selPaypalParameter:paypalSDKParam complete:^(int stateCode, RKPayType payType, NSString *msg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    if (stateCode == 0) {
                        [weakSelf requestData];
                    }
                    [MBProgressHUD showError:msg];
                });
            }];
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}
/******************   内购  ********************/

-(void)doApplePay {
    WeakSelf;
    NSDictionary *dics = @{
                          @"uid":[Config getOwnID],
                          @"coin":minstr([_seleDic valueForKey:@"coin_ios"]),
                          @"money":minstr([_seleDic valueForKey:@"money"]),
                          @"changeid":minstr([_seleDic valueForKey:@"id"]),
                          };
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Charge.getIosOrder" andParameter:dics success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *orderidStr = [[info firstObject] valueForKey:@"orderid"];
            
//            NSString *productId = minstr([dics valueForKey:@"changeid"]);
            NSString *productId = minstr([_seleDic valueForKey:@"product_id"]);
            NSString *appleCallBackUrl = [h5url stringByAppendingFormat:@"/appapi/pay/notify_ios"];
            NSDictionary *appleDic = @{@"product_id":productId,
                                       @"call_back":appleCallBackUrl,
                                       @"orderNo":orderidStr};
            [[YBRechargeType chargeManeger]selApplePayParameter:appleDic complete:^(int stateCode, RKPayType payType, NSString *msg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    if (stateCode == 0) {
                        [weakSelf requestData];
                    }
                    [MBProgressHUD showError:msg];
                });
            }];
            
        }else{
            [MBProgressHUD showError:msg];

        }
    } fail:^{
        
    }];
    
}


/*
-(void)applePayHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

}
-(void)applePayShowHUD{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

//内购成功
-(void)applePaySuccess{
    NSLog(@"苹果支付成功");
    [self requestData];
}
*/
//微信支付*****************************************************************************************************************
-(void)WeiXinPay{
    NSLog(@"微信支付");
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]] ) {
        [MBProgressHUD showError:@"未安装微信"];
        return;
        }
    [MBProgressHUD showMessage:@""];
    
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    [YBToolClass postNetworkWithUrl:@"Charge.getWxOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dict = [info firstObject];
            
            NSMutableDictionary *wxSDKParam = @{@"appid":_wx_appid}.mutableCopy;
            [wxSDKParam addEntriesFromDictionary:dict];
            WeakSelf;
            [[YBRechargeType chargeManeger]selWechatPayParameter:wxSDKParam complete:^(int stateCode, RKPayType payType, NSString *msg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    if (stateCode == 0) {
                        [weakSelf requestData];
                    }
                    [MBProgressHUD showError:msg];
                });
            }];

            /*
            //调起微信支付
            NSString *times = [dict objectForKey:@"timestamp"];
            PayReq* req             = [[PayReq alloc] init];
            req.partnerId           = [dict objectForKey:@"partnerid"];
            NSString *pid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"prepayid"]];
            if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                pid = @"123";
            }
            req.prepayId            = pid;
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = times.intValue;
            req.package             = [dict objectForKey:@"package"];
            req.sign                = [dict objectForKey:@"sign"];
//            [WXApi sendReq:req];
            [WXApi sendReq:req completion:^(BOOL success) {
            }];
            */

        }
        else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
        }

    } fail:^{
        [MBProgressHUD hideHUD];

    }];
}
/*
-(void)onResp:(BaseResp *)resp{
    //支付返回结果，实际支付结果需要去微信服务器端查询
    NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
    switch (resp.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            [self requestData];
            break;
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
            break;
    }
}
*/
//微信支付*****************************************************************************************************************
//支付宝支付与支付宝h5支付*****************************************************************************************************************
-(void)doAlih5payPay{
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Charge.getAliOrderh5" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
           // NSString *tradeNO = [[info firstObject] valueForKey:@"orderid"];
           
                [MBProgressHUD hideHUD];
            NSString *urls = [[info firstObject] valueForKey:@"href"];
//                NSString *bodystr = [NSString stringWithFormat:@"充值%@%@",[_seleDic valueForKey:@"coin"],[common name_coin]];
//                NSString *total_amount = [_seleDic valueForKey:@"money"];
//                NSString *WIDout_trade_no = tradeNO;
//                NSString *WIDsubject = [NSString stringWithFormat:@"充值%@",[common name_coin]];
//                NSString *urls = [NSString stringWithFormat:@"%@%@",h5url,bodystr,total_amount,WIDout_trade_no,WIDsubject];
                urls = [urls stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSLog(@"输出参数==%@",urls);
                //
           
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            
            
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

-(void)doAlipayPay {
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]]) {
        [MBProgressHUD showError:@"未安装支付宝"];
        return;
        }
    
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Charge.getAliOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *tradeNO = [[info firstObject] valueForKey:@"orderid"];
         
            NSDictionary *aliSDKParam = @{@"partner":_aliapp_partner,
                                          @"seller_id":_aliapp_seller_id,
                                          @"key":_aliapp_key_ios,
                                          @"tradeNO":tradeNO,
                                          @"notifyURL":[h5url stringByAppendingString:@"/appapi/Pay/notify_ali"],
                                          @"amount":[subdic valueForKey:@"money"],
                                          @"productName":[NSString stringWithFormat:@"%@%@",[subdic valueForKey:@"coin"],[common name_coin]]
            };
            WeakSelf;
            [[YBRechargeType chargeManeger] selAliPayParameter:aliSDKParam complete:^(int stateCode, RKPayType payType, NSString *msg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    if (stateCode == 0) {
                        [weakSelf requestData];
                    }
                    [MBProgressHUD showError:msg];
                });
            }];
            
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
}
/*
- (void)doAlipayPay
{
    NSString *partner = _aliapp_partner;
    NSString *seller =  _aliapp_seller_id;
    NSString *privateKey = _aliapp_key_ios;
    
    
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0){
        [MBProgressHUD showError:@"缺少partner或者seller或者私钥"];
        return;
    }
    
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    //获取订单id
    //将商品信息拼接成字符串
    
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    
    [YBToolClass postNetworkWithUrl:@"Charge.getAliOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *infos = [[info firstObject] valueForKey:@"orderid"];
            order.tradeNO = infos;
            order.notifyURL = [h5url stringByAppendingString:@"/Appapi/Pay/notify_ali"];
            order.amount = [_seleDic valueForKey:@"money"];
            order.productName = [NSString stringWithFormat:@"%@%@",[_seleDic valueForKey:@"coin"],[common name_coin]];
            order.productDescription = @"productDescription";
            //以下配置信息是默认信息,不需要更改.
            order.service = @"mobile.securitypay.pay";
            order.paymentType = @"1";
            order.inputCharset = @"utf-8";
            order.itBPay = @"30m";
            order.showUrl = @"m.alipay.com";
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types,用于快捷支付成功后重新唤起商户应用
            NSString *appScheme = [[NSBundle mainBundle] bundleIdentifier];
            //将商品信息拼接成字符串
            NSString *orderSpec = [order description];
            NSLog(@"orderSpec = %@",orderSpec);
            //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderSpec];
            //将签名成功字符串格式化为订单字符串,请严格按照该格式
            NSString *orderString = nil;
            if (signedString != nil) {
                orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                               orderSpec, signedString, @"RSA"];
                
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSLog(@"reslut = %@",resultDic);
                    NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                    NSLog(@"#######%ld",(long)resultStatus);
                    // NSString *publicKey = alipaypublicKey;
                    NSLog(@"支付状态信息---%ld---%@",resultStatus,[resultDic valueForKey:@"memo"]);
                    // 是否支付成功
                    if (9000 == resultStatus) {
                        
                        [self requestData];
                        
                    }
                }];
            }
        

        }
    } fail:^{
        
    }];
    
    
    
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
