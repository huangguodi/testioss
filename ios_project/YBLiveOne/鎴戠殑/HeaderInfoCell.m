//
//  HeaderInfoCell.m
//  YBLiveOne
//
//  Created by ybRRR on 2022/1/19.
//  Copyright © 2022 IOS1. All rights reserved.
//

#import "HeaderInfoCell.h"
#import "MineDetailsViewController.h"
@implementation HeaderInfoCell
{
    UIButton *headBtn;       //头像
    NSArray *function_arr1;
    
    UILabel *nameLb;         //名字
    UILabel *idLb;           //ID
    UIImageView *idImage;    //
    
    UIImageView *levelImg;  //等级
    UIImageView *vipImg;    //vip
    
    UIView *function_view3; //（钱包、认证、家族、美颜）
    UIView *function_view4; //（钱包、明细、收益）
    
    UIButton *attBtn;       //关注按钮
    UIButton *fansBtn;      //粉丝按钮
    UIButton *likeBtn;      //喜欢按钮
    UIButton *coinBtn;      //余额按钮
    UIButton *profitBtn;    //收益按钮
    UIButton *vipBtn;       //vip按钮
    UIButton *invitationBtn;//邀请按钮
    UIButton *meiYanBtn;//美颜按钮
    UIButton *familyBtn;//美颜按钮
    
    UIImageView *doNotImg;  //勿扰模式
    
    NSArray *_functioTypeArr;
    UILabel *coinLb;
    UIView *function_view2;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = RGBA(246,247,249, 1);
        [self createUI];
    }
    return self;
}
-(void)createUI{
    
    UIImageView *headBackImg = [[UIImageView alloc]init];
    
    if ([[YBYoungManager shareInstance]isOpenYoung]) {
        headBackImg.frame = CGRectMake(0, 0, _window_width, 24+statusbarHeight+40+100);
    }else{
        headBackImg.frame = CGRectMake(0, 0, _window_width, 262);
    }
    headBackImg.image = [UIImage imageNamed:@"mine_headbg"];
    headBackImg.userInteractionEnabled = YES;
    [self.contentView addSubview:headBackImg];
    
    UIButton *setBtn = [UIButton buttonWithType:0];
    setBtn.frame = CGRectMake(_window_width-26-21, 24+statusbarHeight+15, 22, 22);
    [setBtn setImage:[UIImage imageNamed:@"mine_设置"] forState:0];
    [setBtn addTarget:self action:@selector(setBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:setBtn];
    
    headBtn = [UIButton buttonWithType:0];
    headBtn.frame = CGRectMake(16, 24+statusbarHeight+40, 80, 80);
    headBtn.layer.cornerRadius = 20;
    headBtn.layer.masksToBounds = YES;
    headBtn.layer.borderColor = RGB_COLOR(@"#CB78FF",0.5).CGColor;
    headBtn.layer.borderWidth = 2;
    headBtn.backgroundColor = UIColor.whiteColor;
    [headBtn addTarget:self action:@selector(headTapClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:headBtn];
    
    nameLb = [[UILabel alloc]init];
    nameLb.frame = CGRectMake(headBtn.right+7,headBtn.centerY-20, _window_width-headBtn.right-40, 20);
    nameLb.font = [UIFont boldSystemFontOfSize:18];
    nameLb.textColor = UIColor.blackColor;
    [self.contentView addSubview:nameLb];
    
    levelImg = [[UIImageView alloc]init];
    levelImg.frame = CGRectMake(nameLb.right+5, nameLb.bottom-15, 30, 15);
    levelImg.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:levelImg];
    
    vipImg = [[UIImageView alloc]init];
    vipImg.frame = CGRectMake(levelImg.right+5, levelImg.top, 30, 15);
    vipImg.image = [UIImage imageNamed:@"vip"];
    vipImg.hidden = YES;
    [self.contentView addSubview:vipImg];
    
    idImage = [[UIImageView alloc]init];
    idImage.frame = CGRectMake(nameLb.left, nameLb.bottom+5, 18, 18);
    idImage.image = [UIImage imageNamed:@"我的-ID"];
    [self.contentView addSubview:idImage];
    
    idLb = [[UILabel alloc]init];
    idLb.frame = CGRectMake(idImage.right+5, nameLb.bottom+5, _window_width-headBtn.right-40, 18);
    idLb.font = [UIFont systemFontOfSize:12];
    idLb.textColor = UIColor.grayColor;
    [self.contentView addSubview:idLb];
    
    UIButton *editBtn = [UIButton buttonWithType:0];
    editBtn.frame = CGRectMake(_window_width-60, nameLb.top, 50, 50);
    [editBtn setImage:[UIImage imageNamed:@"person_右箭头"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(headTapClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:editBtn];
    
    if (![[YBYoungManager shareInstance]isOpenYoung]) {
        
        UIView *function_view1 = [[UIView alloc]init];
        function_view1.frame = CGRectMake(20, headBtn.bottom+17, _window_width-40, 50);
        function_view1.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:function_view1];
        
//        function_arr1 = @[YZMsg(@"关注"),YZMsg(@"粉丝"),YZMsg(@"余额"),YZMsg(@"收益")];
//        if ([YBToolClass isUp]) {
//            function_arr1 = @[YZMsg(@"关注"),YZMsg(@"粉丝"),YZMsg(@"余额")];
//        }
        function_arr1 = @[YZMsg(@"关注"),YZMsg(@"喜欢"),YZMsg(@"粉丝"),YZMsg(@"收益")];
        if ([YBToolClass isUp]) {
            function_arr1 = @[YZMsg(@"关注"),YZMsg(@"喜欢"),YZMsg(@"粉丝"),YZMsg(@"余额")];
        }

        CGFloat btnWWW = function_view1.width/function_arr1.count;
        for (int i = 0; i < function_arr1.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(i *btnWWW, 0, btnWWW, 50);
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",@"0"] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
            NSAttributedString *time = [[NSAttributedString alloc] initWithString:function_arr1[i] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
            [title appendAttributedString:time];
            
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            [paraStyle setLineSpacing:10];
            paraStyle.alignment = NSTextAlignmentCenter;
            [title addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, title.length)];
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [btn setAttributedTitle:title forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [function_view1 addSubview:btn];
            if (i == 0) {
                attBtn = btn;
            }else if (i == 1){
                likeBtn = btn;
            }else if (i == 2){
                fansBtn = btn;
            }else{
//                profitBtn = btn;
                coinBtn = btn;
            }
            
        }
        
        function_view2 = [[UIView alloc]init];
        function_view2.frame = CGRectMake(14, function_view1.bottom+17, _window_width-28, 160);
        if ([YBToolClass isUp]) {
            function_view2.frame = CGRectMake(14, function_view1.bottom+0, _window_width-28, 0);
        }
        function_view2.backgroundColor = UIColor.whiteColor;
        function_view2.layer.cornerRadius = 10;
        function_view2.layer.masksToBounds = YES;
        [self.contentView addSubview:function_view2];
        
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
        NSString *buildsss = [NSString stringWithFormat:@"%@",app_build];
        
        function_view4 =[[UIView alloc]init];
        //如果不相等说明未上架，检测是否是新版本
        if (![buildsss isEqual:[common ios_shelves]]) {
            function_view4.frame = CGRectMake(14, function_view2.bottom+15, _window_width-28, 100);
            
        }else{
            function_view4.frame = CGRectMake(14, function_view2.bottom+15, _window_width-28, 50);
            
        }
        function_view4.backgroundColor = UIColor.whiteColor;
        function_view4.layer.cornerRadius = 10;
        function_view4.layer.masksToBounds = YES;
        [self.contentView addSubview:function_view4];
        
        UILabel *view4Titile = [[UILabel alloc]init];
        view4Titile.frame = CGRectMake(14, 16, 100, 20);
        view4Titile.font = [UIFont boldSystemFontOfSize:15];
        view4Titile.textColor = UIColor.blackColor;
        view4Titile.text = YZMsg(@"我的钱包");
        [function_view4 addSubview:view4Titile];
        
        UIImageView *rightImg = [[UIImageView alloc]init];
        rightImg.image = [UIImage imageNamed:@"person_右箭头"];
        [function_view4 addSubview:rightImg];
        [rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(function_view4.mas_right).offset(-10);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(16);
            make.centerY.equalTo(view4Titile.mas_centerY);
        }];
        
        coinLb = [[UILabel alloc]init];
        coinLb.font = [UIFont systemFontOfSize:14];
        coinLb.textColor = [UIColor blackColor];
        [function_view4 addSubview:coinLb];
        [coinLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(rightImg.mas_centerY);
            make.right.equalTo(rightImg.mas_left).offset(-5);
        }];
        
        UIImageView *coinImg = [[UIImageView alloc]init];
        coinImg.image = [UIImage imageNamed:@"center_coin"];
        [function_view4 addSubview:coinImg];
        [coinImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(coinLb.mas_left).offset(-5);
            make.width.height.mas_equalTo(16);
            make.centerY.equalTo(rightImg.mas_centerY);
        }];
        
        UIButton *rechargeBtn = [UIButton buttonWithType:0];
        [rechargeBtn addTarget:self action:@selector(toRechargeClick) forControlEvents:UIControlEventTouchUpInside];
        [function_view4 addSubview:rechargeBtn];
        [rechargeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(coinImg);
            make.right.bottom.equalTo(rightImg);
        }];
        
        if (![buildsss isEqual:[common ios_shelves]]) {
            UIView *mxView = [[UIView alloc]init];
            mxView.backgroundColor = RGBA(246,247,249,1);
            mxView.layer.cornerRadius = 5;
            mxView.layer.masksToBounds = YES;
            [function_view4 addSubview:mxView];
            [mxView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(function_view4.mas_left).offset(10);
                make.right.equalTo(function_view4.mas_centerX).offset(-5);
                make.height.mas_equalTo(36);
                make.top.equalTo(view4Titile.mas_bottom).offset(15);
            }];
            
            UILabel *mxLb = [[UILabel alloc]init];
            mxLb.font = [UIFont systemFontOfSize:14];
            mxLb.textColor = [UIColor blackColor];
            mxLb.text = YZMsg(@"我的明细");
            [mxView addSubview:mxLb];
            [mxLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(mxView.mas_centerX).offset(10);
                make.centerY.equalTo(mxView);
            }];
            
            UIImageView *mxImg = [[UIImageView alloc]init];
            mxImg.image = [UIImage imageNamed:@"我的明细"];
            [mxView addSubview:mxImg];
            [mxImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(mxLb.mas_left).offset(-5);
                make.centerY.equalTo(mxLb);
                make.width.height.mas_equalTo(16);
            }];
            
            UIButton *mxBtn = [UIButton buttonWithType:0];
            [mxBtn addTarget:self
                      action:@selector(mxBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [mxView addSubview:mxBtn];
            [mxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(mxView);
            }];
            
            UIView *syView = [[UIView alloc]init];
            syView.backgroundColor = RGBA(246,247,249,1);
            syView.layer.cornerRadius = 5;
            syView.layer.masksToBounds = YES;
            [function_view4 addSubview:syView];
            [syView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(function_view4.mas_centerX).offset(5);
                make.right.equalTo(function_view4.mas_right).offset(-10);
                make.height.mas_equalTo(36);
                make.centerY.equalTo(mxView);
            }];
            
            UILabel *syLb = [[UILabel alloc]init];
            syLb.font = [UIFont systemFontOfSize:14];
            syLb.textColor = [UIColor blackColor];
            syLb.text = YZMsg(@"我的收益");
            [syView addSubview:syLb];
            [syLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(syView.mas_centerX).offset(10);
                make.centerY.equalTo(syView);
            }];
            
            UIImageView *syImg = [[UIImageView alloc]init];
            syImg.image = [UIImage imageNamed:@"我的收益"];
            [syView addSubview:syImg];
            [syImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(syLb.mas_left).offset(-5);
                make.centerY.equalTo(syLb);
                make.width.height.mas_equalTo(16);
            }];
            UIButton *syBtn = [UIButton buttonWithType:0];
            [syBtn addTarget:self
                      action:@selector(syBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [syView addSubview:syBtn];
            [syBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(syView);
            }];
        }
        
        function_view3 = [[UIView alloc]init];
        function_view3.frame = CGRectMake(14, function_view4.bottom+15, _window_width-28, 60);
        function_view3.backgroundColor = UIColor.clearColor;
        function_view3.layer.cornerRadius = 10;
        function_view3.layer.masksToBounds = YES;
        [self.contentView addSubview:function_view3];
        
    }
}

-(void)headTapClick{
    if (self.btnEvent) {
        self.btnEvent(@"编辑");
    }
}


-(void)setCellData:(NSDictionary *)cellData{
    _cellData = cellData;
    
    if (![[YBYoungManager shareInstance]isOpenYoung]) {
        
        [function_view2 removeAllSubviews];
        NSString *agent_switchStr = minstr([cellData valueForKey:@"agent_switch"]);
        NSString *family_switchStr = minstr([cellData valueForKey:@"family_switch"]);
        
        UILabel *view2Titile = [[UILabel alloc]init];
        view2Titile.frame = CGRectMake(12, 10, 200, 20);
        view2Titile.font = [UIFont boldSystemFontOfSize:15];
        view2Titile.textColor = UIColor.blackColor;
        view2Titile.text = YZMsg(@"增值功能");
        [function_view2 addSubview:view2Titile];
        
        CGFloat fBtn2WWW =(function_view2.width-44)/3;
        NSArray *function_arr2 = @[YZMsg(@"center-vip特权"),YZMsg(@"center-邀请奖励"),YZMsg(@"center-家族公会")];
        NSArray *function_title = @[YZMsg(@"VIP特权"),YZMsg(@"邀请奖励"),YZMsg(@"家族公会")];
        NSArray *function_subtitle = @[YZMsg(@"贵族特权"),YZMsg(@"轻松拿提成"),YZMsg(@"解锁更多玩法")];
        
        if ([agent_switchStr isEqual:@"0"] && [family_switchStr isEqual:@"0"]) {
            function_arr2 = @[YZMsg(@"center-vip特权")];
            function_title= @[YZMsg(@"VIP特权")];
            function_subtitle =@[YZMsg(@"贵族特权")];
        }else  if ([agent_switchStr isEqual:@"1"] && [family_switchStr isEqual:@"0"]) {
            function_arr2 = @[YZMsg(@"center-vip特权"),YZMsg(@"center-邀请奖励")];
            function_title= @[YZMsg(@"VIP特权"),YZMsg(@"邀请奖励")];
            function_subtitle =@[YZMsg(@"贵族特权"),YZMsg(@"轻松拿提成")];
            
        }else  if ([agent_switchStr isEqual:@"0"] && [family_switchStr isEqual:@"1"]) {
            function_arr2 = @[YZMsg(@"center-vip特权"),YZMsg(@"center-家族公会")];
            function_title= @[YZMsg(@"VIP特权"),YZMsg(@"家族公会")];
            function_subtitle =@[YZMsg(@"贵族特权"),YZMsg(@"解锁更多玩法")];
            
        }
        for (int i = 0; i < function_arr2.count; i ++) {
            
            UIImageView *images = [[UIImageView alloc]init];
            images.frame =  CGRectMake((i+1)*10+i*fBtn2WWW, view2Titile.bottom+15, fBtn2WWW, fBtn2WWW);
            images.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_back",function_arr2[i]]];
            images.userInteractionEnabled = YES;
            [function_view2 addSubview:images];
            
            UIImageView *tipsImg = [[UIImageView alloc]init];
            tipsImg.frame = CGRectMake(images.width/2-22, -13, 44, 44);
            tipsImg.image =[UIImage imageNamed:function_arr2[i]];
            tipsImg.userInteractionEnabled = YES;
            [images addSubview:tipsImg];
            
            UILabel *title1 = [[UILabel alloc]init];
            title1.font = [UIFont boldSystemFontOfSize:14];
            title1.textColor = UIColor.blackColor;
            title1.text =function_title[i];
            title1.adjustsFontSizeToFitWidth = YES;
            [images addSubview:title1];
            [title1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(tipsImg.mas_centerX);
                make.top.equalTo(tipsImg.mas_bottom).offset(10);
                make.width.lessThanOrEqualTo(images);
            }];
            UILabel *subtitle = [[UILabel alloc]init];
            subtitle.font = [UIFont systemFontOfSize:12];
            subtitle.textColor = UIColor.grayColor;
            subtitle.text =function_subtitle[i];
            subtitle.adjustsFontSizeToFitWidth = YES;
            [images addSubview:subtitle];
            [subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(tipsImg.mas_centerX);
                make.top.equalTo(title1.mas_bottom).offset(7);
                make.width.lessThanOrEqualTo(images);
            }];
            
            UIButton *btns = [UIButton buttonWithType:0];
            [btns addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [function_view2 addSubview:btns];
            [btns mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(images);
            }];
            if ([agent_switchStr isEqual:@"0"] && [family_switchStr isEqual:@"0"]) {
                if (i == 0) {
                    vipBtn = btns;
                }
            }else  if ([agent_switchStr isEqual:@"1"] && [family_switchStr isEqual:@"0"]) {
                if (i == 0) {
                    vipBtn = btns;
                }else{
                    invitationBtn = btns;
                }
                
                
            }else  if ([agent_switchStr isEqual:@"0"] && [family_switchStr isEqual:@"1"]) {
                if (i == 0) {
                    vipBtn = btns;
                }else{
                    familyBtn = btns;
                }
                
            }else{
                if (i == 0) {
                    vipBtn = btns;
                }else if (i == 1){
                    invitationBtn = btns;
                }else{
                    familyBtn = btns;
                }
                
            }
            
            
            //        if ([agent_switchStr isEqual:@"0"]) {
            //            if (i == 0) {
            //                vipBtn = btns;
            //            }else{
            //                meiYanBtn = btns;
            //            }
            //
            //        }else{
            //            if (i == 0) {
            //                vipBtn = btns;
            //            }else if (i == 1){
            //                invitationBtn = btns;
            //            }else{
            //                meiYanBtn = btns;
            //            }
            //        }
            
        }
        
        
        //设置功能按钮
        [function_view3 removeAllSubviews];
        NSArray *arr;
        NSArray *imgArr;
        //    if ([family_switchStr isEqual:@"1"]) {
        arr = @[YZMsg(@"我要认证"),YZMsg(@"美颜预设"),YZMsg(@"勿扰模式")];
        imgArr = @[@"mine-认证",@"mine-美颜预设",@"mine-勿扰关闭"];
        _functioTypeArr = @[@(functionType_attestation),@(functionType_meiyan),@(functionType_DND)];
        //    }else{
        //        arr = @[YZMsg(@"我要认证"),YZMsg(@"勿扰模式")];
        //        imgArr = @[@"mine-认证",@"mine-勿扰关闭"];
        //        _functioTypeArr = @[@(functionType_attestation),@(functionType_meiyan)];
        //
        //    }
        CGFloat btnWWW =(function_view3.width-(arr.count-1)*10)/arr.count;
        for (int i = 0; i < arr.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(i *(btnWWW+10), 0, btnWWW, 55);
            [btn setImage:[UIImage imageNamed:imgArr[i]] forState:0];
            [btn setTitle:arr[i] forState:0];
            [btn setTitleColor:UIColor.blackColor forState:0];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            if (![lagType isEqual:ZH_CN]) {
                btn.titleLabel.font = [UIFont systemFontOfSize:11];
            }
            [btn setBackgroundColor:UIColor.whiteColor];
            //        btn = [YBToolClass setUpImgDownText:btn space:5];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, - btn.imageView.image.size.width, 0, btn.imageView.image.size.width)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
            btn.layer.cornerRadius = 5;
            btn.layer.masksToBounds = YES;
            btn.tag = 10000+i;
            [btn addTarget:self action:@selector(function3BtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [function_view3 addSubview:btn];
            if (i == arr.count-1) {
                if ([minstr([cellData valueForKey:@"isdisturb"]) isEqual:@"1"]) {
                    //                doNotImg.image = [UIImage imageNamed:];
                    [btn setImage:[UIImage imageNamed:@"mine-勿扰开启"] forState:0];
                    
                }else{
                    //                doNotImg.image = [UIImage imageNamed:@"mine-勿扰关闭"];
                    [btn setImage:[UIImage imageNamed:@"mine-勿扰关闭"] forState:0];
                    
                }
                
            }
        }
    }
    [headBtn sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]] forState:0];
    CGFloat nameWww = [YBToolClass widthOfString:minstr([cellData valueForKey:@"user_nickname"]) andFont: [UIFont boldSystemFontOfSize:18] andHeight:20];
    nameLb.frame = CGRectMake(headBtn.right+7, headBtn.centerY-20, nameWww, 20);
    nameLb.text = minstr([cellData valueForKey:@"user_nickname"]);
    levelImg.frame = CGRectMake(nameLb.right+5, nameLb.bottom-17, 30, 15);
    vipImg.frame = CGRectMake(levelImg.right+5, levelImg.top, 30, 15);
    idLb.text = [NSString stringWithFormat:@"%@",[Config getOwnID]];
    
    if (![[YBYoungManager shareInstance]isOpenYoung]) {
        
        coinLb.text =minstr([cellData valueForKey:@"coin"]);
        
        if ([minstr([cellData valueForKey:@"isauth"]) isEqual:@"1"]) {
            [levelImg sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:[Config level_anchor]]]];
        }else{
            [levelImg sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:[Config getLevel]]]];
        }
        //vip显示
        if ([minstr([cellData valueForKey:@"isvip"]) isEqual:@"1"] && ![YBToolClass isUp]) {
            vipImg.hidden = NO;
        }else{
            vipImg.hidden = YES;
        }
        
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentCenter;
        [paraStyle setLineSpacing:10];
        
        //关注
        NSMutableAttributedString *folloNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"follows"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        NSAttributedString *fTitle = [[NSAttributedString alloc] initWithString:function_arr1[0] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
        [folloNum appendAttributedString:fTitle];
        
        [folloNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, folloNum.length)];
        [attBtn setAttributedTitle:folloNum forState:UIControlStateNormal];
        
        //喜欢
        NSMutableAttributedString *likeNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"likes"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        NSAttributedString *likeTitle = [[NSAttributedString alloc] initWithString:function_arr1[1] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
        [likeNum appendAttributedString:likeTitle];
        
        [likeNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, likeNum.length)];
        [likeBtn setAttributedTitle:likeNum forState:UIControlStateNormal];

        //粉丝
        NSMutableAttributedString *fansNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"fans"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        NSAttributedString *fansTitle = [[NSAttributedString alloc] initWithString:function_arr1[2] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
        [fansNum appendAttributedString:fansTitle];
        
        [fansNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, fansNum.length)];
        [fansBtn setAttributedTitle:fansNum forState:UIControlStateNormal];
//        //余额
//        NSMutableAttributedString *coinNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"coin"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
//
//        NSAttributedString *coinTitle = [[NSAttributedString alloc] initWithString:function_arr1[3] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
//        [coinNum appendAttributedString:coinTitle];
//
//        [coinNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, coinNum.length)];
//        [coinBtn setAttributedTitle:coinNum forState:UIControlStateNormal];
        
        //主播认证
        if([[cellData valueForKey:@"isauth"] isEqual:@"1"]){
            NSMutableAttributedString *profitNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"votestotal"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
            
            NSAttributedString *profitTitle = [[NSAttributedString alloc] initWithString:YZMsg(@"收益") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
            [profitNum appendAttributedString:profitTitle];
            
            [profitNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, profitNum.length)];
            [coinBtn setAttributedTitle:profitNum forState:UIControlStateNormal];

        }else{
            //余额
            NSMutableAttributedString *coinNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"coin"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
            
            NSAttributedString *coinTitle = [[NSAttributedString alloc] initWithString:YZMsg(@"余额") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
            [coinNum appendAttributedString:coinTitle];
            
            [coinNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, coinNum.length)];
            [coinBtn setAttributedTitle:coinNum forState:UIControlStateNormal];

        }
//        //收益
//        if (profitBtn) {
//            NSMutableAttributedString *profitNum = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",minstr([cellData valueForKey:@"votestotal"])] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor blackColor]}];
//
//            NSAttributedString *profitTitle = [[NSAttributedString alloc] initWithString:function_arr1[3] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];
//            [profitNum appendAttributedString:profitTitle];
//
//            [profitNum addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, profitNum.length)];
//            [profitBtn setAttributedTitle:profitNum forState:UIControlStateNormal];
//        }
    }
}
-(void)mxBtnClick{
    //明细
    MineDetailsViewController *details = [[MineDetailsViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:details animated:YES];
    
}
-(void)syBtnClick{
    //点击收益
    if (self.btnEvent) {
        self.btnEvent(@"收益");
    }
    
}
-(void)setBtnClick{
    if (self.btnEvent) {
        self.btnEvent(@"设置");
    }
}
-(void)functionBtnClick:(UIButton *)sender{
    if (sender == attBtn) {
        //点击关注
        if (self.btnEvent) {
            self.btnEvent(@"关注");
        }
    }else if (sender == fansBtn){
        //点击粉丝
        if (self.btnEvent) {
            self.btnEvent(@"粉丝");
        }
    }else if (sender == likeBtn){
        //点击喜欢
        if (self.btnEvent) {
            self.btnEvent(@"喜欢");
        }
    }else if (sender == coinBtn){
        if([sender.titleLabel.text containsString:@"余额"]){
            //点击余额
            if (self.btnEvent) {
                self.btnEvent(@"余额");
            }

        }else{
            //点击收益
            if (self.btnEvent) {
                self.btnEvent(@"收益");
            }

        }
    }else if (sender == profitBtn){
        //点击收益
        if (self.btnEvent) {
            self.btnEvent(@"收益");
        }
    }else if (sender == vipBtn){
        //点击vip
        if (self.btnEvent) {
            self.btnEvent(@"vip");
        }
    }else if (sender == invitationBtn){
        //点击邀请
        if (self.btnEvent) {
            self.btnEvent(@"邀请");
        }
    }else if (sender == meiYanBtn){
        if (self.btnEvent) {
            self.btnEvent(@"美颜预设");
        }
        
    }else if (sender == familyBtn){
        [self goFamily];
        
    }
}
-(void)toRechargeClick{
    //点击余额
    if (self.btnEvent) {
        self.btnEvent(@"我的钱包");
    }
    
}
-(void)function3BtnClick:(UIButton *)sender{
    NSInteger index = sender.tag-10000;
    id aa = _functioTypeArr[index];
    functioType type = [aa integerValue];
    if (type == functionType_wallet) {
        if (self.btnEvent) {
            self.btnEvent(@"我的钱包");
        }
    }else if (type == functionType_attestation){
        if (self.btnEvent) {
            self.btnEvent(@"我要认证");
        }
    }else if (type == functionType_family){
        [self goFamily];
    }else if (type == functionType_meiyan){
        if (self.btnEvent) {
            self.btnEvent(@"美颜预设");
        }
    }else if (type == functionType_DND){
        [self doNotBtnClick:sender];
        
    }
}
//点击勿扰模式
-(void)doNotBtnClick:(UIButton *)sender{
    NSString *url= @"User.SetDisturbSwitch";
    NSString *isdisturb;
    if ([minstr([_cellData valueForKey:@"isdisturb"]) isEqual:@"1"]) {
        isdisturb = @"0";
    }else{
        isdisturb = @"1";
    }
    NSDictionary *dic = @{@"isdisturb":isdisturb};
    [YBToolClass postNetworkWithUrl:url andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSLog(@"info----:%@",info);
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:_cellData];
            if ([isdisturb isEqual:@"1"]) {
                [newDic setValue:@"1" forKey:@"isdisturb"];
                //                doNotImg.image = [UIImage imageNamed:@"mine-勿扰开启"];
                [sender setImage:[UIImage imageNamed:@"mine-勿扰开启"] forState:0];
                
            }else{
                [newDic setValue:@"0" forKey:@"isdisturb"];
                //                doNotImg.image = [UIImage imageNamed:@"mine-勿扰关闭"];
                [sender setImage:[UIImage imageNamed:@"mine-勿扰关闭"] forState:0];
                
            }
            _cellData = newDic;
        }else{
        }
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}


-(void)goFamily{
    NSString *loadUrl = [NSString stringWithFormat:@"%@&uid=%@&token=%@",minstr([_cellData valueForKey:@"family_url"]),[Config getOwnID],[Config getOwnToken]];
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = loadUrl;
    [[YBAppDelegate sharedAppDelegate] pushViewController:web animated:YES];
}
@end
