//
//  classVC.m
//  YBLive
//
//  Created by Boom on 2018/9/22.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "classVC.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HotCollectionViewCell.h"

@interface classVC ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSDictionary *selectedDic;
    NSString *type_val;//
    NSString *livetype;//
    int page;
    UIView *collectionHeaderView;
    UIAlertController *md5AlertController;
    UIView *nothingView;

}
@property(nonatomic,strong)NSMutableArray *infoArray;//获取到的主播列表信息
@property(nonatomic,strong)UICollectionView *collectionView;

@end

@implementation classVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = _titleStr;
    
    _infoArray = [NSMutableArray array];
    page = 1;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/2-4.5, (_window_width/2-4.5) );
    flow.minimumLineSpacing = 3;
    flow.minimumInteritemSpacing = 3;
    flow.sectionInset = UIEdgeInsetsMake(3, 3,3, 3);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HotCollectionViewCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV"];
    
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
    [self pullInternet];

    nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 200, _window_width, 40)];
    nothingView.hidden = YES;
    nothingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nothingView];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 20)];
    label1.font = [UIFont systemFontOfSize:14];
    label1.text = YZMsg(@"暂时没有主播开播");
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = RGB_COLOR(@"#333333", 1);
    [nothingView addSubview:label1];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, _window_width, 20)];
    label2.font = [UIFont systemFontOfSize:13];
    label2.text = YZMsg(@"赶快去其他频道逛逛吧~");
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = RGB_COLOR(@"#969696", 1);
    [nothingView addSubview:label2];
    
}
- (void)pullInternet{
    [YBToolClass postNetworkWithUrl:@"Zlive.getClassLive" andParameter:@{@"p":@(page),@"liveclassid":_classID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];

        if (code == 0) {
            if (page == 1) {
                [_infoArray removeAllObjects];
            }
            [_infoArray addObjectsFromArray:info];
           
            [_collectionView reloadData];
            if ([info count] <= 0) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        if (_infoArray.count == 0) {
            nothingView.hidden = NO;
        }else{
            nothingView.hidden = YES;
        }
    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        nothingView.hidden = YES;
        [MBProgressHUD showError:YZMsg(@"网络请求失败")];
    }];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _infoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSDictionary *subDic = _infoArray[indexPath.row];
    [YBLiveUnitManager shareInstance].liveUid = minstr([subDic valueForKey:@"uid"]);
    [YBLiveUnitManager shareInstance].liveStream = minstr([subDic valueForKey:@"stream"]);
    [YBLiveUnitManager shareInstance].currentIndex = indexPath.row;
    [YBLiveUnitManager shareInstance].listArray = _infoArray;
    [[YBLiveUnitManager shareInstance] checkLiving];
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HotCollectionViewCell *cell = (HotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCollectionViewCELL" forIndexPath:indexPath];
    cell.dataDic = _infoArray[indexPath.row];
    
    return cell;
}




@end
