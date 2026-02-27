//
//  HomeVideoListCell.h
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeVideoListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImg;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIButton *privateBtn;

@property (nonatomic,strong) NSDictionary *dataInfo;
@end

NS_ASSUME_NONNULL_END
