//
//  HotCollectionViewCell.h
//  YBLive
//
//  Created by Boom on 2018/9/21.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *liveTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *numsLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,assign) BOOL isNear;
@property (weak, nonatomic) IBOutlet UIImageView *numImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jianju1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jianju2;
@property (weak, nonatomic) IBOutlet UIImageView *shopImgView;
@property (weak, nonatomic) IBOutlet UILabel *is_adLb;
@property (weak, nonatomic) IBOutlet UIImageView *videoTypeImg;

//@property (nonatomic,strong)hotModel *model;
//@property (nonatomic,strong)NearbyVideoModel *videoModel;

@property(nonatomic,strong)NSDictionary *dataDic;


@end


