//
//  YBVotesUnit.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/8.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBVotesUnit.h"

@interface YBVotesUnit()

@property(nonatomic,strong)UILabel *titleL;
@property(nonatomic,strong)UILabel *numsL;
@property(nonatomic,strong)UIImageView *arrowIV;

@end

@implementation YBVotesUnit

- (instancetype)init{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}
-(void)createUI {
    CGFloat unitSize = 24;
    self.backgroundColor = RGB_COLOR(@"#000000", 0.4);
    self.layer.cornerRadius = unitSize/2;
    
    _titleL = [[UILabel alloc]init];
    _titleL.font = SYS_Font(13);
    if ([lagType isEqual:ZH_CN]) {
        _titleL.text = [NSString stringWithFormat:@"%@%@",[common name_votes],YZMsg(@"收益")];
    }else {
        _titleL.text = [NSString stringWithFormat:@"%@",[common name_votes]];
    }
    _titleL.textColor = UIColor.whiteColor;
    [self addSubview:_titleL];
    [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(unitSize);
        make.height.centerY.equalTo(self);
        make.left.equalTo(self.mas_left).offset(10);
    }];
    
    _numsL = [[UILabel alloc]init];
    _numsL.font = SYS_Font(13);
    _numsL.textColor = UIColor.whiteColor;
    [self addSubview:_numsL];
    [_numsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(_titleL.mas_right).offset(3);
    }];
    
    _arrowIV = [[UIImageView alloc]init];
    _arrowIV.image = [UIImage imageNamed:@"person_右箭头"];
    _arrowIV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_arrowIV];
    [_arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(12);
        make.centerY.equalTo(self);
        make.left.equalTo(_numsL.mas_right).offset(3);
        make.right.equalTo(self.mas_right).offset(-5);
    }];
    
    YBButton *shadowBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [shadowBtn addTarget:self action:@selector(clickShadowBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shadowBtn];
    [shadowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerX.centerY.equalTo(self);
    }];
    
    
    
}
- (void)setNums:(int)nums {
    _nums = nums;
    _numsL.text = [NSString stringWithFormat:@"%d",nums];
}
-(void)clickShadowBtn:(YBButton *)btn {
    if(self.ticketEvent){
        self.ticketEvent(Live_Room_Tickt, @{});
    }
}








@end
