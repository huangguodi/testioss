//
//  YBUserScreenView.m
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "YBUserScreenView.h"

@implementation YBUserScreenView

{
    UIView *whiteView;
    NSMutableArray *sexBtnarray;
    NSMutableArray *typeBtnarray;
    NSString *_sexStr;
    NSString *_typeStr;
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = RGB_COLOR(@"#000000", 0.2);
        _sexStr = @"0";
        _typeStr = @"0";
        sexBtnarray = [NSMutableArray array];
        typeBtnarray = [NSMutableArray array];
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 160+ShowDiff)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    whiteView.layer.mask = [[YBToolClass sharedInstance] setViewLeftTop:20 andRightTop:20 andView:whiteView];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(28, 17, 100, 18)];
//    label.text = YZMsg(@"");
//    label.font = SYS_Font(12);
//    label.textColor = color32;
//    [whiteView addSubview:label];
    
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(whiteView.width-52, 0, 52, 52);
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    [closeBtn addTarget:self action:@selector(closebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:closeBtn];
   
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(28, 17, 200, 18)];
    label2.text = YZMsg(@"用户类型");
    label2.font = SYS_Font(12);
    label2.textColor = color32;
    [whiteView addSubview:label2];
    NSArray *titleArray2 = @[YZMsg(@"全部"),YZMsg(@"已认证"),YZMsg(@"未认证")];
    CGFloat btnWidth = 60;
    int btnFont = 11;
    if (![lagType isEqual:ZH_CN]) {
        btnWidth = 96;
        btnFont = 10;
    }
    CGFloat speace2 = (_window_width-btnWidth*3)/4;
    for (int i = 0; i < titleArray2.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(speace2+i*(btnWidth+speace2), label2.bottom+11, btnWidth, 26);
        btn.layer.cornerRadius = 13;
        btn.layer.masksToBounds = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"筛选-未选中"] forState:0];
        [btn setBackgroundImage:[UIImage imageNamed:@"screen_sel"] forState:UIControlStateSelected];
        [btn setTitle:titleArray2[i] forState:0];
        [btn setTitle:titleArray2[i] forState:UIControlStateSelected];
        btn.clipsToBounds = YES;
        btn.titleLabel.font = SYS_Font(btnFont);
        [btn setTitleColor:color96 forState:0];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
        btn.tag = 2000+i;
        [whiteView addSubview:btn];
        [typeBtnarray addObject:btn];
    }
    UIButton *screenBtn = [UIButton buttonWithType:0];
    screenBtn.frame = CGRectMake(38, label2.bottom+11+26+20, _window_width-38*2, 40);
    screenBtn.layer.cornerRadius = 20;
    screenBtn.layer.masksToBounds = YES;
    [screenBtn setBackgroundColor:normalColors];
    [screenBtn setTitle:YZMsg(@"确定") forState:0];
    screenBtn.titleLabel.font = SYS_Font(15);
    [screenBtn addTarget:self action:@selector(screenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:screenBtn];
}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height-160-ShowDiff;
    }];

}
- (void)closebtnClick{
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height;
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];

}

- (void)typeBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in typeBtnarray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    if (sender.tag == 2000) {
        _typeStr = @"1";
    }else if(sender.tag == 2001){
        _typeStr = @"3";
    }else{
        _typeStr = @"2";
    }
   
}
- (void)screenBtnClick{
    [self closebtnClick];
    if (self.block) {
        NSDictionary *dic = @{
                              @"type":_typeStr
                              };
        self.block(dic);
    }
}

@end
