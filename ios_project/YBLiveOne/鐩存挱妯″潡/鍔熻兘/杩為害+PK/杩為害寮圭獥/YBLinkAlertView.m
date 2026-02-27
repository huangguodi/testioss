//
//  YBLinkAlertView.m
//  yunbaolive
//
//  Created by Boom on 2018/10/29.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "YBLinkAlertView.h"

@interface YBLinkAlertView()

@property(nonatomic,strong)NSString *applyUid;

@end
@implementation YBLinkAlertView{
    NSDictionary *userMsg;
    UIView *whiteView;
    
}

- (instancetype)initWithFrame:(CGRect)frame andUserMsg:(NSDictionary *)dic{
    self = [self initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    userMsg = dic;
    if (self) {
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    self.isHostToHost = NO;
    if (![YBToolClass checkNull:minstr([userMsg valueForKey:@"pkuid"])]) {
        self.isHostToHost = YES;
    }
    self.applyUid = minstr([userMsg valueForKey:@"uid"]);
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*(95/750.00000), _window_height/2-100, _window_width*(560/750.00000), 200)];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 5.0;
    whiteView.layer.masksToBounds = YES;
    [self addSubview:whiteView];
    UIImageView *headerImgview =[[ UIImageView alloc]initWithFrame:CGRectMake(whiteView.width/2-22.5, 15, 45, 45)];
    [headerImgview sd_setImageWithURL:[NSURL URLWithString:minstr([userMsg valueForKey:@"uhead"])]];
    headerImgview.layer.cornerRadius = 22.5;
    headerImgview.layer.masksToBounds = YES;
    [whiteView addSubview:headerImgview];
    
    //UILabel *nameL = [[UILabel alloc]initWithFrame:CGRectMake(0, headerImgview.bottom, whiteView.width, 29)];
    UILabel *nameL = [[UILabel alloc]init];
    nameL.textColor = RGB_COLOR(@"#646566", 1);
    nameL.font = [UIFont boldSystemFontOfSize:15];
    nameL.textAlignment = NSTextAlignmentCenter;
    nameL.text = minstr([userMsg valueForKey:@"uname"]);
    [whiteView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerImgview.mas_bottom);
        make.height.mas_equalTo(29);
        make.centerX.equalTo(whiteView.mas_centerX).offset(-10);
    }];
    
    
    //UIImageView *sexImgView =[[ UIImageView alloc]initWithFrame:CGRectMake(whiteView.width/2-25, nameL.bottom, 18, 15)];
    UIImageView *sexImgView = [[UIImageView alloc]init];
    if ([minstr([userMsg valueForKey:@"sex"]) isEqual:@"1"]) {
        sexImgView.image = [UIImage imageNamed:@"bullet-男"];
    }else{
        sexImgView.image = [UIImage imageNamed:@"bullet-女"];
    }
    [whiteView addSubview:sexImgView];
    [sexImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(15);
        make.centerY.mas_equalTo(nameL.mas_centerY);
        make.left.equalTo(nameL.mas_right).offset(1);
    }];
    
    /*
    UIImageView *levelImgView =[[ UIImageView alloc]initWithFrame:CGRectMake(sexImgView.right+5, sexImgView.top, 30, 15)];
    if ([userMsg valueForKey:@"level_anchor"]) {
        NSDictionary *levelDic = [common getAnchorLevelMessage:minstr([userMsg valueForKey:@"level_anchor"])];
        [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
    }else{
        NSDictionary *levelDic = [common getUserLevelMessage:minstr([userMsg valueForKey:@"level"])];
        [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
    }
    [whiteView addSubview:levelImgView];
    */
    //_timeL = [[UILabel alloc]initWithFrame:CGRectMake(0, sexImgView.bottom, whiteView.width, 41)];
    _timeL = [[UILabel alloc]init];
    _timeL.textAlignment = NSTextAlignmentCenter;
    _timeL.adjustsFontSizeToFitWidth = YES;
    _timeL.textColor = RGB_COLOR(@"#636465", 1);
    [whiteView addSubview:_timeL];
    [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.equalTo(whiteView);
        make.top.equalTo(nameL.mas_bottom).offset(12);
    }];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, whiteView.height-51, whiteView.width, 1) andColor:RGB_COLOR(@"#e3e4e5", 1) andView:whiteView];
    
    NSArray *btnTitleArr = @[YZMsg(@"拒绝"),YZMsg(@"接受")];
    for (int i = 0; i< btnTitleArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake((whiteView.width/2+0.5)*i, whiteView.height-50, whiteView.width/2-0.5, 50);
        btn.tag = i+1000;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:btnTitleArr[i] forState:0];
        if (i == 0) {
            [btn setTitleColor:RGB_COLOR(@"#636465", 1) forState:0];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(btn.right, btn.top, 1, btn.height) andColor:RGB_COLOR(@"#e3e4e5", 1) andView:whiteView];
        }else{
            [btn setTitleColor:Pink_Cor forState:0];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        }
        
        [whiteView addSubview:btn];
    }
}
- (void)btnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        self.linkAlertEvent(NO,self.isHostToHost);
    }else{
        self.linkAlertEvent(YES,self.isHostToHost);
    }
    [UIView animateWithDuration:0.3 animations:^{
        whiteView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)show{
    [UIView animateWithDuration:0.3 animations:^{
        whiteView.transform = CGAffineTransformMakeScale(1, 1);
    }completion:^(BOOL finished) {
    }];

}
@end
