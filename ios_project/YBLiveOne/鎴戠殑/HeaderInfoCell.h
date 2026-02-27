//
//  HeaderInfoCell.h
//  YBLiveOne
//
//  Created by ybRRR on 2022/1/19.
//  Copyright © 2022 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, functioType){
    functionType_wallet,
    functionType_attestation,
    functionType_family,
    functionType_meiyan,
    functionType_DND,

};

typedef void(^headerBtnEvent)(NSString *btnType);
@interface HeaderInfoCell : UITableViewCell

@property (nonatomic, strong)NSDictionary *cellData;
@property (nonatomic, copy)headerBtnEvent btnEvent;
@end

