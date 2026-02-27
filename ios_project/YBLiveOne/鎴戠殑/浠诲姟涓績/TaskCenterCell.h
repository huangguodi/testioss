//
//  TaskCenterCell.h
//  YBLiveOne
//
//  Created by yunbao01 on 2023/12/6.
//  Copyright © 2023 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol taskCenterDelegate <NSObject>

-(void)taskStatusClick:(NSDictionary *)dataDic;
-(void)reloadTaskList;
@end

@interface TaskCenterCell : UITableViewCell

@property(nonatomic, strong)UIButton *statusBtn;


@property(nonatomic, strong)NSDictionary *dataDic;
@property(nonatomic, assign)id<taskCenterDelegate>delegate;
@end

