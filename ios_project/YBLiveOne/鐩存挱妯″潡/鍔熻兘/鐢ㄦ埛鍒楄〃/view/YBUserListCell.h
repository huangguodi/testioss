//
//  YBUserListCell.h
//  YBVideo
//
//  Created by YB007 on 2019/12/3.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YBUserListModel.h"

@interface YBUserListCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageV;
@property(nonatomic,strong)UIImageView *levelimage;
@property(nonatomic,strong)YBUserListModel *model;
@property(nonatomic,strong)UIImageView *kuang;

+(YBUserListCell *)collectionview:(UICollectionView *)collectionview andIndexpath:(NSIndexPath *)indexpath;

@end


