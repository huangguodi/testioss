//
//  OnlineUserCell.h
//  YBLive
//
//  Created by ybRRR on 2023/6/25.
//  Copyright © 2023 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OnlineUserCell : UITableViewCell
@property (nonatomic, strong)NSDictionary *dataDic;
@property (strong, nonatomic) IBOutlet UILabel *numLb;
@property (strong, nonatomic) IBOutlet UILabel *nameLb;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImg;
@property (strong, nonatomic) IBOutlet UIImageView *sexImg;
@property (strong, nonatomic) IBOutlet UILabel *ageLb;
@property (strong, nonatomic) IBOutlet UILabel *votesLb;
@property (strong, nonatomic) IBOutlet UIView *sexView;
@property (strong, nonatomic) IBOutlet UILabel *addressLb;

+(OnlineUserCell*)cellWithTab:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
