//
//  RegAlertView.m
//  yunbaolive
//
//  Created by YB007 on 2020/4/29.
//  Copyright © 2020 cat. All rights reserved.
//

#import "RegAlertView.h"



@implementation RegAlertView



+(instancetype)showRegAler:(NSDictionary *)dataDic complete:(RegAlertBlock)complete;{
    RegAlertView *regView = [[[NSBundle mainBundle]loadNibNamed:@"RegAlertView" owner:nil options:nil]objectAtIndex:0];
    regView.regAlertEvent = complete;
    [regView setupView:dataDic];
    return regView;
}
-(void)setupView:(NSDictionary *)dataDic {
    
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    self.backgroundColor = RGB_COLOR(@"#000000", 0.4);
    [[YBAppDelegate sharedAppDelegate].topViewController.view addSubview:self];
    

    _titleL.text = minstr([dataDic valueForKey:@"title"]);
    _contentL.text = [dataDic valueForKey:@"content"];
    _contentL.textColor = RGB_COLOR(@"#323232", 1);
    _contentL.font = SYS_Font(15);
    _contentL.numberOfLines = 0;
    NSArray *ppA = [NSArray arrayWithArray:[dataDic valueForKey:@"message"]];
    
    NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",_contentL.text]];
    [textAtt addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#323232", 1) range:textAtt.yy_rangeOfAll];
    
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
    _contentL.attributedText = textAtt;
    
    
}
-(void)dismissView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}
- (IBAction)clickCancleBtn:(id)sender {
    [self dismissView];
    if (self.regAlertEvent) {
        self.regAlertEvent(-1);
    }
}

- (IBAction)clickSureBtn:(id)sender {
    [self dismissView];
    if (self.regAlertEvent) {
        self.regAlertEvent(0);
    }
}


@end
