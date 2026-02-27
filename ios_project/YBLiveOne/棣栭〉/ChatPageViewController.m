//
//  ChatPageViewController.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/5.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "ChatPageViewController.h"
#import "SJPageViewController.h"
#import "RecommendViewController.h"
#import "FollowViewController.h"
#import "NearByViewController.h"
#import "UserListViewController.h"
#import "HomeNewViewController.h"
#import "UISegmentedControl+YBSegment.h"
#import "SearchViewController.h"
#import "SDCycleScrollView.h"

@interface ChatPageViewController ()<SJPageViewControllerDelegate, SJPageViewControllerDataSource,SDCycleScrollViewDelegate>
{
    UISegmentedControl * segment1;
    RecommendViewController *recommend;
    UserListViewController *userlist;
    UIView *segmentBack;
//    UIView *segmentSub;
    UIButton *screenBtn;
    

}
@property (nonatomic, strong) SJPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic,strong) SDCycleScrollView *cycleScroll;
@property (nonatomic,strong) NSArray *sliderArray;

@end

@implementation ChatPageViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = @[YZMsg(@"推荐"),YZMsg(@"附近"),YZMsg(@"最新"),YZMsg(@"关注"),YZMsg(@"用户")];
    
    
    _cycleScroll = [[SDCycleScrollView alloc]initWithFrame:CGRectMake(10, 64+statusbarHeight, _window_width-20, _window_width*0.293)];//collectionHeaderView.height-
    _cycleScroll.delegate = self;
    _cycleScroll.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    _cycleScroll.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _cycleScroll.autoScrollTimeInterval = 3.0;//轮播时间间隔，默认1.0秒，可自定义
    _cycleScroll.layer.cornerRadius = 20;
    _cycleScroll.layer.borderWidth = 2;
    _cycleScroll.layer.borderColor = RGBA(254, 188, 53, 1).CGColor;
    _cycleScroll.layer.masksToBounds = YES;
    [self.view addSubview:_cycleScroll];
    
//    CGFloat wwww = (_window_width-40)/2;
//    NSArray *function_arr = @[@"home_yuyin",@"home_shipin"];
//    for (int i = 0; i <function_arr.count; i ++) {
//        UIButton *btn = [UIButton buttonWithType:0];
//        btn.frame = CGRectMake((i+1)*10 +i*wwww, _cycleScroll.bottom+10, wwww, wwww*0.5);
//        [btn setImage:[UIImage imageNamed:function_arr[i]] forState:0];
//        [btn addTarget:self action:@selector(functionBtnClilck:) forControlEvents:UIControlEventTouchUpInside];
//        btn.tag = 10000+i;
//        [self.view addSubview:btn];
//    }
    
    segment1 = [[UISegmentedControl alloc]initWithItems:_datas];
    CGFloat byWidth = 0.75;
    int fontSize = 14;
    int fontSizeSel = 16;
    if (![lagType isEqual:ZH_CN]) {
        byWidth = 0.85;
        fontSize = 12;
        fontSizeSel = 12;
    }
    segment1.frame = CGRectMake(10, _cycleScroll.bottom+10, _window_width *byWidth, 40);
    if (@available(iOS 13.0, *)) {
        [segment1 ensureiOS12Style];
    } else {
        segment1.tintColor = [UIColor clearColor];
    }
    NSDictionary *nomalC = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:fontSize],NSFontAttributeName,[UIColor grayColor], NSForegroundColorAttributeName, nil];
    [segment1 setTitleTextAttributes:nomalC forState:UIControlStateNormal];
    
    NSDictionary *selC = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:fontSizeSel],NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil];
    [segment1 setTitleTextAttributes:selC forState:UIControlStateSelected];

    segment1.selectedSegmentIndex = 0;
    if (![lagType isEqual:ZH_CN]) {
        [segment1 setWidth:100 forSegmentAtIndex:0];
    }
    [segment1 addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment1];
    
    _pageViewController = [SJPageViewController pageViewControllerWithOptions:@{SJPageViewControllerOptionInterPageSpacingKey:@(5)}];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    _pageViewController.view.frame =CGRectMake(0, segment1.bottom, _window_width, _window_height-64-statusbarHeight-40);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        _pageViewController.scrollUnenable = YES;
    }
    
    [self setView];
    [self getSlide];
}
-(void)getSlide{
    [YBToolClass postNetworkWithUrl:@"Home.getSlide" andParameter:nil success:^(int code,id info,NSString *msg) {
        
        if (code == 0) {
            NSDictionary *infoA = [info objectAtIndex:0];
            _sliderArray = [infoA valueForKey:@"slide"];
            NSMutableArray *muArr = [NSMutableArray array];
            for (NSDictionary *dic in _sliderArray) {
                [muArr addObject:minstr([dic valueForKey:@"image"])];
            }
            _cycleScroll.imageURLStringsGroup = muArr;
        }
        
    } fail:^{        
    }];
    
}
#pragma mark ============轮播图点击=============
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        return;
    }
    
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = minstr([_sliderArray[index] valueForKey:@"url"]);
    [[YBAppDelegate sharedAppDelegate] pushViewController:web animated:YES];
}


- (void)setView{
    screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    screenBtn.frame = CGRectMake(_window_width-40-12,24 +statusbarHeight,40,40);
    screenBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [screenBtn setImage:[UIImage imageNamed:@"home_shaixuan"] forState:UIControlStateNormal];
    screenBtn.centerY = segment1.centerY;
    [screenBtn addTarget:self action:@selector(screenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenBtn];
}
- (void)screenBtnClick{
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        return;
    }
    
    if (segment1.selectedSegmentIndex == 0) {
        [recommend showYBScreendView];
    }else{
        [userlist showYBScreendView];
    }
   
}
- (void)search{
    SearchViewController *search = [[SearchViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:search animated:YES];
}
- (void)pageViewController:(SJPageViewController *)pageViewController focusedIndexDidChange:(NSUInteger)index;
{
    [segment1 setSelectedSegmentIndex:index];
//    [self setLineFrameWithIndex:index];
}

- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
    return SJPageViewControllerHeaderModePinnedToTop;
}
- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return 0.0001;
}

//返回控制器的数量
- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return _datas.count;
}

// 返回`index`对应的控制器
- (UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {

    if (index == 0) {
        recommend = [[RecommendViewController alloc]init];
        return recommend;
    }
    else if(index == 1){
        NearByViewController *near = [[NearByViewController alloc]init];
        return near;
    }
    else if(index == 2){
        HomeNewViewController *new =[[HomeNewViewController alloc]init];
        return new;

    }else if (index == 3){
        FollowViewController *follow = [[FollowViewController alloc]init];
        return follow;
    }else{
        userlist = [[UserListViewController alloc] init];
        return userlist;

    }

}
- (void)pageViewController:(SJPageViewController *)pageViewController willDisplayViewController:(nullable __kindof UIViewController *)viewController atIndex:(NSInteger)index
{
    segment1.selectedSegmentIndex =index;
    if (index == 0 ||index == 4) {
        screenBtn.hidden = NO;
    }else{
        screenBtn.hidden = YES;
    }

}
- (void)segmentChange:(UISegmentedControl *)seg{
    NSLog(@"点击了-----index:%ld",seg.selectedSegmentIndex) ;
    
    BOOL showLite = [[YBLiteMode shareInstance] checkShow];
    // 基本模式禁止滚动
    if(showLite){
        segment1.selectedSegmentIndex = 0;
        return;
    }
    
    [_pageViewController setViewControllerAtIndex:seg.selectedSegmentIndex];
//    [self setLineFrameWithIndex:seg.selectedSegmentIndex];
    if (seg.selectedSegmentIndex != 0 ||seg.selectedSegmentIndex != 4) {
        screenBtn.hidden = YES;
    }else{
        screenBtn.hidden = NO;
    }

}




@end
