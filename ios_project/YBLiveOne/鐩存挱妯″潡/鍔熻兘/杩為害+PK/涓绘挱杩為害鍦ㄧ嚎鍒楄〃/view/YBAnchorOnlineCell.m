//
//  YBAnchorOnlineCell.m
//  yunbaolive
//
//  Created by Boom on 2018/11/13.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "YBAnchorOnlineCell.h"

@implementation YBAnchorOnlineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)linkBtnClick:(id)sender {
    
    if (self.anchorOnlineCellEvent) {
        self.anchorOnlineCellEvent(_dataDic);
    }
    
}

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
    
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:minstr([_dataDic valueForKey:@"avatar"])]];
    _nameL.text = minstr([_dataDic valueForKey:@"user_nickname"]);
    if ([minstr([_dataDic valueForKey:@"sex"]) isEqual:@"1"]) {
        _sexImgView.image = [UIImage imageNamed:@"bullet-男"];
    }else{
        _sexImgView.image = [UIImage imageNamed:@"bullet-女"];
    }
    /*
    NSDictionary *levelDic = [common getAnchorLevelMessage:_model.level];
    [_levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
    */
    _linkBtn.layer.borderWidth = 1.0;
    if (![minstr([_dataDic valueForKey:@"pkuid"]) isEqual:@"0"]) {
        _linkBtn.layer.borderColor = RGB_COLOR(@"#c7c8c9", 1).CGColor;
        [_linkBtn setTitleColor:RGB_COLOR(@"#c7c8c9", 1) forState:0];
        _linkBtn.userInteractionEnabled = NO;
        [_linkBtn setTitle:YZMsg(@"已邀请") forState:0];
    }else{
        _linkBtn.layer.borderColor = Pink_Cor.CGColor;
        [_linkBtn setTitleColor:Pink_Cor forState:0];
        _linkBtn.userInteractionEnabled = YES;
        [_linkBtn setTitle:YZMsg(@"邀请连麦") forState:0];
    }
    
}
@end
