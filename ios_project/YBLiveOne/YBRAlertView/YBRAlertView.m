//
//  YBAlertView.m
//  yunbaolive
//
//  Created by ybRRR on 2019/12/9.
//  Copyright © 2019 cat. All rights reserved.
//

#import "YBRAlertView.h"


@implementation YBRAlertView

-(instancetype)initWithTitle:(NSString *)title Msg:(NSString *)msg LeftMsg:(NSString *)leftMsg RightMsg:(NSString *)rightMsg PlaceHodler:(NSString *)text Style:(YBAlertStyle)Style{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = RGB_COLOR(@"#000000", 0.6);
       CGFloat hei = [[YBToolClass sharedInstance] heightOfString:msg andFont:[UIFont systemFontOfSize:14] andWidth:_window_width - 188];
        [self creatUI:hei andTitle:title Msg:msg LeftMsg:leftMsg RightMsg:rightMsg];
    }
    return self;
}
-(void)creatUI:(CGFloat)hei andTitle:(NSString *)title Msg:(NSString *)msg LeftMsg:(NSString *)leftMsg RightMsg:(NSString *)rightMsg{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(70, (_window_height - 123-hei)/2, _window_width - 140, 123 + hei)];
    [self addSubview:_bgView];
  
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 10;
    _bgView.layer.masksToBounds = YES;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, _bgView.width, 30)];
    [_bgView addSubview:_titleLabel];
   
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.text = title;
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, _titleLabel.bottom + 7, _bgView.width - 48, hei)];
    [_bgView addSubview:_contentLabel];
   
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.text = msg;
    
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(0, _contentLabel.bottom + 25, _bgView.width, 1)];
    lineview.backgroundColor = RGB_COLOR(@"#F0F0F0", 1);
    [_bgView addSubview:lineview];

    
    
    _cancleButton = [UIButton buttonWithType:0];
    _cancleButton.frame = CGRectMake(0, lineview.bottom, _bgView.width/2 - 0.5, 44);
    [_bgView addSubview:_cancleButton];
    
    [_cancleButton setTitle:leftMsg forState:0];
    _cancleButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancleButton setTitleColor:RGB_COLOR(@"#969696", 1) forState:0];
    [_cancleButton addTarget:self action:@selector(cancliclick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *shulineview = [[UIView alloc]initWithFrame:CGRectMake(_cancleButton.right, lineview.bottom, 1, 44)];
    [_bgView addSubview:shulineview];
    shulineview.backgroundColor = RGB_COLOR(@"#F0F0F0", 1);
    
    _sureButton = [UIButton buttonWithType:0];
    _sureButton.frame = CGRectMake(shulineview.right, lineview.bottom, _bgView.width/2 - 0.5, 44);
    _sureButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_bgView addSubview:_sureButton];
    [_sureButton setTitle:rightMsg forState:0];
    [_sureButton setTitleColor:normalColors forState:0];
    [_sureButton addTarget:self action:@selector(sureclick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)sureclick{
    if (self.actionEvent) {
        self.actionEvent(@"1",@"0");
    }
}
-(void)cancliclick{
    if (self.actionEvent) {
        self.actionEvent(@"2",@"");
    }
}
- (IBAction)nextBtnClick:(UIButton *)sender {
    if (self.actionEvent) {
        self.actionEvent(@"0",@"0");
    }
}
- (IBAction)sureBtnClick:(id)sender {
    
        if (self.actionEvent) {
            self.actionEvent(@"1",@"0");
        }

}

- (IBAction)closeBtnClick:(UIButton *)sender {
    if (self.actionEvent) {
        self.actionEvent(@"2",@"");
    }
}

@end
