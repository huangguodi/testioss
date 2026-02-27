//
//  YBUserListCell.m
//  YBVideo
//
//  Created by YB007 on 2019/12/3.
//  Copyright © 2019 cat. All rights reserved.
//

#import "YBUserListCell.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

@implementation YBUserListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        /**
         * 64:84
         */
        _kuang = [[UIImageView alloc]init];
        _kuang.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_kuang];
        [_kuang mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerX.centerY.equalTo(self.contentView);
            make.width.equalTo(_kuang.mas_height).multipliedBy(64/84.0);
        }];
        
        _imageV = [[UIImageView alloc]init];
        _imageV.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageV];
        [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_kuang.mas_width);
            make.height.equalTo(_imageV.mas_width);
            make.bottom.equalTo(_kuang.mas_bottom);
            make.centerX.equalTo(_kuang.mas_centerX);
        }];

        _levelimage = [[UIImageView alloc]init];
        _levelimage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_levelimage];
        [_levelimage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10);
            make.width.equalTo(_levelimage.mas_height).multipliedBy(2);
            make.right.equalTo(_imageV.mas_right);
            make.bottom.equalTo(_imageV.mas_bottom);
        }];
        
        //
        [self.contentView layoutIfNeeded];
        _imageV.layer.cornerRadius = _imageV.size.height/2;
        
    }
    return self;
}
-(void)setModel:(YBUserListModel *)model{
    _model = model;
    [_imageV sd_setImageWithURL:[NSURL URLWithString:_model.iconName] placeholderImage:[YBToolClass getAppIcon]];
    /*
    if ([_model.guard_type isEqual:@"0"]) {
        NSDictionary *levelDic = [common getUserLevelMessage:_model.level];
        [_levelimage sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb_mark"])]];
    }else if ([_model.guard_type isEqual:@"1"]){
        _levelimage.image = [UIImage imageNamed:@"chat_shou_month"];
    }else if ([_model.guard_type isEqual:@"2"]){
        _levelimage.image = [UIImage imageNamed:@"chat_shou_year"];
    }
     */

    NSString *levelThumb = [common getUserLevelMessage:model.level];
    [_levelimage sd_setImageWithURL:[NSURL URLWithString:levelThumb]];
   
}
+(YBUserListCell *)collectionview:(UICollectionView *)collectionview andIndexpath:(NSIndexPath *)indexpath{
    YBUserListCell *cell = [collectionview dequeueReusableCellWithReuseIdentifier:@"YBUserListCell" forIndexPath:indexpath];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"YBUserListCell" owner:self options:nil].lastObject;
    }
    return cell;
}
@end
