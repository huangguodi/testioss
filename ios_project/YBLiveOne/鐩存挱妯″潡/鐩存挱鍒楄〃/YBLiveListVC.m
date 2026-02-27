//
//  YBLiveListVC.m
//  YBLiveOne
//
//  Created by yunbao02 on 2023/9/12.
//  Copyright © 2023 iOS. All rights reserved.
//

#import "YBLiveListVC.h"
#import "SDCycleScrollView.h"
#import "HotCollectionViewCell.h"
#import "classVC.h"
#import "AllClassVC.h"
#import "YBPlayVC.h"

@interface YBLiveListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,SDCycleScrollViewDelegate>{
    CGFloat oldOffset;
    CGFloat _hotHeight;
    CGFloat _sliderHeight;
    CGFloat _classHeight;
    int _pageing;
    
    UIView *collectionHeaderView;
}

@property (nonatomic,strong)SDCycleScrollView *cycleScroll;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)NSArray *sliderArray;
@property(nonatomic,strong)NSArray *classArray;

@end

@implementation YBLiveListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageing = 1;
    _dataArray = [NSMutableArray array];
    _sliderArray = [NSArray array];
    _classArray = [NSArray array];
    
    [self createCollectionView];
    
    
}
- (void)createCollectionHeaderView{
    
    _sliderHeight = _window_width * 0.293;
    _classHeight = _window_width/5.5;
    _hotHeight = 50;
    if (collectionHeaderView) {
        [collectionHeaderView removeAllSubviews];
    }else{
        collectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _classHeight+_sliderHeight+_hotHeight)];

        collectionHeaderView.backgroundColor =RGB_COLOR(@"#ffffff", 1);
        collectionHeaderView.clipsToBounds = YES;
    }
    CGFloat bottomFloat = 0;
    if (_sliderArray.count > 0) {
        collectionHeaderView.height = _classHeight+_sliderHeight;
        _cycleScroll = [[SDCycleScrollView alloc]initWithFrame:CGRectMake(7, 0, _window_width-14, _sliderHeight)];
        _cycleScroll.delegate = self;
        _cycleScroll.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        _cycleScroll.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        [collectionHeaderView addSubview:_cycleScroll];
        _cycleScroll.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _cycleScroll.autoScrollTimeInterval = 3.0;//轮播时间间隔，默认1.0秒，可自定义
        _cycleScroll.currentPageDotColor = [UIColor whiteColor];
        _cycleScroll.pageDotColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        _cycleScroll.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _cycleScroll.layer.cornerRadius = 20;
        _cycleScroll.layer.masksToBounds = YES;
        NSMutableArray *sliderMuArr = [NSMutableArray array];
        for (NSDictionary *dic in _sliderArray) {
            [sliderMuArr addObject:minstr([dic valueForKey:@"image"])];
        }
        _cycleScroll.imageURLStringsGroup = sliderMuArr;
        bottomFloat = _cycleScroll.bottom;
    }
    
    NSInteger count;
    if (_classArray.count>6) {
        count = 5;
        UIButton *allButton = [UIButton buttonWithType:0];
        allButton.frame = CGRectMake(_window_width/6*5, bottomFloat+10, _window_width/6, _classHeight);
        allButton.tag = 10086;
        [allButton addTarget:self action:@selector(liveClassBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [collectionHeaderView addSubview:allButton];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(allButton.width*0.15, allButton.width*0.05, allButton.width*0.7, allButton.width*0.7)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [imgView setImage:[UIImage imageNamed:@"live_all"]];
        [allButton addSubview:imgView];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imgView.bottom, allButton.width, allButton.height - (imgView.bottom))];
        label.textColor = RGB_COLOR(@"#636363", 1);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        [label setText:YZMsg(@"全部")];
        [allButton addSubview:label];
    }else{
        count = _classArray.count;
    }
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:0];
        button.frame = CGRectMake(i*(_window_width/6), bottomFloat+10   , _window_width/6, _classHeight);
        button.tag = i + 20180922;
        [button addTarget:self action:@selector(liveClassBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [collectionHeaderView addSubview:button];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(button.width*0.15, button.width*0.05, button.width*0.7, button.width*0.7)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([_classArray[i] valueForKey:@"thumb"])] placeholderImage:[UIImage imageNamed:@"live_all"]];
        [button addSubview:imgView];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imgView.bottom, button.width, button.height-(imgView.bottom))];
        label.textColor = RGB_COLOR(@"#636363", 1);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        [label setText:minstr([_classArray[i] valueForKey:@"name"])];
        [button addSubview:label];

    }
    bottomFloat = _cycleScroll.bottom+_classHeight+10;

    if (_sliderArray.count > 0) {
        collectionHeaderView.height =_classHeight+_sliderHeight + _hotHeight+10;
    }else{
        collectionHeaderView.height =_classHeight + _hotHeight+10;
    }
    //标题
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, bottomFloat, _window_width, _hotHeight)];
    [collectionHeaderView addSubview:titleView];
    
    UIImageView *tImgIV = [[UIImageView alloc]init];
    tImgIV.image = [UIImage imageNamed:@"home_hot"];
    [titleView addSubview:tImgIV];
    [tImgIV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.centerY.equalTo(titleView.mas_centerY);
        make.left.equalTo(titleView.mas_left).offset(13);
    }];
    UILabel *titleL = [[UILabel alloc]init];
    titleL.font = [UIFont boldSystemFontOfSize:15];
    titleL.textColor = UIColor.blackColor;
    titleL.text = YZMsg(@"热门推荐");
    [titleView addSubview:titleL];
    [titleL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tImgIV.mas_right).offset(0);
        make.centerY.equalTo(titleView);
    }];
    
}

-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/2-4.5, (_window_width/2-4.5));
    flow.minimumLineSpacing = 3;
    flow.minimumInteritemSpacing = 3;
    flow.sectionInset = UIEdgeInsetsMake(3, 3,3, 3);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HotCollectionViewCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV"];
    self.collectionView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageing = 1;
        [self pullInternet];
    }];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _pageing ++;
        [self pullInternet];
    }];
    
    _collectionView.contentInset = UIEdgeInsetsMake(64+statusbarHeight, 0, 0, 0);
    _collectionView.mj_header.ignoredScrollViewContentInsetTop = 64+statusbarHeight;
    [self pullInternet];
    
}


//获取网络数据
-(void)pullInternet{
    [YBToolClass postNetworkWithUrl:@"Zlive.getLivelist" andParameter:@{@"p":@(_pageing)} success:^(int code,id info,NSString *msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSArray *listArray = [NSArray arrayWithArray:[infoDic valueForKey:@"list"]];
            if (_pageing == 1) {
                [_dataArray removeAllObjects];
                _sliderArray = [NSArray arrayWithArray:[infoDic valueForKey:@"slide"]];
                _classArray = [NSArray arrayWithArray:[infoDic valueForKey:@"liveclass"]];
                [self createCollectionHeaderView];
            }
            [_dataArray addObjectsFromArray:listArray];
            [_collectionView reloadData];
        }
    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
    }];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
 
    NSDictionary *subDic = _dataArray[indexPath.row];
    [YBLiveUnitManager shareInstance].liveUid = minstr([subDic valueForKey:@"uid"]);
    [YBLiveUnitManager shareInstance].liveStream = minstr([subDic valueForKey:@"stream"]);
    [YBLiveUnitManager shareInstance].currentIndex = indexPath.row;
    [YBLiveUnitManager shareInstance].listArray = _dataArray;
    [[YBLiveUnitManager shareInstance] checkLiving];
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HotCollectionViewCell *cell = (HotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCollectionViewCELL" forIndexPath:indexPath];
    cell.dataDic = _dataArray[indexPath.row];
    
    return cell;
}

#pragma mark ================ collectionview头视图 ===============
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV" forIndexPath:indexPath];
        
        header.backgroundColor = [UIColor whiteColor];
        [header addSubview:collectionHeaderView];
        return header;
    }else{
        return nil;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(_window_width, collectionHeaderView.height);
}

#pragma mark ================ 分类按钮点击事件 ===============
- (void)liveClassBtnClick:(UIButton *)sender{
    
    if (sender.tag == 10086) {
        AllClassVC *allClass = [[AllClassVC alloc]init];
        [[YBAppDelegate sharedAppDelegate]pushViewController:allClass animated:YES];
    }else{
        NSDictionary *dic = _classArray[sender.tag - 20180922];
        [self pushLiveClassVC:dic];
    }
}

- (void)pushLiveClassVC:(NSDictionary *)dic{
    classVC *class = [[classVC alloc]init];
    class.titleStr = minstr([dic valueForKey:@"name"]);
    class.classID = minstr([dic valueForKey:@"id"]);
    [[YBAppDelegate sharedAppDelegate] pushViewController:class animated:YES];
}

#pragma mark ============轮播图点击=============
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    
    NSString *uuuuuuu = minstr([_sliderArray[index] valueForKey:@"url"]);
    if ([YBToolClass isUrlString:uuuuuuu]) {
        YBWebViewController *web = [[YBWebViewController alloc]init];
        web.urls = uuuuuuu;
        [[YBAppDelegate sharedAppDelegate] pushViewController:web animated:YES];
    }
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
- (void)showTabBar{
    if (self.tabBarController.tabBar.hidden == NO){
        return;
    }
    self.tabBarController.tabBar.hidden = NO;
}

@end
