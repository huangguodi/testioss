//
//  GuardRankCell.h
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/9.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuardRankModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GuardRankCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *kkIV;  //边框
@property (weak, nonatomic) IBOutlet UILabel *otherMCL;  //名次

#pragma mark - 公用
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *levelIV;
@property (weak, nonatomic) IBOutlet UILabel *moneyL;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UILabel *votesL;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (nonatomic,strong) GuardRankModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *sexImgView;

+(GuardRankCell*)cellWithTab:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
