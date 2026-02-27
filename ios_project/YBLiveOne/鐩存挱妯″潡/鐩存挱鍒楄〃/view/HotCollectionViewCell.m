//
//  HotCollectionViewCell.m
//  YBLive
//
//  Created by Boom on 2018/9/21.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "HotCollectionViewCell.h"

@implementation HotCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _is_adLb.text = YZMsg(@"广告");

}

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
    if (![YBToolClass checkNull:minstr([dataDic valueForKey:@"thumb"])]) {
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:minstr([dataDic valueForKey:@"thumb"])]];
    }else{
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:minstr([dataDic valueForKey:@"avatar"])]];
    }
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:minstr([dataDic valueForKey:@"avatar"])]];
    _nameLabel.text = minstr([_dataDic valueForKey:@"user_nickname"]);
    if (_isNear) {
        _numImgView.image = [UIImage imageNamed:@"live_distence"];
        _numsLabel.text = minstr([_dataDic valueForKey:@"distance"]);
    }else{
        _numsLabel.text = minstr([_dataDic valueForKey:@"nums"]);
        _numImgView.image = [UIImage imageNamed:@"live_nums"];
    }
    _shopImgView.hidden = YES;
    _titleLabel.text = minstr([_dataDic valueForKey:@"title"]);
    if (![YBToolClass checkNull:minstr([_dataDic valueForKey:@"title"])]) {
        if (_jianju1.constant == 5) {
            _jianju1.constant += 5;
            _jianju2.constant += 5;
        }
    }else{
        if (_jianju1.constant == 10) {
            _jianju1.constant -= 5;
            _jianju2.constant -= 5;
            
        }
    }
    int type = [[_dataDic valueForKey:@"type"] intValue];
    switch (type) {
        case 0:
            [_liveTypeImageView setImage:[UIImage imageNamed:getImagename(@"live_普通")]];
            break;
        case 1:
            [_liveTypeImageView setImage:[UIImage imageNamed:getImagename(@"live_密码")]];
            break;
        case 2:
            [_liveTypeImageView setImage:[UIImage imageNamed:getImagename(@"live_付费")]];
            break;
        case 3:
            [_liveTypeImageView setImage:[UIImage imageNamed:getImagename(@"live_计时")]];
            break;
        default:
            break;
    }
}



@end
