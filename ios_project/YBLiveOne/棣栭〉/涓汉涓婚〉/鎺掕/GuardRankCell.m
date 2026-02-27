//
//  GuardRankCell.m
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/9.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "GuardRankCell.h"

@implementation GuardRankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+(GuardRankCell *)cellWithTab:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    GuardRankCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"GuardRankCell" owner:nil options:nil]objectAtIndex:0];
    }
    cell.iconIV.layer.masksToBounds = YES;
    cell.iconIV.layer.cornerRadius = 20;
//    [cell.contentView layoutIfNeeded];
//    [cell.backView layoutIfNeeded];

    if(indexPath.row == 0){
        cell.backView.frame = CGRectMake(16, 0,_window_width-30 , 75);

        [cell.backView jk_setRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight radius:16];
    }
    return cell;
}

-(void)setModel:(GuardRankModel *)model {
    _model = model;
    [_iconIV sd_setImageWithURL:[NSURL URLWithString:_model.iconStr] placeholderImage:[UIImage imageNamed:@"bg1"]];
    _nameL.text = _model.unameStr;
    [_levelIV sd_setImageWithURL:[NSURL URLWithString:minstr([common getUserLevelMessage:_model.levelStr])]];
    _votesL.text = [common name_votes];
    _moneyL.text = _model.totalCoinStr;
    
    if ([_model.sex isEqual:@"1"]) {
        self.sexImgView.image = [UIImage imageNamed:@"sex_man"];
    }else{
        self.sexImgView.image = [UIImage imageNamed:@"sex_woman"];
    }
    self.sexImgView.hidden = YES;
    _levelIV.hidden = YES;
    if ([_model.isAttentionStr isEqual:@"0"]) {
        self.followBtn.selected = NO;
    }else {
        self.followBtn.selected = YES;
    }
}

@end
