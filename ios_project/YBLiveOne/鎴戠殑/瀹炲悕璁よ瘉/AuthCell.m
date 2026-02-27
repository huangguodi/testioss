//
//  AuthCell.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/11/26.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "AuthCell.h"

@implementation AuthCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+(AuthCell*)cellWithTab:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    AuthCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AuthCell"];
     if (!cell) {
             cell = [[[NSBundle mainBundle]loadNibNamed:@"AuthCell" owner:nil options:nil]objectAtIndex:0];
     }
     return cell;

}
-(void)setCellData:(NSDictionary *)cellData
{
    //status：-1 没有提交认证  0 审核中  1  通过  2 拒绝

    _cellData = cellData;
    _titleLb.text = minstr([cellData valueForKey:@"auth_title"]);
    [_titleImg sd_setImageWithURL:[NSURL URLWithString:minstr([cellData valueForKey:@"auth_icon"])]];
    if ([minstr([cellData valueForKey:@"status"]) isEqual:@"1"]) {
        _statuImg.image = [UIImage imageNamed:@"authstatusselect"];
    }else{
        _statuImg.image = [UIImage imageNamed:@"authstatusnormal"];

    }
}
@end
