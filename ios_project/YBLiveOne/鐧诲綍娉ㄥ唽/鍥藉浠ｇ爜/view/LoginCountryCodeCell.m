//
//  LoginCountryCodeCell.m
//  YBPlaying
//
//  Created by YB007 on 2020/12/21.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "LoginCountryCodeCell.h"

@implementation LoginCountryCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(LoginCountryCodeCell *)cellWithTab:(UITableView *)table index:(NSIndexPath *)index {
    LoginCountryCodeCell *cell = [table dequeueReusableCellWithIdentifier:@"LoginCountryCodeCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"LoginCountryCodeCell" owner:nil options:nil]objectAtIndex:0];
    }
    cell.backgroundColor = UIColor.whiteColor;
    cell.contentView.backgroundColor = UIColor.whiteColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
