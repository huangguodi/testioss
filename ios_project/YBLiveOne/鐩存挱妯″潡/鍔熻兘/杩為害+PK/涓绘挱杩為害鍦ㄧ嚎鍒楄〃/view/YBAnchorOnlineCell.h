//
//  YBAnchorOnlineCell.h
//  yunbaolive
//
//  Created by Boom on 2018/11/13.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnchorOnlineCellBlock)(NSDictionary *cellDic);

@interface YBAnchorOnlineCell : UITableViewCell

@property(nonatomic,copy)AnchorOnlineCellBlock anchorOnlineCellEvent;

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *sexImgView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImgView;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn;

@property(nonatomic,strong)NSDictionary *dataDic;

@end


