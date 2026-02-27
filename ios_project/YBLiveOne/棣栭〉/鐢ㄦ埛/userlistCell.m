//
//  userlistCell.m
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "userlistCell.h"

@implementation userlistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+(userlistCell *)cellWithTab:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    userlistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userlistCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"userlistCell" owner:nil options:nil]objectAtIndex:0];
    }
    return cell;
}
-(void)setModel:(SearchModel *)model{
    _model = model;
    _namelabel.text = _model.user_nickname;
    [_headerImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    if ([_model.sex isEqual:@"1"]) {
        _seximgv.image = [UIImage imageNamed:@"person_性别男"];
    }else{
        _seximgv.image = [UIImage imageNamed:@"person_性别女"];
    }
    if ([_model.isauthor_auth isEqual:@"1"]) {
        [_levelimgv sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level]]];
        _authimg.image = [UIImage imageNamed:getImagename(@"yirenzheng")];
        //_statusImgv.hidden = NO;
        _authwidconiast.constant = 36;
    }else{
        [_levelimgv sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:_model.level]]];
        _authimg.image = [UIImage imageNamed:getImagename(@"weirenzheng")];
        //_statusImgv.hidden = YES;
        _authwidconiast.constant = 26;
    }
    NSArray *arr = @[@"离线",@"勿扰",@"在聊",@"在线"];
    
    NSString *imgStr = [NSString stringWithFormat:@"user_%@",arr[[_model.online intValue]]];
    _statusImgv.image = [UIImage imageNamed:getImagename(imgStr)];
    
}
@end
