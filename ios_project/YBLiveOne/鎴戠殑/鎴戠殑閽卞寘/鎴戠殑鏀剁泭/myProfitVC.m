//
//  myProfitVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "myProfitVC.h"
#import "profitTypeVC.h"
#import "AuthenticateVC.h"
@interface myProfitVC (){
    UILabel *allVotesL;
    UILabel *nowVotesL;
    UITextField *votesT;
    UILabel *moneyLabel;
    UILabel *typeLabel;
    int cash_rate;
    float cash_take;
    UIButton *inputBtn;
    UILabel *tipsLabel;
    NSDictionary *typeDic;
    UIImageView *seletTypeImgView;
    
    NSDictionary *headerDic;
    int isAuth;
}

@end

@implementation myProfitVC
- (void)rightBtnClick{
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = [NSString stringWithFormat:@"%@/appapi/cash/index&uid=%@&token=%@&lang=%@",h5url,[Config getOwnID],[Config getOwnToken],[RookieTools serviceLang]];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = YZMsg(@"我的收益");
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:YZMsg(@"提现记录") forState:0];
    [self creatUI];
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Cash.GetProfit" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            //获取收益
            nowVotesL.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"votes"]];
//            self.withdraw.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"todaycash"]];
            allVotesL.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"votestotal"]];//收益 魅力值
            cash_rate = [minstr([[info firstObject] valueForKey:@"cash_rate"]) intValue];
            cash_take = [minstr([[info firstObject] valueForKey:@"cash_take"]) floatValue];
            NSString *tips = minstr([[info firstObject] valueForKey:@"tips"]);
            CGFloat height = [[YBToolClass sharedInstance] heightOfString:tips andFont:[UIFont systemFontOfSize:11] andWidth:_window_width*0.7-30];
            tipsLabel.text = tips;
            tipsLabel.height = height;
            NSLog(@"收益数据........%@",info);
        }
    } fail:^{
        
    }];
}
- (void)tapClick{
    [votesT resignFirstResponder];
}
- (void)creatUI{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
    //黄色背景图
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.04, 64+statusbarHeight+10, _window_width*0.92, _window_width*0.92*24/69)];
    backImgView.image = [UIImage imageNamed:@"recharge_背景"];
    [self.view addSubview:backImgView];
    
    for (int i = 0; i < 4; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(backImgView.width/2*(i%2), backImgView.height/4*(i/2+1), backImgView.width/2, backImgView.height/4)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        if (i<2) {
            label.font = [UIFont systemFontOfSize:15];
            if (i == 0) {
                label.text = [NSString stringWithFormat:@"%@%@%@",YZMsg(@"总"),[common name_votes],YZMsg(@"数")];

            }else{
                label.text = [NSString stringWithFormat:@"%@%@%@",YZMsg(@"可提取"),[common name_votes],YZMsg(@"数")];

                [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(backImgView.width/2-0.5, backImgView.height/4, 1, backImgView.height/2) andColor:[UIColor whiteColor] andView:backImgView];
            }
        }else{
            label.font = [UIFont boldSystemFontOfSize:22];
            label.text = @"0";
            if (i == 2) {
                allVotesL = label;
            }else{
                nowVotesL = label;
            }
        }
        [backImgView addSubview:label];
    }
    //输入提现金额的视图
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, backImgView.bottom+10, backImgView.width, backImgView.height)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [self.view addSubview:textView];
//    NSArray *arr = @[[NSString stringWithFormat:@"输入要提取的%@数",[common name_votes]],@"可到账金额"];
    NSArray *arr = @[[NSString stringWithFormat:@"%@%@%@",YZMsg(@"输入要提取的"),[common name_votes],YZMsg(@"数")],YZMsg(@"可到账金额")];

    for (int i = 0; i<2; i++) {
        CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:arr[i] andFont:[UIFont systemFontOfSize:15] andHeight:textView.height/2];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, textView.height/2*i, labelW+20, textView.height/2)];
        label.textColor = RGB_COLOR(@"#333333", 1);
        label.font = [UIFont systemFontOfSize:15];
        label.text = arr[i];
        [textView addSubview:label];
        if (i == 0) {
            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(textView.width*0.05, textView.height/2-0.5, textView.width*0.9, 1) andColor:colorf5 andView:textView];
            votesT = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, textView.width*0.95-label.right, textView.height/2)];
            votesT.textColor = normalColors;
            votesT.font = [UIFont boldSystemFontOfSize:17];
            votesT.placeholder = @"0";
            votesT.keyboardType = UIKeyboardTypeNumberPad;
            [textView addSubview:votesT];
        }else{
            moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, textView.width*0.95-label.right, textView.height/2)];
            moneyLabel.textColor = [UIColor redColor];
            moneyLabel.font = [UIFont boldSystemFontOfSize:17];
            moneyLabel.text = @"¥0.00";
            [textView addSubview:moneyLabel];
        }
    }
    
    //选择提现账户
    
    UIView *typeView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, textView.bottom+10, backImgView.width, 50)];
    typeView.backgroundColor = [UIColor whiteColor];
    typeView.layer.cornerRadius = 5.0;
    typeView.layer.masksToBounds = YES;
    [self.view addSubview:typeView];
    typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, 0, typeView.width*0.95-40, 50)];
    typeLabel.textColor = RGB_COLOR(@"#333333", 1);
    typeLabel.font = [UIFont systemFontOfSize:15];
    typeLabel.text = YZMsg(@"请选择提现账户");
    [typeView addSubview:typeLabel];
    seletTypeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeLabel.left, 15, 20, 20)];
    seletTypeImgView.hidden = YES;
    [typeView addSubview:seletTypeImgView];
    
    UIImageView *rightImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeView.width-30, 18, 14, 14)];
    rightImgView.image = [UIImage imageNamed:@"person_right"];
    rightImgView.userInteractionEnabled = YES;
    [typeView addSubview:rightImgView];

    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, typeView.width, typeView.height);
    [btn addTarget:self action:@selector(selectPayType) forControlEvents:UIControlEventTouchUpInside];
    [typeView addSubview:btn];
    
    inputBtn = [UIButton buttonWithType:0];
    inputBtn.frame = CGRectMake(_window_width*0.15, typeView.bottom + 30, _window_width*0.7, 30);
    inputBtn.backgroundColor = RGB_COLOR(@"#dcdcdc", 1);
    
    [inputBtn setTitle:YZMsg(@"立即提现") forState:0];
    [inputBtn addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
    inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    inputBtn.layer.cornerRadius = 15;
    inputBtn.layer.masksToBounds = YES;
    inputBtn.userInteractionEnabled = NO;
    [self.view addSubview:inputBtn];
    
    tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(inputBtn.left+15, inputBtn.bottom + 15, inputBtn.width-30, 100)];
    tipsLabel.font = [UIFont systemFontOfSize:11];
    tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
    tipsLabel.numberOfLines = 0;
    [self.view addSubview:tipsLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidChangeNotification object:nil];

}
//选择z提现方式
- (void)selectPayType{
    profitTypeVC *vc = [[profitTypeVC alloc]init];
    if (typeDic) {
        vc.selectID = minstr([typeDic valueForKey:@"id"]);
    }else{
        vc.selectID = YZMsg(@"未选择提现方式");
    }
    vc.block = ^(NSDictionary * _Nonnull dic) {
        typeDic = dic;
        seletTypeImgView.hidden = NO;
        typeLabel.x = seletTypeImgView.right + 5;
        int type = [minstr([dic valueForKey:@"type"]) intValue];
        switch (type) {
            case 1:
                seletTypeImgView.image = [UIImage imageNamed:getImagename(@"profit_alipay")];
                typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
            case 2:
                seletTypeImgView.image = [UIImage imageNamed:@"profit_wx"];
                typeLabel.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];

                break;
            case 3:
                seletTypeImgView.image = [UIImage imageNamed:@"profit_card"];
                typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
                
            default:
                break;
        }

    };
    [self.navigationController pushViewController:vc animated:YES];
}
//提交申请
- (void)inputBtnClick{
    if ([[Config getIsUserauth] isEqual:@"0"]) {
        [self renzengalert];
        return;
    }
    if(!typeDic){
        [MBProgressHUD showError:YZMsg(@"请选择提现账号")];
        return;
    }
    NSDictionary *dic = @{@"accountid":minstr([typeDic valueForKey:@"id"]),@"cashvote":votesT.text};
    [YBToolClass postNetworkWithUrl:@"Cash.SetCash" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            votesT.text = @"";
            [self ChangeMoenyLabelValue];
            [MBProgressHUD showError:msg];
            [self requestData];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
}
-(void)renzengalert{
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"您未认证，暂不支持提现") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *goredit = [UIAlertAction actionWithTitle:YZMsg(@"去认证") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self authrequestData];
        [self getOldAuthMessage];
    }];
    [cancel setValue:RGB_COLOR(@"#969696",  1) forKey:@"_titleTextColor"];
    [goredit setValue:normalColors forKey:@"_titleTextColor"];
    [alertControl addAction:cancel];
    [alertControl addAction:goredit];
    [[[YBAppDelegate sharedAppDelegate]topViewController]presentViewController:alertControl animated:YES completion:nil];
}
- (void)authrequestData{
    
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
//
//    NSString *build = [NSString stringWithFormat:@"%@",app_build];
//
//    [YBToolClass postNetworkWithUrl:@"User.GetBaseInfo" andParameter:@{@"ios_version":build} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        if (code == 0) {
//            headerDic = [info firstObject];
//
//            isAuth = [minstr([headerDic valueForKey:@"isauth"]) intValue];
//            if (isAuth == 0) {
//                //未认证
////                [self authclic:nil];
//                [self getOldAuthMessage];
//
//            }else if (isAuth == 1){
//                [MBProgressHUD showError:YZMsg(@"您的认证资料正在飞速审核中")];
//            }else if (isAuth == 3){
//                [MBProgressHUD showError:YZMsg(@"认证失败，请重新认证")];
//                [self getOldAuthMessage];
////
////                if ([minstr([headerDic valueForKey:@"oldauth"]) isEqual:@"1"]) {
////                }else{
////                    [self authclic:nil];
////                }
//            }
//
//        }
//
//    } fail:^{
//
//    }];
}
- (void)getOldAuthMessage{
    AuthenticateVC *auth = [[AuthenticateVC alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:auth animated:YES];

}
- (void)ChangeMoenyLabelValue{
    //floorf 向下取整(当取到8位9的时候就出问题了)
    
    NSString *textstr = votesT.text;
    if (textstr.length > 9) {
        textstr = [textstr substringToIndex:9];
    }
    votesT.text = textstr;
  
  
    if (votesT.text.length > 0) {
        inputBtn.userInteractionEnabled = YES;
        [inputBtn setBackgroundColor:normalColors];
        NSString *coincountstr = [self tt_ClientFeeCalculationMethodWithString:textstr with:[NSString stringWithFormat:@"%d",cash_rate] andscale:0];
        NSString *resultValue = [self tt_ClientFeeCalculationMethodWithString:coincountstr with:[NSString stringWithFormat:@"%.2f",(100 - cash_take)/100] andscale:2];
        
        moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",[resultValue doubleValue]];
    }else{
        inputBtn.userInteractionEnabled = NO;
        [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
        moneyLabel.text = @"¥0.00";
    }
    
}

/**
 客户端手续费计算方法并解决金额精度问题
 @param amountValue 用户输入的具体金额
 @param rateValue   后台给予的费率
 @return            客户端计算出的手续费
 */
-(NSString *)tt_ClientFeeCalculationMethodWithString:(NSString *)amountValue with:(NSString *)rateValue andscale:(int)scales{
    /*手续费计算精度问题解决：NSDecimalNumber
     加: decimalNumberByAdding
     减: decimalNumberBySubtracting：
     乘: decimalNumberByMultiplyingBy：
     除: decimalNumberByDividingBy：
     */
    rateValue = [NSString stringWithFormat:@"%@%%",rateValue];
    NSDecimalNumber *rateValueNumber = [NSDecimalNumber decimalNumberWithString:rateValue];

    //输入金额
    NSDecimalNumber *amountValueNumber = [NSDecimalNumber decimalNumberWithString:amountValue];
    NSDecimalNumber * product = [NSDecimalNumber decimalNumberWithString:@"0.00"];
   
    if (scales == 0) {
        product = [amountValueNumber decimalNumberByDividingBy:rateValueNumber];
    }else{
        product = [amountValueNumber decimalNumberByMultiplyingBy:rateValueNumber];
    }
    /*四舍五入精确度问题解决：NSDecimalNumberHandler
     讲述下参数的含义:
     RoundingMode: 简单讲就是你要四舍五入操作的标准.
     scale : 需要保留的精度。
     raiseOnExactness : 为YES时在处理精确时如果有错误，就会抛出异常。
     raiseOnOverflow  : YES时在计算精度向上溢出时会抛出异常，否则返回。
     raiseOnUnderflow : YES时在计算精度向下溢出时会抛出异常，否则返回.
     raiseOnDivideByZero : YES时。当除以0时会抛出异常，否则返回。
     */
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                                      scale:scales
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSDecimalNumber *tempStr =[product decimalNumberByRoundingAccordingToBehavior:roundingBehavior] ;
    
    return [tempStr stringValue];
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
