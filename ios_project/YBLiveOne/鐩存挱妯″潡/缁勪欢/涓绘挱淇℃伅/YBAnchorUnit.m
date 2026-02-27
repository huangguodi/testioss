//
//  YBAnchorUnit.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/5.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBAnchorUnit.h"

#import "YBLiveSocket.h"

@interface YBAnchorUnit()
{
    CGFloat _follow_height;
    CGFloat _follow_space;
    CGFloat _unit_height;
}
@property(nonatomic,strong)UIImageView *iconIV;
@property(nonatomic,strong)UIImageView *levalIV;
@property(nonatomic,strong)UILabel *nameL;
@property(nonatomic,strong)UILabel *idL;
@property(nonatomic,strong)YBButton *followBtn;


@end

@implementation YBAnchorUnit

- (instancetype)init{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI {
    
    CGFloat icon_size = 34;
    CGFloat icon_space = 5;
    _unit_height = icon_size + icon_space * 2;
    _follow_height = 32;
    _follow_space = (_unit_height - _follow_height)/2;
    
    self.backgroundColor = RGB_COLOR(@"#000000", 0.4);
    self.layer.cornerRadius = _unit_height/2;
    
    _iconIV = [[UIImageView alloc]init];
    _iconIV.layer.cornerRadius = icon_size/2;
    _iconIV.layer.masksToBounds = YES;
    _iconIV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_iconIV];
    [_iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(icon_size);
        make.left.top.equalTo(self).offset(icon_space);
        make.bottom.equalTo(self.mas_bottom).offset(-icon_space);
    }];
    
    _levalIV = [[UIImageView alloc]init];
    _levalIV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_levalIV];
    [_levalIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
        make.width.equalTo(_levalIV.mas_height).multipliedBy(2);
        make.right.equalTo(_iconIV.mas_right);
        make.bottom.equalTo(_iconIV.mas_bottom);
    }];
    
    _nameL = [[UILabel alloc]init];
    _nameL.font = SYS_Font(14);
    _nameL.textColor = UIColor.whiteColor;
    [self addSubview:_nameL];
    [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconIV.mas_right).offset(icon_space);
        make.bottom.equalTo(self.mas_centerY);
        make.width.mas_lessThanOrEqualTo(60);
    }];
    
    _idL = [[UILabel alloc]init];
    _idL.font = SYS_Font(12);
    _idL.textColor = UIColor.whiteColor;
    [self addSubview:_idL];
    [_idL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_nameL);
        make.top.equalTo(_nameL.mas_bottom).offset(1);
    }];
    
    _followBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [_followBtn setTitle:YZMsg(@"关注") forState:0];
    _followBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    _followBtn.titleLabel.font = SYS_Font(13);
    _followBtn.layer.cornerRadius = _follow_height/2;
    _followBtn.layer.masksToBounds = YES;
    [_followBtn setTitleColor:[UIColor whiteColor] forState:0];
    [_followBtn setBackgroundImage:[UIImage imageNamed:@"follow_bg"] forState:0];
    [_followBtn addTarget:self action:@selector(clickFollowBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_followBtn];
    // 默认隐藏
    _followBtn.hidden = YES;
    [_followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_follow_height);
        make.centerY.equalTo(self);
        make.left.equalTo(_nameL.mas_right).offset(_follow_space);
        make.right.equalTo(self.mas_right).offset(-_follow_space);
        make.width.mas_equalTo(0);
    }];
    
    // 头像点击事件遮罩【点击范围：头像的左侧至昵称的右侧】
    YBButton *iconShadowBtn = [YBButton buttonWithType:UIButtonTypeCustom];
    [iconShadowBtn addTarget:self action:@selector(clickIconBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:iconShadowBtn];
    [iconShadowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.centerY.equalTo(self);
        make.right.equalTo(_nameL.mas_right);
    }];
    
}
-(void)clickIconBtn:(YBButton *)btn {
    NSDictionary *notiDic = @{
        @"id":minstr([_infoDic valueForKey:@"uid"]),
        @"name":minstr([_infoDic valueForKey:@"user_nickname"]),
    };
    [[NSNotificationCenter defaultCenter]postNotificationName:Live_Notice_Userinfo object:nil userInfo:notiDic];
}
- (void)setInfoDic:(NSDictionary *)infoDic {
    _infoDic = infoDic;
    
    [_iconIV sd_setImageWithURL:[NSURL URLWithString:minstr([_infoDic valueForKey:@"avatar"])] placeholderImage:[YBToolClass getAppIcon]];
    _nameL.text = minstr([_infoDic valueForKey:@"user_nickname"]);
    _idL.text = [NSString stringWithFormat:@"ID:%@",[_infoDic valueForKey:@"uid"]];
    
    NSString *anchorLevel = [common getAnchorLevelMessage:minstr([_infoDic valueForKey:@"level_anchor"])];
    [_levalIV sd_setImageWithURL:[NSURL URLWithString:anchorLevel]];
    
}
-(void)changeAttent:(int)isAttent {
    NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_infoDic];
    [m_dic setObject:@(isAttent) forKey:@"isattention"];
    _infoDic = [NSDictionary dictionaryWithDictionary:m_dic];
    
    _followBtn.hidden = isAttent;
    [_followBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_follow_height);
        make.centerY.equalTo(self);
        make.left.equalTo(_nameL.mas_right).offset(_follow_space);
        make.right.equalTo(self.mas_right).offset(-_follow_space);
        if(isAttent){
            make.width.mas_equalTo(0);
        }
    }];
}



-(void)clickFollowBtn:(YBButton *)btn {
    WeakSelf
    [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":minstr([_infoDic valueForKey:@"uid"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            int isattention = [minstr([infoDic valueForKey:@"isattent"]) intValue];
            [weakSelf changeAttent:isattention];
            
            if(isattention == 1){
                // socket
                // yb_lang
                NSString *socStr = [[Config getOwnNicename] stringByAppendingFormat:@"关注了主播"];
                NSString *socStrEn = [[Config getOwnNicename] stringByAppendingFormat:@" followed the anchor"];
                [[YBLiveSocket shareInstance]socketSendSystem:socStr conStrEn:socStrEn];
            }
            
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}


-(int)getAttent; {
    return (int)_followBtn.hidden;
}

@end
