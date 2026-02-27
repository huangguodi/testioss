//
//  TChatAlertView.m
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/8.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "TChatAlertView.h"

@implementation TChatAlertView

- (instancetype)initWithFrame:(CGRect)frame andScreenFrame:(CGRect)screenFrame andtype:(int)type anddration:(int)dration;
{
    self = [super initWithFrame:frame];
    if(self){
        if (type == 0) {
            [self setupViews:screenFrame];
        }else if(type == 1){
            [self creatcopyUI:screenFrame];
        }else  if(type == 2 ){
            [self creatremoveUI:screenFrame andduration:dration];
        }
       
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapclick)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupViews:(CGRect)frame
{
    CGFloat hei = 32;
    CGFloat wid = 80;
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - hei, wid,hei)];
    bgView.image = [UIImage imageNamed:@"tchabgview"];
    bgView.userInteractionEnabled = YES;
    [self addSubview:bgView];
    
    UIButton *copyBtn = [UIButton buttonWithType:0];
    copyBtn.frame = CGRectMake(0, 0, wid/2 - 0.5, hei - 5);
    [copyBtn setTitle:YZMsg(@"复制") forState:0];
    copyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [copyBtn setTitleColor:RGB_COLOR(@"#FFFFFF", 1) forState:0];
    [bgView addSubview:copyBtn];
    [copyBtn addTarget:self action:@selector(copyclick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(copyBtn.right, 8.5, 1, 10)];
    lineView.backgroundColor = RGB_COLOR(@"#BFBFBF", 1);
    [bgView addSubview:lineView];
    
    UIButton *removeBtn = [UIButton buttonWithType:0];
    removeBtn.frame = CGRectMake(lineView.right, 0, wid/2 - 0.5, hei - 5);
    [removeBtn setTitle:YZMsg(@"撤回") forState:0];
    removeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [removeBtn setTitleColor:RGB_COLOR(@"#FFFFFF", 1) forState:0];
    [bgView addSubview:removeBtn];
    [removeBtn addTarget:self action:@selector(removeclick) forControlEvents:UIControlEventTouchUpInside];
}
- (void)creatcopyUI:(CGRect)frame{
    CGFloat hei = 31;
    CGFloat wid = 40;
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - hei, wid,hei)];
    bgView.image = [UIImage imageNamed:@"tchatsingleview"];
    bgView.userInteractionEnabled = YES;
    [self addSubview:bgView];
    
    UIButton *copyBtn = [UIButton buttonWithType:0];
    copyBtn.frame = CGRectMake(0, 0, wid, hei - 5);
    [copyBtn setTitle:YZMsg(@"复制") forState:0];
    copyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [copyBtn setTitleColor:RGB_COLOR(@"#FFFFFF", 1) forState:0];
    [bgView addSubview:copyBtn];
    [copyBtn addTarget:self action:@selector(copyclick) forControlEvents:UIControlEventTouchUpInside];
}
- (void)creatremoveUI:(CGRect)frame andduration:(int)duration{
    CGFloat hei = 31;
    CGFloat wid = 40;
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + duration, frame.origin.y - hei, wid,hei)];
    bgView.image = [UIImage imageNamed:@"tchatsingleview"];
    bgView.userInteractionEnabled = YES;
    [self addSubview:bgView];
    
    UIButton *removeBtn = [UIButton buttonWithType:0];
    removeBtn.frame = CGRectMake(0, 0, wid, hei - 5);
    [removeBtn setTitle:YZMsg(@"撤回") forState:0];
    removeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [removeBtn setTitleColor:RGB_COLOR(@"#FFFFFF", 1) forState:0];
    [bgView addSubview:removeBtn];
    [removeBtn addTarget:self action:@selector(removeclick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)copyclick{
    if (self.block) {
        self.block(0);
    }
}
-(void)removeclick{
    if (self.block){
        self.block(1);
    }
}
-(void)tapclick{
    if (self.block){
        self.block(2);
    }
}
@end
