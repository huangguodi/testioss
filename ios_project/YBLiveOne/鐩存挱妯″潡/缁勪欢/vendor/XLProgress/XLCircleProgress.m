//
//  CircleView.m
//  YKL
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import "XLCircleProgress.h"
#import "XLCircle.h"

@implementation XLCircleProgress
{
    XLCircle* _circle;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}


-(void)initUI
{
    float lineWidth = 5;
    _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.size.width-10, self.size.width-10)];
    _percentLabel.textColor = [UIColor whiteColor];
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    _percentLabel.font = [UIFont boldSystemFontOfSize:17];
    _percentLabel.text = @"100\n催更";
    _percentLabel.numberOfLines = 2;
    _percentLabel.backgroundColor = [UIColor whiteColor];//Pink_Cor;
    _percentLabel.layer.cornerRadius = (self.size.width-10.0)/2;
    _percentLabel.layer.masksToBounds = YES;
    [self addSubview:_percentLabel];
    
    _circle = [[XLCircle alloc] initWithFrame:self.bounds lineWidth:lineWidth];
    [self addSubview:_circle];
}

#pragma mark -
#pragma mark Setter方法
-(void)setProgress:(float)progress
{
    _progress = progress;
    _circle.progress = progress;
//    _percentLabel.text = [NSString stringWithFormat:@"%.0f%%\n催更",progress*100];
}

@end
