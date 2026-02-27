//
//  YBLookVideoCell.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "YBLookVideoCell.h"
#import "PersonMessageViewController.h"
@implementation YBLookVideoCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.backImgV];
        [self.backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerX.centerY.equalTo(self.contentView);
        }];
        [self creatUI];
    }
    return self;

}
- (UIImageView *)backImgV {
    if (!_backImgV) {
        _backImgV = [[UIImageView alloc] init];
        _backImgV.userInteractionEnabled = YES;
        _backImgV.backgroundColor = [UIColor blackColor];
        _backImgV.tag =191107;
        _backImgV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backImgV;
}

- (void)creatUI{
    UIButton *rightBtn = [UIButton buttonWithType:0];
    rightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"三点白"] forState:0];
    [self.contentView  addSubview:rightBtn];


    NSArray *btnArray;
    NSArray *titleArray;
    if([[YBYoungManager shareInstance]isOpenYoung])
    {
        btnArray = @[@"video--分享",@"video--评论",[_model.islike isEqual:@"1"] ? @"home_zan_sel":@"home_zan"];
        titleArray = @[@"0",@"0",@"0"];

    }else{
        btnArray = @[@"video--视频语音",@"video--礼物",@"video--分享",@"video--评论",[_model.islike isEqual:@"1"] ? @"home_zan_sel":@"home_zan"];
        titleArray = @[@"",@"",@"0",@"0",@"0"];

    }

    for (int i = 0; i < btnArray.count; i ++) {

        UILabel *label = [[UILabel alloc]init];
        label.font = SYS_Font(11);
        label.textColor = [UIColor whiteColor];
        label.text = titleArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(25);
            make.bottom.equalTo(self.contentView).offset(-(30+60*i));
        }];
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setImage:[UIImage imageNamed:btnArray[i]] forState:0];
        [btn addTarget:self action:@selector(rightBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(label);
            make.bottom.equalTo(label.mas_top);
            make.width.height.mas_equalTo(30);
        }];
        [btn setTitle:btnArray[i] forState:0];
        [btn setTitleColor:[UIColor clearColor] forState:0];
        btn.tag = 1000+i;
        if([[YBYoungManager shareInstance]isOpenYoung]){
            if ([btnArray[i] rangeOfString:@"home_zan"].location != NSNotFound) {
                likesL = label;
                likeBtn = btn;
            }
            if ([btnArray[i] isEqual:@"video--评论"]) {
                _viewsL = label;
            }
            if ([btnArray[i] isEqual:@"video--分享"]) {
                sharesL = label;
            }

        }else{
            if (i == 0) {
                callBtn = btn;
            }
            if ([btnArray[i] rangeOfString:@"home_zan"].location != NSNotFound) {
                likesL = label;
                likeBtn = btn;
            }
            if ([btnArray[i] isEqual:@"video--评论"]) {
                _viewsL = label;
            }
            if ([btnArray[i] isEqual:@"video--分享"]) {
                sharesL = label;
            }
            if ([btnArray[i] isEqual:@"video--礼物"]) {
                giftBtn = btn;
            }

        }
    }

    titleL = [[UILabel alloc]init];
    titleL.textColor = [UIColor whiteColor];
    titleL.font = SYS_Font(12);
    titleL.numberOfLines = 0;
    titleL.text = _model.title;
    [self.contentView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-80);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];

    iconV = [[UIImageView alloc]init];
    iconV.contentMode= UIViewContentModeScaleAspectFill;
    iconV.clipsToBounds = YES;
    iconV.layer.cornerRadius = 25;
    iconV.layer.masksToBounds = YES;
    iconV.userInteractionEnabled = YES;
    [self.contentView addSubview:iconV];
    [iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(titleL.mas_top).offset(-15);
        make.height.width.mas_equalTo(50);
    }];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconClick)];
    [iconV addGestureRecognizer:tapGesture];
    
    nameL = [[UILabel alloc]init];
    nameL.textColor = [UIColor whiteColor];
    nameL.font = SYS_Font(16);
    [self.contentView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconV.mas_right).offset(3);
        make.top.equalTo(iconV);
        make.height.equalTo(iconV).multipliedBy(0.5);
    }];
    followBtn = [UIButton buttonWithType:0];
    [followBtn setImage:[UIImage imageNamed:@"video--关注"] forState:0];
    [followBtn setImage:[UIImage imageNamed:@"video--已关注"] forState:UIControlStateSelected];
    [followBtn addTarget:self action:@selector(dofollow) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:followBtn];
    [followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameL.mas_right).offset(5);
        make.centerY.equalTo(nameL);
        make.height.mas_equalTo(15);
    }];
    stateImgV = [[UIImageView alloc]init];
    onlineArr = @[@"离线",@"勿扰",@"在聊",@"在线"];

    [self.contentView addSubview:stateImgV];
    [stateImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameL);
        make.top.equalTo(nameL.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(36);
    }];

}
-(void)iconClick{
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":minstr([_userDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *subDic = [info firstObject];
            PersonMessageViewController *person = [[PersonMessageViewController alloc]init];
            person.liveDic = subDic;
            [[YBAppDelegate sharedAppDelegate] pushViewController:person animated:YES];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
-(void)setModel:(videoModel *)model
{
    _model = model;
    _userDic = model.userDic;
    NSString *str = @"";
    if ([minstr([_userDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_userDic valueForKey:@"isvoice"]) isEqual:@"1"]) {
        callType = 1;
        str = @"video--视频语音";
        callBtn.userInteractionEnabled = YES;

    }else if ([minstr([_userDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_userDic valueForKey:@"isvoice"]) isEqual:@"0"]){
        callType = 2;
        str = @"video--视频";
        callBtn.userInteractionEnabled = YES;

    }else if ([minstr([_userDic valueForKey:@"isvideo"]) isEqual:@"0"] && [minstr([_userDic valueForKey:@"isvoice"]) isEqual:@"1"]){
        callType = 3;
        str = @"video--语音";
        callBtn.userInteractionEnabled = YES;
    }else{
        callBtn.userInteractionEnabled = NO;
    }
    [callBtn setImage:[UIImage imageNamed:str] forState:0];
    [_backImgV sd_setImageWithURL:[NSURL URLWithString:minstr(model.thumb)] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];

    [iconV sd_setImageWithURL:[NSURL URLWithString:minstr([_userDic valueForKey:@"avatar_thumb"])]];
    NSString * _shares =_model.shares;
    NSString * _likes = _model.likes;
    NSString * _islike = _model.islike;
    NSString * _views = model.comments;//评论数量
    //点赞数 评论数 分享数
    if ([_islike isEqual:@"1"]) {
        [likeBtn setImage:[UIImage imageNamed:@"home_zan_sel"] forState:0];
    } else{
        [likeBtn setImage:[UIImage imageNamed:@"home_zan"] forState:0];
    }
    likesL.text = _likes;
    _viewsL.text = _views;
    sharesL.text = _shares;
    nameL.text = minstr([_userDic valueForKey:@"user_nickname"]);
    titleL.text = _model.title;
    
    int isattent = 0;
    if (![YBToolClass checkNull:minstr([_userDic valueForKey:@"isattent"])]) {
        isattent = [minstr([_userDic valueForKey:@"isattent"]) intValue];
    }else {
        isattent = [_model.isattent intValue];
    }
    followBtn.selected = isattent;
    /*
    if ([minstr([_userDic valueForKey:@"isattent"]) isEqual:@"1"]) {
        followBtn.selected = YES;
    }else{
        followBtn.selected = NO;
    }
    */
    NSString *imgStr = [NSString stringWithFormat:@"主页状态-%@",onlineArr[[minstr([_userDic valueForKey:@"online"]) intValue]]];
    stateImgV.image = [UIImage imageNamed:getImagename(imgStr)];
    if ([minstr([_userDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
        followBtn.hidden = YES;
        callBtn.hidden = YES;
        giftBtn.hidden = YES;
    }else{
        followBtn.hidden = NO;
        callBtn.hidden = NO;
        giftBtn.hidden = NO;

    }

}

- (void)rightBtnClick{
    if (self.cellBtnEvent) {
        self.cellBtnEvent(@"更多", _model, _userDic);
    }
}

- (void)rightBtnCLick:(UIButton *)sender{
    NSString *str = sender.titleLabel.text;
    if ([str rangeOfString:@"home_zan"].location != NSNotFound) {
        [self doLike];
    }else{
        if ([str isEqual:@"video--分享"]) {
            [self doShare];
        }else if ([str isEqual:@"video--礼物"]) {
            if (self.cellBtnEvent) {
                self.cellBtnEvent(@"礼物", _model, _userDic);
            }
        }else if ([str isEqual:@"video--评论"]) {
            if (self.cellBtnEvent) {
                self.cellBtnEvent(@"评论", _model, _userDic);
            }

        }else{
            if ([self.delegate respondsToSelector:@selector(callBtnWithType:andModel:andUserDic:)]) {
                [self.delegate callBtnWithType:callType andModel:_model andUserDic:_userDic];
            }
        }
    }
}
#pragma mark----点击关注
- (void)dofollow{
    [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":minstr([_userDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            _model.isattent = minstr([infoDic valueForKey:@"isattent"]);
            NSDictionary *notiDic = @{
                @"uid":minstr([_model.userDic valueForKey:@"id"]),
                @"isattent":_model.isattent,
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:ybFollowUser object:nil userInfo:notiDic];
            if ([minstr([infoDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                followBtn.selected = YES;
            }else{
                followBtn.selected = NO;
            }
        }
        [MBProgressHUD showError:msg];
        
    } fail:^{
        
    }];

}
#pragma mark----点赞
- (void)doLike{
    NSString *sign = [YBToolClass sortString:@{@"uid":[Config getOwnID],@"videoid":_model.videoID}];

   NSMutableArray *zanImgArray = [NSMutableArray array];
    for (int i = 0; i < 15; i ++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_video_zan_%02d",i+1]];
        [zanImgArray addObject:image];
    }

    [YBToolClass postNetworkWithUrl:@"Video.AddLike" andParameter:@{@"videoid":_model.videoID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            _model.islike = minstr([dic valueForKey:@"islike"]);
            _model.likes = minstr([dic valueForKey:@"nums"]);
            likesL.text = _model.likes;
            NSDictionary *newDic = @{@"islike":minstr([dic valueForKey:@"islike"]),@"likes":minstr([dic valueForKey:@"nums"])};

            if (self.cellBtnEvent) {
                self.cellBtnEvent(@"点赞", _model, newDic);
            }

            if ([minstr([dic valueForKey:@"islike"]) isEqual:@"1"]) {
                likeBtn.imageView.animationImages = zanImgArray;//将序列帧数组赋给UIImageView的animationImages属性
                likeBtn.imageView.animationDuration = 1;//设置动画时间
                likeBtn.imageView.animationRepeatCount = 1;//设置动画次数 0 表示无限
                [likeBtn.imageView startAnimating];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [likeBtn setImage:[UIImage imageNamed:@"home_zan_sel"] forState:0];
                });
            }else{
                [likeBtn setImage:[UIImage imageNamed:@"home_zan"] forState:0];
            }
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}
-(void)doShare{
    if (!shareView) {
        shareView = [[fenXiangView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        shareView.delegate = self;
        NSDictionary *dic = @{
                              @"title":_model.title,
                              @"videoid":_model.videoID,
                              @"user_nickname":[_userDic valueForKey:@"user_nickname"],
                              @"avatar_thumb":[_userDic valueForKey:@"avatar_thumb"]
                              };
        [shareView GetDIc:dic];
        [self.contentView addSubview:shareView];
    }
    [shareView show];

}
- (void)shareSuccess{
    NSString *sign = [YBToolClass sortString:@{@"uid":[Config getOwnID],@"videoid":_model.videoID}];

    [YBToolClass postNetworkWithUrl:@"Video.AddShare" andParameter:@{@"videoid":_model.videoID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            _model.shares = minstr([dic valueForKey:@"nums"]);
            sharesL.text = _model.shares;
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}

@end
