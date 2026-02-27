//
//  recommendCell.h
//  YBLiveOne
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "recommendModel.h"

typedef void(^RecommendCallEvent)(recommendModel *model);
typedef void(^cellChangeHello)(recommendModel *model);

@interface recommendCell : UICollectionViewCell


@property (nonatomic,strong) recommendModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UIImageView *stateImgV;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *levelImgV;
@property (weak, nonatomic) IBOutlet UIImageView *videoImgV;
@property (weak, nonatomic) IBOutlet UIImageView *audioImgV;
@property (weak, nonatomic) IBOutlet UIView *uuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoImgWidthC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *uuHeightC;
@property (weak, nonatomic) IBOutlet UILabel *distanceL;
@property (weak, nonatomic) IBOutlet UIImageView *locationImgV;
@property (weak, nonatomic) IBOutlet UIImageView *openTypeImgV;
@property (weak, nonatomic) IBOutlet UILabel *openTypeL;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@property (nonatomic, copy)RecommendCallEvent callEvent;
@property (nonatomic, copy)cellChangeHello changeHelloEvent;

@end

