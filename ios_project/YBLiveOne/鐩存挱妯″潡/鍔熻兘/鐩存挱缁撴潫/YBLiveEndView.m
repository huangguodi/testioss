//
//  YBLiveEndView.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/13.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBLiveEndView.h"

@interface YBLiveEndView()


@property(nonatomic,strong)UIImageView *bgIV;
@property(nonatomic,strong)UIImageView *avatarIV;
@property(nonatomic,strong)UILabel *nameL;
@property(nonatomic,strong)UILabel *liveTimeL;
@property(nonatomic,strong)UILabel *liveVotesL;
@property(nonatomic,strong)UILabel *liveNumL;

@end

@implementation YBLiveEndView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI {
    _bgIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _bgIV.userInteractionEnabled = YES;
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0,_window_width,_window_height);
    [_bgIV addSubview:effectview];
    
    
    UILabel *labell= [[UILabel alloc]initWithFrame:CGRectMake(0,24+statusbarHeight, _window_width, _window_height*0.17)];
    labell.textColor = Pink_Cor;
    labell.text = YZMsg(@"直播已结束");
    labell.textAlignment = NSTextAlignmentCenter;
    labell.font = [UIFont boldSystemFontOfSize:20];
    [_bgIV addSubview:labell];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.1, labell.bottom+50, _window_width*0.8, _window_width*0.8*8/13)];
    backView.backgroundColor = RGB_COLOR(@"#000000", 0.2);
    backView.layer.cornerRadius = 5.0;
    backView.layer.masksToBounds = YES;
    [_bgIV addSubview:backView];
    
    _avatarIV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width/2-50, labell.bottom, 100, 100)];
    _avatarIV.layer.masksToBounds = YES;
    _avatarIV.layer.cornerRadius = 50;
    [_bgIV addSubview:_avatarIV];
    
    
    _nameL= [[UILabel alloc]initWithFrame:CGRectMake(0,50, backView.width, backView.height*0.55-50)];
    _nameL.textColor = [UIColor whiteColor];
    _nameL.text = [Config getOwnNicename];
    _nameL.textAlignment = NSTextAlignmentCenter;
    _nameL.font = [UIFont boldSystemFontOfSize:18];
    [backView addSubview:_nameL];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, _nameL.bottom, backView.width-20, 1) andColor:RGB_COLOR(@"#585452", 1) andView:backView];
    
    NSArray *labelArray = @[YZMsg(@"直播时长"),[NSString stringWithFormat:@"%@%@",YZMsg(@"收获"),[common name_votes]],YZMsg(@"观看人数")];
    if (![lagType isEqual:ZH_CN]) {
        labelArray = @[YZMsg(@"直播时长"),@"Income",YZMsg(@"观看人数")];
    }
    for (int i = 0; i < labelArray.count; i++) {
        UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*backView.width/3, _nameL.bottom, backView.width/3, backView.height/4)];
        topLabel.font = [UIFont boldSystemFontOfSize:18];
        topLabel.textColor = [UIColor whiteColor];
        topLabel.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            _liveTimeL = topLabel;
        }
        if (i == 1) {
            _liveVotesL = topLabel;
        }
        if (i == 2) {
            _liveNumL = topLabel;
        }
        [backView addSubview:topLabel];
        UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(topLabel.left, topLabel.bottom, topLabel.width, 14)];
        footLabel.font = [UIFont systemFontOfSize:13];
        footLabel.textColor = RGB_COLOR(@"#cacbcc", 1);
        footLabel.textAlignment = NSTextAlignmentCenter;
        footLabel.text = labelArray[i];
        [backView addSubview:footLabel];
    }
        
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(_window_width*0.1,_window_height *0.75, _window_width*0.8,50);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(docancle) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = Pink_Cor;
    [button setTitle:YZMsg(@"返回首页") forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.layer.cornerRadius = 25;
    button.layer.masksToBounds  =YES;
    [_bgIV addSubview:button];
    [self addSubview:_bgIV];
}
-(void)docancle {
    if (self.liveEndEvent) {
        self.liveEndEvent(Live_EndLive_Close,@{});
    }
}
-(void)updateData:(NSDictionary *)dic {
    [_bgIV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"hostAvatar"])]];
    [_avatarIV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"hostAvatar"])] placeholderImage:[UIImage imageNamed:@"bg1"]];
    _nameL.text = minstr([dic valueForKey:@"hostName"]);
    _liveTimeL.text = minstr([dic valueForKey:@"length"]);
    _liveVotesL.text = minstr([dic valueForKey:@"votes"]);
    _liveNumL.text = minstr([dic valueForKey:@"nums"]);
    
}



@end
