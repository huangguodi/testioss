//
//  AuthCell.h
//  YBLiveOne
//
//  Created by ybRRR on 2021/11/26.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthCell : UITableViewCell

@property(nonatomic, strong)NSDictionary *cellData;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIImageView *titleImg;
@property (weak, nonatomic) IBOutlet UIImageView *statuImg;

+(AuthCell*)cellWithTab:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath ;
@end
