//
//  EditUserVoiceCell.h
//  YBLiveOne
//
//  Created by ybRRR on 2021/12/10.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>

typedef void(^UserVoiceEvent)();
@interface EditUserVoiceCell : UITableViewCell
{

}
@property(nonatomic,strong)UIImageView *audioImg;
@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property (copy, nonatomic)UserVoiceEvent voiceEvent;
@property (strong, nonatomic)UILabel *voiceTimeLb;
@property (strong, nonatomic)UIImageView *vioceImgNormal;

@property (weak, nonatomic) IBOutlet UILabel *titleL;


@end

