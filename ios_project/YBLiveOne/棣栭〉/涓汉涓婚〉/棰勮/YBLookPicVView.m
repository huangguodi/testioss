//
//  YBLookPicVView.m
//  YBLiveOne
//
//  Created by 阿庶 on 2021/3/4.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "YBLookPicVView.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
@interface YBLookPicVView()<UIScrollViewDelegate>
{
    UIScrollView *topScroll;
    UIImageView *playerImgview;
    UIPageControl *pageControl;
    NSArray *_topImgArr;
    NSInteger _currentindex;

}
@property (nonatomic, strong) ZFPlayerController *player;

@end
@implementation YBLookPicVView

- (instancetype)init:(NSArray *)toparray andindex:(NSInteger)currentindex{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = RGB_COLOR(@"#000000", 1);
        _topImgArr = toparray;
        _currentindex = currentindex;
        [self creatUI];
    }
    return self;
}
-(void)creatUI{
    topScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    topScroll.delegate = self;
    topScroll.pagingEnabled = YES;
    topScroll.backgroundColor = [UIColor blackColor];
    topScroll.showsVerticalScrollIndicator = NO;
    topScroll.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        topScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:topScroll];
    
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, topScroll.bottom - 25, _window_width, 20)];
    pageControl.numberOfPages = _topImgArr.count;
    pageControl.currentPageIndicatorTintColor = RGB_COLOR(@"#E014E2", 1);
    pageControl.pageIndicatorTintColor = RGB_COLOR(@"#b8b4b2", 1);
    pageControl.hidesForSinglePage = YES;
    pageControl.currentPage = _currentindex;
    pageControl.enabled = NO;
    [self addSubview:pageControl];
    
    
    
    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rBtn];
    
    
    topScroll.contentSize = CGSizeMake(_window_width*_topImgArr.count, 0);
    topScroll.contentOffset = CGPointMake(_window_width *_currentindex, 0);
    for (int i = 0; i < _topImgArr.count; i++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*i, 0, _window_width, _window_height)];
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        imgV.clipsToBounds = YES;
        imgV.backgroundColor = [UIColor blackColor];
        [imgV sd_setImageWithURL:[NSURL URLWithString:[_topImgArr[i] valueForKey:@"thumb"]]];
        [topScroll addSubview:imgV];
        if (i == 0 && [minstr([_topImgArr[i] valueForKey:@"type"]) isEqual:@"1"]){
            playerImgview = imgV;
        }
    }
    
    /// playerManager
    /*
    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
    NSString *ijkRef = [NSString stringWithFormat:@"Referer:%@\r\n",h5url];
    [playerManager.options setFormatOptionValue:ijkRef forKey:@"headers"];
    */
    // #import <ZFPlayer/ZFAVPlayerManager.h>
    ZFAVPlayerManager*playerManager = [[ZFAVPlayerManager alloc] init];
    NSDictionary *header = @{@"Referer":h5url};
    NSDictionary *optiosDic = @{@"AVURLAssetHTTPHeaderFieldsKey" : header};
    [playerManager setRequestHeader:optiosDic];

    /// player的tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:playerImgview];
    [self.player setDisableGestureTypes:ZFPlayerDisableGestureTypesAll];
    self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
    self.player.playerDisapperaPercent = 1.0;
    if (playerImgview && _currentindex == 0) {
        [self playerPlay];
    }
    WeakSelf;
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        NSLog(@"结束");
       
        [weakSelf.player.currentPlayerManager replay];
    };
}
-(void)doReturn{
    if (self.block) {
        self.block(0);
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    pageControl.currentPage = scrollView.contentOffset.x/_window_width;
    if (playerImgview) {
        if (pageControl.currentPage == 0) {
            [self playerPlay];
            //[self pauseclick:NO];
        }else{
            //[self pauseclick:YES];
            [self playerStop];
        }
    }
    
}
- (void)playerPlay{
    self.player.assetURL =[NSURL URLWithString:[[_topImgArr firstObject] valueForKey:@"href"]];
    
    //功能
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"准备");
    };
    WeakSelf;
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        NSLog(@"结束");
        [weakSelf.player.currentPlayerManager replay];
    };

}
-(void)playerStop {
    [self.player stop];
}
-(void)pauseclick:(BOOL)ispause{
   
    [self.player setPauseByEvent:ispause];
}
@end
