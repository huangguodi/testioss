//
//  LoginCountryCodeCell.h
//  YBPlaying
//
//  Created by YB007 on 2020/12/21.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LoginCountryCodeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameL;

+(LoginCountryCodeCell *)cellWithTab:(UITableView *)table index:(NSIndexPath *)index;

@end


