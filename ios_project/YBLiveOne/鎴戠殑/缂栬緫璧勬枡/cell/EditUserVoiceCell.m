//
//  EditUserVoiceCell.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/12/10.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "EditUserVoiceCell.h"

@implementation EditUserVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.audioImg];
    _titleL.text = YZMsg(@"语音");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(UIImageView *)audioImg{
    if (!_audioImg) {
        _audioImg = [[UIImageView alloc]init];
        _audioImg.frame =CGRectMake(_window_width/2,self.contentView.height/2-15, _window_width/2*0.8, 30);
        _audioImg.backgroundColor = normalColors;
        _audioImg.userInteractionEnabled = YES;
        _audioImg.layer.cornerRadius = 15;
        _audioImg.layer.masksToBounds = YES;
        _audioImg.hidden = YES;
        
        _animationView = [[YYAnimatedImageView alloc]init];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"trendslistaudeo" withExtension:@"gif"];
        _animationView.yy_imageURL = url;
        _animationView.hidden = YES;
        [_audioImg addSubview:_animationView];
        [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_audioImg);
            make.left.equalTo(_audioImg).offset(20);
            make.width.equalTo(_audioImg).multipliedBy(0.6);
            make.height.mas_equalTo(30);
        }];

        
        _vioceImgNormal = [[UIImageView alloc]init];
        _vioceImgNormal.image =[UIImage imageNamed:@"icon_voice_play_1"];
        _vioceImgNormal.userInteractionEnabled = YES;
        [_audioImg addSubview:_vioceImgNormal];
        [_vioceImgNormal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_audioImg);
            make.left.equalTo(_audioImg).offset(20);
            make.width.equalTo(_audioImg).multipliedBy(0.6);
            make.height.mas_equalTo(18);

        }];

        _voiceTimeLb = [[UILabel alloc]init];
        _voiceTimeLb.textColor =[UIColor whiteColor];
        _voiceTimeLb.font = [UIFont systemFontOfSize:14];
        [_audioImg addSubview:_voiceTimeLb];
        [_voiceTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_vioceImgNormal.mas_right).offset(8);
            make.centerY.equalTo(_audioImg.mas_centerY);
            make.right.equalTo(_audioImg.mas_right);
            make.height.mas_equalTo(16);
        }];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioImgClick)];
        [_audioImg addGestureRecognizer:singleTap];
    }
    return _audioImg;

}
-(void)audioImgClick{
    if (self.voiceEvent) {
        self.voiceEvent();
    }
}
@end
