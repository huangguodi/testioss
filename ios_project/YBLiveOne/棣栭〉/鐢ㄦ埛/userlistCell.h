//
//  userlistCell.h
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface userlistCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImgV;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UIImageView *seximgv;
@property (weak, nonatomic) IBOutlet UIImageView *levelimgv;
@property (weak, nonatomic) IBOutlet UIImageView *authimg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authwidconiast;

@property (weak, nonatomic) IBOutlet UIImageView *statusImgv;

@property (nonatomic,strong) SearchModel *model;
+(userlistCell*)cellWithTab:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
