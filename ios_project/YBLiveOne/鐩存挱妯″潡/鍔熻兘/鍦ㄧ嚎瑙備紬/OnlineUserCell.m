//
//  OnlineUserCell.m
//  YBLive
//
//  Created by ybRRR on 2023/6/25.
//  Copyright © 2023 cat. All rights reserved.
//

#import "OnlineUserCell.h"
@implementation OnlineUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+(OnlineUserCell*)cellWithTab:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    OnlineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlineUserCell"];
     if (!cell) {
             cell = [[[NSBundle mainBundle]loadNibNamed:@"OnlineUserCell" owner:nil options:nil]objectAtIndex:0];
     }
     return cell;

}
-(void)setDataDic:(NSDictionary *)dataDic
{
    [_avatarImg sd_setImageWithURL:[NSURL URLWithString:minstr([dataDic valueForKey:@"avatar_thumb"])]];
    _nameLb.text = minstr([dataDic valueForKey:@"user_nickname"]);
    if ([minstr([dataDic valueForKey:@"sex"]) isEqual:@"1"])
   {
       _sexView.backgroundColor = RGB_COLOR(@"#5F83F3", 1);
       _sexImg.image = [UIImage imageNamed:@"online_nan"];
   }
   else
   {
       _sexView.backgroundColor = normalColors;
       _sexImg.image = [UIImage imageNamed:@"online_nv"];
   }
    _ageLb.text = minstr([dataDic valueForKey:@"age"]);
    _votesLb.text =[NSString stringWithFormat:@"%@%@",minstr([dataDic valueForKey:@"contribution"]),[common name_votes]] ;
    _addressLb.text =minstr([dataDic valueForKey:@"city"]);
}
@end
