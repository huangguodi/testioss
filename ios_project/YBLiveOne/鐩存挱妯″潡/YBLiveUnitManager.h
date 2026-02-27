//
//  YBLiveUnitManager.h
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/11.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YBLiveUnitManager : NSObject

@property(nonatomic,assign)BOOL onRoom;

+(instancetype)shareInstance;

@property(nonatomic,strong)NSString *liveUid;
@property(nonatomic,strong)NSString *liveStream;

@property(nonatomic,assign)NSInteger currentIndex;
@property(nonatomic,strong)NSArray *listArray;

-(void)checkLiving;

@end


