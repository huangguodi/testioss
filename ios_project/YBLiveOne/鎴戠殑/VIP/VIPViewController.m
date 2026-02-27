//
//  VIPViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "VIPViewController.h"
#import "vipBuyView.h"

@interface VIPViewController (){
    UILabel *vipL;
    UILabel *statusL;
    UIButton *kaitongBtn;
    NSDictionary *infoDic;
    vipBuyView *buyView;
}

@end

@implementation VIPViewController

- (void)doReturn {
    [[YBRechargeType chargeManeger]removePayNotice];
    [super doReturn];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = YZMsg(@"会员中心");
    [[YBRechargeType chargeManeger]addPayNotice];
    [self creatUI];
    [self requestData];
}
- (void)creatUI{
    UIImageView *headerImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_width*0.426)];
    headerImgV.userInteractionEnabled = YES;
    headerImgV.image = [UIImage imageNamed:@"vip_header"];
    [self.view addSubview:headerImgV];
    vipL = [[UILabel alloc]init];
    vipL.textColor = [UIColor whiteColor];
    vipL.font = SYS_Font(16);
    [headerImgV addSubview:vipL];
    [vipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(0.6);
    }];
    
    statusL = [[UILabel alloc]init];
    statusL.textColor = [UIColor whiteColor];
    statusL.font = SYS_Font(11);
    [headerImgV addSubview:statusL];
    [statusL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV);
    }];
    
    kaitongBtn = [UIButton buttonWithType:0];
    [kaitongBtn setBackgroundColor:[UIColor whiteColor]];
    [kaitongBtn setTitleColor:normalColors forState:0];
    kaitongBtn.titleLabel.font = SYS_Font(12);
    [kaitongBtn addTarget:self action:@selector(kaitongBtnClick) forControlEvents:UIControlEventTouchUpInside];
    kaitongBtn.layer.cornerRadius = _window_width*0.04;
    kaitongBtn.layer.masksToBounds = YES;
    [headerImgV addSubview:kaitongBtn];
    [kaitongBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(1.5);
        make.height.mas_equalTo(_window_width*0.08);
        make.width.equalTo(kaitongBtn.mas_height).multipliedBy(3);
    }];
    
    UIImageView *bottomImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, headerImgV.bottom, _window_width, _window_width*0.875)];
    bottomImgV.userInteractionEnabled = YES;
    bottomImgV.image = [UIImage imageNamed:getImagename(@"vip_footer")];
    [self.view addSubview:bottomImgV];

    UILabel *youngLb = [[UILabel alloc]init];
    youngLb.text =YZMsg(@"未成年人禁止充值消费");
    youngLb.textColor = normalColors_live;
    youngLb.font =[UIFont systemFontOfSize:12];
    [self.view addSubview:youngLb];
    [youngLb mas_makeConstraints:^(MASConstraintMaker *make) {
        if (![lagType isEqual:ZH_CN]) {
            make.top.equalTo(bottomImgV.mas_top).offset(30);
        }else{
            make.top.equalTo(bottomImgV.mas_top).offset(10);
        }
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    UIImageView *tanImg =[[UIImageView alloc]init];
    tanImg.image = [UIImage imageNamed:@"young-叹号"];
    [self.view addSubview:tanImg];
    [tanImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(youngLb.mas_centerY);
        make.width.height.mas_equalTo(13);
        make.right.equalTo(youngLb.mas_left);
    }];

    
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Vip.myVip" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isvip"]) isEqual:@"1"]) {
                vipL.text = YZMsg(@"您已开通VIP会员");
                statusL.text = [NSString stringWithFormat:@"%@：%@",YZMsg(@"会员到期时间"),minstr([infoDic valueForKey:@"endtime"])];
                [kaitongBtn setTitle:YZMsg(@"续费VIP") forState:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADHOMEVIDEOLIST" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADVIDEOLIST" object:nil];
                if (self.vipBlock) {
                    self.vipBlock();
                }
            }else{
                vipL.text = YZMsg(@"您还不是VIP会员");
                statusL.text = YZMsg(@"无法享受会员特权");
                [kaitongBtn setTitle:YZMsg(@"开通VIP") forState:0];
            }
        }
    } fail:^{
        
    }];
}
- (void)kaitongBtnClick{
    if (!buyView) {
        buyView = [[vipBuyView alloc]initWithMsg:infoDic];
        [self.view addSubview:buyView];
    }
    WeakSelf;
    buyView.block = ^{
        [weakSelf requestData];
    };
    [buyView show];
    [self.view bringSubviewToFront:buyView];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
