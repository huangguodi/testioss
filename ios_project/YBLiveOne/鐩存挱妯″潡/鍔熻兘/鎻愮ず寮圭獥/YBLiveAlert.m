//
//  YBLiveAlert.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/6.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBLiveAlert.h"

@interface YBLiveAlert()
{
    NSDictionary *_contentDic;
}
@end

@implementation YBLiveAlert

- (void)awakeFromNib {
    [super awakeFromNib];
    //有标题默认值
//    _titleHeight.constant = 25;
//    _contentTop.constant = 25;
    
    //无标题默认
    _titleHeight.constant = 0;
    _contentTop.constant = 0;
    
    //默认色值
    _titleL.textColor = _contentL.textColor = RGB_COLOR(@"#323232", 1);
    _contentL.font = SYS_Font(14);
    _contentL.numberOfLines = 0;
    _contentL.textAlignment = NSTextAlignmentCenter;
    
    [_cancleBtn setTitleColor:RGB_COLOR(@"#969696", 1) forState:0];//c9c9c9
    [_sureBtn setTitleColor:Pink_Cor forState:0];//RGB_COLOR(@"#fb483a", 1)
}

+(instancetype)showAlertView:(NSDictionary *)contentDic complete:(YBAlertBlock)complete;{
    YBLiveAlert *aletView = [[[NSBundle mainBundle]loadNibNamed:@"YBLiveAlert" owner:nil options:nil]objectAtIndex:0];
    if (complete) {
        aletView.ybAlertEvent = ^(int eventType) {
            complete(eventType);
        };
    }
    [aletView setContent:contentDic];
    return aletView;
}

-(void)setContent:(NSDictionary *)contentDic{
    self.frame = [UIScreen mainScreen].bounds;
    
    _contentDic = contentDic;
    
    _titleHeight.constant = 0;
    _contentTop.constant = 0;
    if (![YBToolClass checkNull:minstr([_contentDic valueForKey:@"title"])]) {
        _titleHeight.constant = 25;
        _contentTop.constant = 15;
        _titleL.text = minstr([_contentDic valueForKey:@"title"]);
    }
    _contentL.text = minstr([_contentDic valueForKey:@"msg"]);
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",_contentL.text]];
    
    if ([minstr([_contentDic valueForKey:@"msg"]) containsString:@"[rich]"]) {
        //说明是富文本
        NSRange richRange = [_contentL.text rangeOfString:@"[rich]"];
       
        UIImage *image = [UIImage imageNamed:minstr([_contentDic valueForKey:@"richImg"])];
        NSMutableAttributedString *attachment = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(13, 13) alignToFont:SYS_Font(14) alignment:(YYTextVerticalAlignment)YYTextVerticalAlignmentCenter];
        //'richImg'替换[rich]
        [introText replaceCharactersInRange:richRange withAttributedString:attachment];
    }
    introText.yy_font = SYS_Font(14);
    introText.yy_lineSpacing = 8;
    introText.yy_alignment = NSTextAlignmentCenter;
    _contentL.attributedText = introText;
    //计算content高度
    CGSize introSize = CGSizeMake(_bgView.width*0.8, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    _contentL.textLayout = layout;
    CGFloat introHeight = layout.textBoundingSize.height;
    _contentHeight.constant = introHeight;
    
    if (![YBToolClass checkNull:minstr([_contentDic valueForKey:@"left"])]) {
        _vLineL.hidden = NO;
        _cancleBtn.hidden = NO;
        [_cancleBtn setTitle:minstr([_contentDic valueForKey:@"left"]) forState:0];
    }else {
        _vLineL.hidden = YES;
        _cancleBtn.hidden = YES;
        [_sureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.bottom.equalTo(_bgView);
            make.height.mas_equalTo(40);
        }];
    }
    
    [_sureBtn setTitle:minstr([_contentDic valueForKey:@"right"]) forState:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show];
    });
    
}
-(void)show {
    /*
    for (UIView *view in [UIApplication sharedApplication].delegate.window.subviews) {
        if ([view isKindOfClass:[YBAlertView class]]) {
            [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [view removeFromSuperview];
        }
    }*/
    
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    [self changeLayer];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = RGB_COLOR(@"#000000", 0.2);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)setAlertFrom:(AlertFrom)alertFrom{
    _alertFrom = alertFrom;
    [self changeLayer];
}
-(void)changeLayer {
//    [PublicObj layoutWindowPopLayer];
}

-(void)dismiss {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}

//左边
- (IBAction)clikcCancelBtn:(UIButton *)sender {
    if (!_forbidSureDismiss) {
        [self dismiss];
    }
    if (self.ybAlertEvent) {
        self.ybAlertEvent(0);
    }
}

//右边
- (IBAction)clikcSureBtn:(UIButton *)sender {
    [self dismiss];
    if (self.ybAlertEvent) {
        self.ybAlertEvent(1);
    }
}

@end
