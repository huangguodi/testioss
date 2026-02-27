//
//  HomeVideoVC.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/5/6.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "HomeVideoVC.h"
#import "HomeVideoListCell.h"
#import "YBLookVideoVC.h"
#import "YBAlertView.h"
#import "VIPViewController.h"
#import "RechargeViewController.h"
static NSString *identifier = @"HomeVideoListCELL";
@interface HomeVideoVC ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    int page;
    YBAlertView *alert;
    CGFloat oldOffset;

}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;//获取到的主播列表信息

@end

@implementation HomeVideoVC


-(void)pullInternet{
    NSDictionary *parDic = @{@"uid":[Config getOwnID],@"token":[Config getOwnToken],@"p":@(page)};
    [YBToolClass postNetworkWithUrl:@"Video.getRecommendVideos" andParameter:parDic success:^(int code,id info,NSString *msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if (code == 0) {
            if (page == 1) {
                [_infoArray removeAllObjects];
            }
            NSArray *infoA = info;
            [_infoArray addObjectsFromArray:infoA];
            [_collectionView reloadData];

        }
        
    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        if (_infoArray.count == 0) {
        }
        
    }];

}
-(void)pullInternetforNewDown{
    page = 1;
    [self pullInternet];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoArray =  [NSMutableArray array];
    page = 1;
    oldOffset = 0;

    self.view.backgroundColor = UIColor.whiteColor;
    [self createCollectionView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullInternetforNewDown) name:@"RELOADHOMEVIDEOLIST" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followUser:) name:ybFollowUser object:nil];
}
-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/2-7.5, _window_width/2-7.5);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(5, 5,5, 5);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height) collectionViewLayout:flow];
    _collectionView.delegate  = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HomeVideoListCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self pullInternet];
    }];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self pullInternet];
    }];
    
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(64+statusbarHeight, 0, 0, 0);
    [self pullInternet];
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _infoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSDictionary *currentDic =_infoArray[indexPath.item];
    NSMutableDictionary *videoDic =[[NSMutableDictionary alloc]initWithDictionary:currentDic];
//    if ([minstr([videoDic valueForKey:@"isprivate"]) isEqual:@"1"] && ![minstr([videoDic valueForKey:@"uid"]) isEqual:[Config getOwnID]]) {
        
    if ([minstr([currentDic valueForKey:@"cansee"]) isEqual:@"0"]) {
        
        if([[YBYoungManager shareInstance] isOpenYoung]){
            
            UIAlertController *showAlert = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"青少年模式下，不能观看付费视频") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:YZMsg(@"去关闭") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[YBYoungManager shareInstance]checkYoungStatus:YoungFrom_Center];

            }];
            [cancelAction setValue:UIColor.grayColor forKey:@"_titleTextColor"];
            [closeAction setValue:normalColors_live forKey:@"_titleTextColor"];
            [showAlert addAction:cancelAction];
            [showAlert addAction:closeAction];
            [[[YBAppDelegate sharedAppDelegate] topViewController] presentViewController:showAlert animated:YES completion:nil];
        }else{
            NSString *msgTitle = [NSString stringWithFormat:YZMsg(@"该视频为私密视频，需支付%@%@观看\n开通VIP后可免费观看"),minstr([videoDic valueForKey:@"coin"]),[common name_coin]];

            WeakSelf;
            alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:msgTitle andButtonArrays:@[YZMsg(@"开通会员"),YZMsg(@"付费观看")] andButtonClick:^(int type) {
                if (type == 2) {
                    
                    NSString *url  = [NSString stringWithFormat:@"Video.BuyVideo&videoid=%@",minstr([videoDic valueForKey:@"id"])];
                    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                        if (code == 0) {
                            NSDictionary *infoDic = [info firstObject];

                            NSDictionary *newDic = @{@"cansee":@"1",@"href":minstr([infoDic valueForKey:@"href"])};
                            [videoDic addEntriesFromDictionary:newDic];
                            [_infoArray replaceObjectAtIndex:indexPath.row withObject:videoDic];

                            YBLookVideoVC *ybLook = [[YBLookVideoVC alloc]init];
                            ybLook.pushPlayIndex = indexPath.item;
                            ybLook.sourceBaseUrl  =minstr([infoDic valueForKey:@"href"]);
                            ybLook.videoList = _infoArray;
                            ybLook.pages =page;
                            [[YBAppDelegate sharedAppDelegate] pushViewController:ybLook animated:YES];

                        }else if (code == 1005){
                            [weakSelf doRecharge];
                        }
                        [MBProgressHUD showError:msg];
                    } fail:^{
                        
                    }];

                    
                    
                }else if (type == 1) {
                    [weakSelf doVIP];
                }
                
                [weakSelf removeAlertView];
                
            }];
            [self.view addSubview:alert];
        }

    }else{
        YBLookVideoVC *ybLook = [[YBLookVideoVC alloc]init];
        ybLook.pushPlayIndex = indexPath.item;
        ybLook.sourceBaseUrl  =minstr([_infoArray valueForKey:@"href"]);// baseUrl;
        ybLook.videoList = _infoArray;
        ybLook.pages =page;
        [[YBAppDelegate sharedAppDelegate] pushViewController:ybLook animated:YES];

    }
}
-(void)followUser:(NSNotification *)noti {
    NSDictionary *notiDidc = noti.userInfo;
    NSString *userId = minstr([notiDidc valueForKey:@"uid"]);
    NSString *isattent = minstr([notiDidc valueForKey:@"isattent"]);
    NSArray *originA = [NSArray arrayWithArray:_infoArray];
    BOOL needRefresh = NO;
    for (int i = 0; i<originA.count; i++) {
        NSDictionary *subDic = originA[i];
        NSString *subUid = minstr([subDic valueForKey:@"uid"]);
        if ([subUid isEqual:userId]) {
            NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:subDic];
            [m_dic setObject:isattent forKey:@"isattent"];
            NSDictionary *new_dic = [NSDictionary dictionaryWithDictionary:m_dic];
            [_infoArray replaceObjectAtIndex:i withObject:new_dic];
            needRefresh = YES;
        }
    }
    if (needRefresh) {
        [_collectionView reloadData];
    }
}

- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}

- (void)doVIP{
    VIPViewController *vip = [[VIPViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:vip animated:YES];
}
-(void)doRecharge{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[YBAppDelegate sharedAppDelegate] pushViewController:recharge animated:YES];

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeVideoListCell *cell = (HomeVideoListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.dataInfo = _infoArray[indexPath.item];
    return cell;
}


#pragma mark ================ 隐藏和显示tabbar ===============

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    oldOffset = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > oldOffset) {
        if (scrollView.contentOffset.y > 0) {
            _pageView.hidden = YES;
            [self hideTabBar];
        }
    }else{
        _pageView.hidden = NO;
        [self showTabBar];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%f",oldOffset);
}
- (void)hideTabBar {
    
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    self.tabBarController.tabBar.hidden = YES;
}
- (void)showTabBar

{
    if (self.tabBarController.tabBar.hidden == NO)
    {
        return;
    }
    self.tabBarController.tabBar.hidden = NO;
    
}

@end
