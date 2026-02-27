//
//  Loginbonus.m
//  YBLive
//
//  Created by Rookie on 2017/4/1.
//  Copyright © 2017年 cat. All rights reserved.
//

#import "Loginbonus.h"
#import "LogFirstCell.h"
#import "LogFirstCell2.h"
#import <YYText/YYLabel.h>
#import <YYText/NSAttributedString+YYText.h>

static NSString* IDENTIFIER = @"collectionCell";

static NSString *IDENTIFIER2 = @"collectionCell2";

@interface Loginbonus ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    CADisplayLink *_link;
    LogFirstCell *selectCell;
    LogFirstCell2 *selectCell2;
    UIImageView *sevendayimageview;
    NSString *logDayCount;

    NSString *logDay;
    NSArray *numArr ;
    UIView *whiteView;
    UIImageView *backImg;
    
    UIView *firtBackView;

}
@property (nonatomic,strong) NSArray *arrays;

@end

@implementation Loginbonus
//#define speace 8*_window_width/375
#define itemWidth 58
#define itemHeight 75
#define speace ((_window_width*0.96*0.7)-itemWidth*4)/4

/******************  登录奖励 ->  ********************/

-(instancetype)initWithFrame:(CGRect)frame AndNSArray:(NSArray *)arrays AndDay:(NSString *)day andDayCount:(NSString *)dayCount{
    
    self = [super initWithFrame:frame];
    if (self) {
        _arrays = arrays;
        logDay = day;
        logDayCount = dayCount;
//        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        firtBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        firtBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self addSubview:firtBackView];

        self.backgroundColor = [UIColor clearColor];

        [self firstLog:frame];
    }
    return self;
    
}

-(void)firstLog:(CGRect)frame {
    CGFloat height = _window_width *0.9*26/66.00+80+(_window_width *0.9*0.88 - 30)/4*(140/116.00)*2.5;

    

    backImg = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.02, -_window_height, _window_width*0.96, height)];
    backImg.userInteractionEnabled = YES;
    backImg.image = [UIImage imageNamed:getImagename(@"loginbonus_bg")];
    [self addSubview:backImg];
    
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(backImg.width*0.8, 0, 30, 30);
    [btn setImage:[UIImage imageNamed:@"loginclose"] forState:0];
    [btn addTarget:self action:@selector(cancelLQ) forControlEvents:UIControlEventTouchUpInside];
    [backImg addSubview:btn];

    CGFloat fcW = backImg.width;
    CGFloat fcH = backImg.height;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing =5;

    _firstCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(fcW *0.15 , backImg.height*0.4, fcW*0.7, fcH *0.4) collectionViewLayout:layout];
    _firstCollection.dataSource = self;
    _firstCollection.delegate = self;

    UINib *nib = [UINib nibWithNibName:@"LogFirstCell" bundle:nil];
    [_firstCollection registerNib:nib forCellWithReuseIdentifier:IDENTIFIER];
    UINib *nib2 = [UINib nibWithNibName:@"LogFirstCell2" bundle:nil];
    [_firstCollection registerNib:nib2 forCellWithReuseIdentifier:IDENTIFIER2];
    _firstCollection.backgroundColor = [UIColor whiteColor];

    [backImg addSubview:_firstCollection];
    
    NSString *str = @"已连续签到999天";
    CGFloat strWidth = [YBToolClass widthOfString:str andFont:[UIFont systemFontOfSize:12] andHeight:24];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(backImg.width-strWidth-backImg.width*0.1, _firstCollection.origin.y-35-7, strWidth, 30)];
//    title.layer.cornerRadius = 13;
//    title.layer.masksToBounds = YES;
//    title.backgroundColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:12];
    title.textColor = RGB_COLOR(@"#8D8D8D", 1);
    title.textAlignment = NSTextAlignmentCenter;
//    title.backgroundColor = RGBA(255,46,140,0.1);
//    title.adjustsFontSizeToFitWidth = YES;
    title.numberOfLines = 0;
    [backImg addSubview:title];

    NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:YZMsg(@"已连续签到%@天"),logDayCount]];
    [textAtt addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#323232", 1) range:textAtt.yy_rangeOfAll];

    NSRange clickRange = [[textAtt string] rangeOfString:logDayCount];
    [textAtt yy_setTextHighlightRange:clickRange color:normalColors backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
    }];
    title.attributedText = textAtt;
    
    UILabel *tipslb = [[UILabel alloc]init];
//    CGFloat tipsStrWidth = [YBToolClass widthOfString:str andFont:[UIFont systemFontOfSize:15] andHeight:24];
//    tipslb.frame = CGRectMake(backImg.width *0.15, title.origin.y, tipsStrWidth+20, 30);
    tipslb.frame = CGRectMake(backImg.width *0.15, title.origin.y, backImg.width *0.5, 35);

    tipslb.textAlignment = NSTextAlignmentLeft;
    tipslb.text = YZMsg(@"连续签到领取额外奖励");
    tipslb.font = [UIFont boldSystemFontOfSize:14];
    tipslb.textColor = RGB_COLOR(@"#8D8D8D", 1);
//    tipslb.adjustsFontSizeToFitWidth = YES;
    tipslb.numberOfLines = 0;
    [backImg addSubview:tipslb];
    
    UIButton *receiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnW = backImg.width*0.6;
    CGFloat btnH = 40;
    CGFloat btnX = backImg.width*0.2;
    CGFloat btnY = 10;
    receiveBtn.frame = CGRectMake(btnX, _firstCollection.bottom+5, btnW, btnH);
    receiveBtn.backgroundColor = normalColors;
    [receiveBtn addTarget:self action:@selector(clickReceiveBtn) forControlEvents:UIControlEventTouchUpInside];
    [receiveBtn setTitle:YZMsg(@"签到") forState:UIControlStateNormal];
    receiveBtn.titleLabel.textColor = [UIColor whiteColor];
//    receiveBtn.layer.cornerRadius = 20;
//    receiveBtn.layer.masksToBounds = YES;
    [receiveBtn setBackgroundImage:[UIImage imageNamed:@"loginFirst_qiandao"]];
    receiveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [backImg addSubview:receiveBtn];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8 animations:^{
                backImg.frame = CGRectMake(_window_width*0.02, _window_height*0.2, _window_width*0.96, height);
            }];
        });
    });

    
}
- (void)showLogSucessAnimation{
    [backImg removeFromSuperview];
    backImg = nil;
    UIImageView *lightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.25, _window_height/2-_window_width*0.125-50, _window_width*0.5, _window_width*0.5)];
    lightImageView.image = [UIImage imageNamed:@"logFirst_背景"];
    [self addSubview:lightImageView];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 9999;
    [lightImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    //放大效果，并回到原位
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //速度控制函数，控制动画运行的节奏
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;       //执行时间
    animation.repeatCount = 1;      //执行次数
    animation.autoreverses = NO;    //完成动画后会回到执行动画之前的状态
    animation.fromValue = [NSNumber numberWithFloat:0.2];   //初始伸缩倍数
    animation.toValue = [NSNumber numberWithFloat:1.2];     //结束伸缩倍数
    
    
    
    
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(lightImageView.left, lightImageView.top-lightImageView.width/3, lightImageView.width, lightImageView.width/3)];
    headerImgView.image = [UIImage imageNamed:getImagename(@"logFirst_成功")];
    [self addSubview:headerImgView];
    
    
    UIImageView *coinImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.375, lightImageView.width*0.25+lightImageView.top, _window_width*0.25, _window_width*0.25)];
    coinImageView.image = [UIImage imageNamed:@"logFirst_钻石"];
    [self addSubview:coinImageView];
    
    [headerImgView.layer addAnimation:animation forKey:nil];
    [coinImageView.layer addAnimation:animation forKey:nil];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, coinImageView.bottom+5, _window_width, 22)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    NSDictionary *subdic = _arrays[[logDay intValue]-1];
    label.text = [NSString stringWithFormat:@"+ %@",minstr([subdic valueForKey:@"coin"])];
    [self addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label.layer addAnimation:animation forKey:nil];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [UIView animateWithDuration:0.8 animations:^{
                firtBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                [firtBackView removeFromSuperview];
                firtBackView = nil;
            }];


        } completion:^(BOOL finished) {
            if ([_delegate respondsToSelector:@selector(removeView:)]) {
                [_delegate removeView:nil];
            }
        }];
        
    });

}
-(void)clickReceiveBtn {
    [YBToolClass postNetworkWithUrl:@"User.getBonus" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self showLogSucessAnimation];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD showError:YZMsg(@"网络错误")];

    }];
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrays.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    
    if (indexPath.row  == 6) {
        LogFirstCell2 *cell2 = [collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER2 forIndexPath:indexPath];
        
        cell = cell2;
        
    } else {
        
        LogFirstCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER forIndexPath:indexPath];
        
        cell1.layer.cornerRadius = 3;
        cell1.layer.masksToBounds = YES;
        NSDictionary *subdic = _arrays[indexPath.row];
        cell1.numL.text = [NSString stringWithFormat:YZMsg(@"第%@天"),minstr([subdic valueForKey:@"day"])];
        if(indexPath.item < [logDay integerValue]-1){
            cell1.bgIV2.image = [UIImage imageNamed:getImagename(@"logFirst_已领取")];
        }else{
            cell1.bgIV2.image = [UIImage imageNamed:@"logFirst_未领取"];
        }
        //判断第几天
        if (indexPath.item == [logDay integerValue]-1) {
            //动画
//            cell1.bgIV2.image = [UIImage imageNamed:@"sel"];
            selectCell = cell1;
//            if (nil == _link) {
//                // 实例化计时器
//                _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(keepRatate)];
//                // 添加到当前运行循环中
//                [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//            } else {
//                // 如果不为空，就关闭暂停
//                _link.paused = NO;
//            }
        }
        cell = cell1;
    }
    return cell;
}

- (void)keepRatate {
    if ([logDay integerValue] == 7) {
        selectCell2.bgIV2.transform = CGAffineTransformRotate(selectCell2.bgIV2.transform, M_PI_4 * 0.02);
    }else {
        selectCell.bgIV2.transform = CGAffineTransformRotate(selectCell.bgIV2.transform, M_PI_4 * 0.02);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 6) {
        return CGSizeMake(itemWidth*2, itemHeight);
    }else {
        return CGSizeMake(itemWidth, itemHeight);

    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%zi",indexPath.item);
}
- (void)cancelLQ{
    [self.delegate removeView:nil];
}
/******************  <- 登录奖励  ********************/




@end
