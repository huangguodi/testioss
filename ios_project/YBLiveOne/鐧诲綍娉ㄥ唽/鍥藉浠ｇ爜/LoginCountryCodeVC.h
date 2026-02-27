//
//  LoginCountryCodeVC.h
//  YBPlaying
//
//  Created by YB007 on 2020/12/19.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "YBBaseViewController.h"

typedef void (^CountryCodeBlock)(NSString *selCode);

@interface LoginCountryCodeVC : YBBaseViewController

@property(nonatomic,copy)CountryCodeBlock countryEvent;

@end


