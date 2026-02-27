//
//  YBAnchorLinkInfo.m
//  YBVideo
//
//  Created by YB007 on 2022/3/3.
//  Copyright © 2022 cat. All rights reserved.
//

#import "YBAnchorLinkInfo.h"
#import "YBLiveSocket.h"

@interface YBAnchorLinkInfo(){
    /// 对方主播
    UIView *_toLiveBox;
    UIImageView *_toIconIV;
    UILabel *_toNameL;
    UIImageView *_toFollowIV;
    NSString *_toHostUid;
}
@property(nonatomic,assign)int toIsattent;
@end


@implementation YBAnchorLinkInfo

+(YBAnchorLinkInfo *)showHostInfoWithSuperView:(UIView *)superView{
    YBAnchorLinkInfo *view = [[YBAnchorLinkInfo alloc]init];
    [superView addSubview:view];
    /**
     *要参考PK进度条的位置
     *CGRectMake(0, 130+statusbarHeight, _window_width, _window_width*2/3+20)
     */
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView.mas_top).offset(130+statusbarHeight+_window_width*2/3-35);
        make.right.right.equalTo(superView.mas_right).offset(-10);
        make.left.greaterThanOrEqualTo(superView.mas_centerX).offset(45);
        make.height.mas_equalTo(26);
    }];
    [view createUI];
    return view;
}

-(void)keyboardChangeHeight:(CGFloat)height {
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.superview.mas_top).offset(130+statusbarHeight+_window_width*2/3-35+height);
        make.right.right.equalTo(self.superview.mas_right).offset(-10);
        make.left.greaterThanOrEqualTo(self.superview.mas_centerX).offset(45);
        make.height.mas_equalTo(26);
    }];
}

-(void)createUI {
    /// 主播信息
    _toLiveBox = [[UIView alloc]init];
    _toLiveBox.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    _toLiveBox.layer.cornerRadius = 13;
    [self addSubview:_toLiveBox];
    [_toLiveBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerX.centerY.equalTo(self);
    }];
    
    _toIconIV = [[UIImageView alloc]init];
    _toIconIV.contentMode = UIViewContentModeScaleAspectFill;
    _toIconIV.layer.cornerRadius = 12;
    _toIconIV.layer.masksToBounds = YES;
    [_toLiveBox addSubview:_toIconIV];
    [_toIconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_toLiveBox.mas_left).offset(1);
        make.centerY.equalTo(_toLiveBox);
        make.width.height.mas_equalTo(24);
    }];
    
    _toNameL = [[UILabel alloc]init];
    _toNameL.textColor = UIColor.whiteColor;
    _toNameL.font = SYS_Font(13);
    [_toLiveBox addSubview:_toNameL];
    [_toNameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_toIconIV.mas_right).offset(2);
        make.centerY.equalTo(_toLiveBox);
    }];
    
    _toFollowIV = [[UIImageView alloc]init];
    _toFollowIV.contentMode = UIViewContentModeScaleAspectFill;
    [_toLiveBox addSubview:_toFollowIV];
    [_toFollowIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_toNameL.mas_right).offset(2);
        make.centerY.equalTo(_toLiveBox);
        make.width.height.mas_equalTo(22);
        make.right.equalTo(_toLiveBox.mas_right).offset(-2);
    }];
    _toLiveBox.hidden = YES;
}

-(void)reqToHostInfo:(NSString*)toHostid; {
    NSLog(@"pkpkpkpkkppk=======：%@",toHostid);
    _toHostUid = toHostid;
    if ([_toHostUid intValue]>0) {
        WeakSelf;
        [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":_toHostUid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                _toLiveBox.hidden = NO;
                NSDictionary *infoDic = [info firstObject];
                [_toIconIV sd_setImageWithURL:[NSURL URLWithString:minstr([infoDic valueForKey:@"avatar"])]];
                _toNameL.text = minstr([infoDic valueForKey:@"user_nickname"]);
                _toFollowIV.image = [UIImage imageNamed:@"link_follow"];
                int isattention = [minstr([infoDic valueForKey:@"isattent"]) intValue];
                weakSelf.toIsattent = isattention;
                if (weakSelf.attentEvent) {
                    weakSelf.attentEvent(isattention);
                }
                [weakSelf changePkFolloUI:isattention];
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^{
            
        }];
    }
}
/// 关注
-(void)updateFollow;{
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"User.setAttent" andParameter:@{@"touid":_toHostUid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0) {
            NSString *infoDic = [info firstObject];
            int isattention = [minstr([infoDic valueForKey:@"isattent"]) intValue];
            if (weakSelf.attentEvent) {
                weakSelf.attentEvent(isattention);
            }
            [weakSelf changePkFolloUI:isattention];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

-(void)changePkFolloUI:(int)isattention {
    _toFollowIV.hidden = isattention;
    [_toFollowIV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_toNameL.mas_right).offset(2);
        make.centerY.equalTo(_toFollowIV.superview);
        make.height.mas_equalTo(22);
        if (isattention == 1) {
            make.width.mas_equalTo(0);
        }else{
            make.width.mas_equalTo(22);
        }
        make.right.equalTo(_toFollowIV.superview.mas_right).offset(-2);
    }];
}


@end
