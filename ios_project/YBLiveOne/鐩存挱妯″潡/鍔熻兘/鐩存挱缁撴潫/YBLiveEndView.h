//
//  YBLiveEndView.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/13.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YBLiveEndView : UIView

@property(nonatomic,copy)LiveBlock liveEndEvent;

-(void)updateData:(NSDictionary *)dic;

@end


