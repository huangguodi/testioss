//
//  SearchCell.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _yuyueImgV.image = [UIImage imageNamed:getImagename(@"已预约")];
    [_fuyueBtn setTitle:YZMsg(@"赴约") forState:0];
}
-(void)setModel:(SearchModel *)model{
    _model = model;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _nameL.text = _model.user_nickname;
    if ([_model.isVip isEqual:@"1"]) {
        _vipImgV.hidden = NO;
        _authcoinst.constant = 26;
        _videoaudioconst.constant = 26;
    }else{
        _vipImgV.hidden = YES;
        _authcoinst.constant = 3;
        _videoaudioconst.constant = 3;
    }
    //0 搜索   1粉丝  2关注   3、6 预约  5拉黑
  
    if (_fromType == 0){
        _levelconstain.constant = 18;
        _isauthImgV.hidden = NO;
    }else{
        _levelconstain.constant = 3;
        _isauthImgV.hidden = YES;
    }
    if (_fromType == 0) {
        _IDL.text = [NSString stringWithFormat:@"ID：%@",_model.userID];
       
        if ([_model.sex isEqual:@"1"]) {
            _sexImgV.image = [UIImage imageNamed:@"person_性别男"];
        }else{
            _sexImgV.image = [UIImage imageNamed:@"person_性别女"];
        }
        if ([_model.isauthor_auth isEqual:@"1"]) {
            [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];
            _isauthImgV.image = [UIImage imageNamed:getImagename(@"yirenzheng")];
            _authwidcoinst.constant = 36;
            _fansL.text = [NSString stringWithFormat:@"%@：%@",YZMsg(@"粉丝"),_model.fans];
        }else{
            [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:_model.level]]];
            _isauthImgV.image = [UIImage imageNamed:getImagename(@"weirenzheng")];
            _authwidcoinst.constant = 26;
            _fansL.text = @"";
        }
        
    }else if (_fromType == 2){
        _IDL.text = [NSString stringWithFormat:@"ID：%@",_model.userID];
        _fansL.text = [NSString stringWithFormat:@"%@：%@",YZMsg(@"粉丝"),_model.fans];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];
        
    }
    else if (_fromType == 1){
        if ([YBToolClass checkNull:_model.fans]){
            _fansL.text = [NSString stringWithFormat:@"%@：%@",YZMsg(@"粉丝"),@"0"];
        }else{
            _fansL.text = [NSString stringWithFormat:@"%@：%@",YZMsg(@"粉丝"),_model.fans];
        }
       
        _IDL.text = [NSString stringWithFormat:@"%@：%@",YZMsg(@"ID"),_model.userID];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:_model.level]]];
        _coinImgV.hidden = YES;
    }else if (_fromType == 6){
        _fansL.text = @"";
        _IDL.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"ID："),_model.userID];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:_model.level]]];
        _coinImgV.hidden = YES;
        
        if ([_model.type isEqual:@"1"]) {
            //视频
            _vatypeImgV.image = [UIImage imageNamed:@"home_可视频.png"];
        }else{
            //语音
            _vatypeImgV.image = [UIImage imageNamed:@"home_可语音.png"];
        }

    }else{
        _fansL.text = @"";
        _IDL.text = [NSString stringWithFormat:@"ID：%@",_model.userID];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];

    }
}
- (IBAction)cellBtnClick:(id)sender {
    if (self.delegate) {
        [self.delegate cellBtnClick:_model];
    }
}

@end
