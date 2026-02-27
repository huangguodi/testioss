//
//  IdentityAuthVC.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/11/26.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "IdentityAuthVC.h"

@interface IdentityAuthVC ()
{
    NSArray *placeHolder;
    NSArray *arr;
    UITextField *_nameField;
    UITextField *_mobileField;
    UITextField *_cardnoField;
    
    UIView *reBackView;
}
@end

@implementation IdentityAuthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBA(245, 245, 245, 1);
    arr = @[YZMsg(@"真实姓名"),YZMsg(@"身份证号"),YZMsg(@"手机号码")];
    placeHolder = @[YZMsg(@"请填写您的真实姓名"),YZMsg(@"请填写您的身份证号"),YZMsg(@"请填写您的手机号码")];

    //status：-1 没有提交认证  0 审核中  1  通过  2 拒绝
    if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"-1"]) {
        self.titleL.text = YZMsg(@"实名认证");
        [self createNOAuth];
    }else{
        self.titleL.text = YZMsg(@"我的认证");
        [self createHaveAuth];

    }
    
}
#pragma mark =我要认证=
-(void)createNOAuth{
    UILabel *titleLb = [[UILabel alloc]init];
    //titleLb.frame = CGRectMake(12, 64+statusbarHeight+10, _window_width-24, 30);
    titleLb.font = [UIFont systemFontOfSize:13];
    titleLb.textColor = UIColor.blackColor;
    titleLb.text = YZMsg(@"以下信息均为必填项，为保证您的利益，请如实填写");
    titleLb.numberOfLines = 0;
    [self.view addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).offset(-24);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.top.equalTo(self.view.mas_top).offset(64+statusbarHeight+10);
    }];
    
    [self.view layoutIfNeeded];
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = UIColor.whiteColor;
    backView.frame = CGRectMake(12, titleLb.bottom+10, _window_width-24, 176);
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    [self.view addSubview:backView];
    for (int i = 0; i < arr.count; i++) {
        UILabel *lb = [[UILabel alloc]init];
        lb.frame = CGRectMake(12, i*176/3, 70, 176/3);
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = UIColor.blackColor;
        lb.text = arr[i];
        [backView addSubview:lb];
        
        UITextField *tf = [[UITextField alloc]init];
        tf.frame = CGRectMake(lb.right+5, lb.top, backView.width-lb.right-10, lb.height);
        tf.placeholder = placeHolder[i];
        tf.font = [UIFont systemFontOfSize:14];
        tf.textColor = UIColor.blackColor;
        [backView addSubview:tf];
        if (i == 0) {
            _nameField  = tf;
        }else if (i == 1){
            _cardnoField = tf;
        }else{
            _mobileField = tf;
        }
    }
    for (int i = 0; i < arr.count; i++) {
        if (i != 2) {
            [[YBToolClass sharedInstance]lineViewWithFrame:CGRectMake(12, (i+1)*176/3, backView.width-24, 1) andColor:RGBA(245, 245, 245, 1) andView:backView];
        }
    }
    
    UIButton *subBtn = [UIButton buttonWithType:0];
    subBtn.frame = CGRectMake(backView.left+20, backView.bottom+40, backView.width-40, 44);
    subBtn.layer.cornerRadius = 22;
    subBtn.layer.masksToBounds = YES;
    CAGradientLayer*gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame=subBtn.bounds;
    gradientLayer.startPoint=CGPointMake(0,0);
    gradientLayer.endPoint=CGPointMake(1,0);
    gradientLayer.locations = @[@(0),@(1.0)];//渐变点
    [gradientLayer setColors:@[(id)[RGBA(178,1,253,1) CGColor],(id)[RGBA(115,3,251,1) CGColor]]];//渐变数组
    [subBtn.layer addSublayer:gradientLayer];
    [subBtn setTitle:YZMsg(@"提交认证") forState:0];
    [subBtn setTitleColor:UIColor.whiteColor forState:0];
    subBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [subBtn addTarget:self action:@selector(subBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subBtn];
    
}
-(void)subBtnClick{

    if (_nameField.text.length < 1) {
        [MBProgressHUD showError:placeHolder[0]];
        return;
    }else if (_cardnoField.text.length < 1){
        [MBProgressHUD showError:placeHolder[1]];
        return;
    }else if (_mobileField.text.length < 1){
        [MBProgressHUD showError:placeHolder[2]];
        return;
    }
    NSDictionary *parDic = @{@"uid":[Config getOwnID],@"token":[Config getOwnToken],@"name":_nameField.text,@"cardno":_cardnoField.text,@"mobile":_mobileField.text};
    [YBToolClass postNetworkWithUrl:@"Auth.setUserAuth" andParameter:parDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [[YBAppDelegate sharedAppDelegate]popViewController:YES];
        }else{
        }
        [MBProgressHUD showError:msg];

        } fail:^{
        }];

}
#pragma mark =我的认证=
-(void)createHaveAuth{
    UILabel *titleLb = [[UILabel alloc]init];
    //titleLb.frame = CGRectMake(12, 64+statusbarHeight+10, _window_width-24, 30);
    titleLb.font = [UIFont systemFontOfSize:13];
    titleLb.textColor = UIColor.blackColor;
    titleLb.text = YZMsg(@"以下信息均为必填项，为保证您的利益，请如实填写");
    titleLb.numberOfLines = 0;
    [self.view addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).offset(-24);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.top.equalTo(self.view.mas_top).offset(64+statusbarHeight+10);
    }];
    [self.view layoutIfNeeded];
    //status：-1 没有提交认证  0 审核中  1  通过  2 拒绝

    reBackView = [[UIView alloc]init];
    reBackView.backgroundColor = UIColor.whiteColor;
    if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"1"]) {
        reBackView.frame = CGRectMake(12, 64+statusbarHeight+ShowDiff+10, _window_width-24, 150);
        titleLb.hidden = YES;
    }else{
        reBackView.frame = CGRectMake(12, titleLb.bottom+10, _window_width-24, 150);

    }
    reBackView.layer.cornerRadius = 10;
    reBackView.layer.masksToBounds = YES;
    [self.view addSubview:reBackView];
    for (int i = 0; i < arr.count; i++) {
        UILabel *lb = [[UILabel alloc]init];
        lb.frame = CGRectMake(12, i*150/3, 70, 150/3);
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = UIColor.blackColor;
        lb.text = arr[i];
        [reBackView addSubview:lb];
        
        UITextField *tf  = [[UITextField alloc]init];
        tf.frame = CGRectMake(lb.right+5, lb.top, reBackView.width-lb.right-10, lb.height);
        tf.font = [UIFont systemFontOfSize:14];
        tf.textColor = UIColor.blackColor;
        tf.placeholder = placeHolder[i];
        [reBackView addSubview:tf];
        if (i == 0) {
            tf.text = minstr([_authDic valueForKey:@"name"]);
            _nameField  = tf;
        }else if (i == 1){
            tf.text = minstr([_authDic valueForKey:@"cardno"]);
            _cardnoField = tf;
        }else{
            tf.text = minstr([_authDic valueForKey:@"mobile"]);
            _mobileField = tf;
        }
    }
    UIButton *subBtn = [UIButton buttonWithType:0];
    subBtn.frame = CGRectMake(reBackView.left+20, reBackView.bottom+40, reBackView.width-40, 44);
    subBtn.layer.cornerRadius = 22;
    subBtn.layer.masksToBounds = YES;
    subBtn.hidden = YES;
    if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"0"]) {
        [subBtn setTitle:YZMsg(@"审核中") forState:0];
        [subBtn setBackgroundColor:UIColor.grayColor];
        subBtn.hidden = NO;
        _nameField.userInteractionEnabled = NO;
        _cardnoField.userInteractionEnabled = NO;
        _mobileField.userInteractionEnabled = NO;
    }else if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"2"]){
        subBtn.hidden = NO;

        CAGradientLayer*gradientLayer =  [CAGradientLayer layer];
        gradientLayer.frame=subBtn.bounds;
        gradientLayer.startPoint=CGPointMake(0,0);
        gradientLayer.endPoint=CGPointMake(1,0);
        gradientLayer.locations = @[@(0),@(1.0)];//渐变点
        [gradientLayer setColors:@[(id)[RGBA(178,1,253,1) CGColor],(id)[RGBA(115,3,251,1) CGColor]]];//渐变数组
        [subBtn.layer addSublayer:gradientLayer];
        [subBtn setTitle:YZMsg(@"审核失败，请重新上传") forState:0];
        [subBtn addTarget:self action:@selector(subBtnClick) forControlEvents:UIControlEventTouchUpInside];

    }else{
        _nameField.userInteractionEnabled = NO;
        _cardnoField.userInteractionEnabled = NO;
        _mobileField.userInteractionEnabled = NO;

    }
    [subBtn setTitleColor:UIColor.whiteColor forState:0];
    subBtn.titleLabel.font = [UIFont systemFontOfSize:14];

    [self.view addSubview:subBtn];

}
@end
