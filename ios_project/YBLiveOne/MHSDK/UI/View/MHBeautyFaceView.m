//
//  MHBeautyFaceView.m



#import "MHBeautyFaceView.h"
#import "MHBeautySlider.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"

@interface MHBeautyFaceView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, strong) MHBeautySlider *slider;
@property (nonatomic, assign) NSInteger beautyType;
@end
@implementation MHBeautyFaceView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        NSDictionary *indexDic = [[NSUserDefaults standardUserDefaults] objectForKey:kMHFaceTitle];
        if(IsDictionaryWithAnyKeyValue(indexDic)){
            NSNumber *index = indexDic.allValues.firstObject;
            if(index){
                self.lastIndex = index.integerValue;
            }else{
                self.lastIndex = -1;
            }
        }
    }
    return self;
}

- (void)configureFaceData:(NSMutableArray *)facesArr {
    self.array = facesArr;
    [self.collectionView reloadData];
}

- (void)clearAllFaceEffects {
    /****
     瘦鼻 嘴型 下巴 额头 长鼻 眉毛 眼角 开眼角 眼距 ，默认值50，其余为0
     ***/
    NSArray *arr = @[@"瘦鼻", @"嘴型",@"下巴",@"额头",@"长鼻", @"眉毛", @"眼角", @"开眼角",@"眼距"];
    for (int i = 0; i<self.array.count; i++) {
        MHBeautiesModel *model = self.array[i];
        NSString *faceKey = [NSString stringWithFormat:@"face_%ld",model.type];
        if([arr containsObject:model.beautyTitle]){
            [[NSUserDefaults standardUserDefaults] setInteger:50 forKey:faceKey];
        }else{
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:faceKey];
        }
        model.isSelected = i==0;
    }
    [self.collectionView reloadData];
}

- (void)cancelSelectedFaceType:(NSInteger)type {
    for (int i = 0; i<self.array.count; i++) {
        MHBeautiesModel *model = self.array[i];
        if (model.type == type) {
            model.isSelected = NO;
        }
    }
    self.lastIndex = -1;
    [self.collectionView reloadData];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHBeautyMenuCell" forIndexPath:indexPath];
    cell.beautyModel = self.array[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((window_width - 20 - 5*20)/4, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    currentModel.isSelected = YES;
   
    if(self.lastIndex > 0){
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    if (indexPath.row == 0) {
        [self clearAllFaceEffects];
    }else{
        MHBeautiesModel *firstModel = self.array[0];
        firstModel.isSelected = NO;
//        NSString *key = [NSString stringWithFormat:@"kFace_%@",firstModel.beautyTitle];
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
    }
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
    
    NSDictionary *indexDic = @{currentModel.beautyTitle:@(indexPath.row)};
    [[NSUserDefaults standardUserDefaults] setValue:indexDic forKey:kMHFaceTitle];
    NSString *faceKey = [NSString stringWithFormat:@"face_%ld",(long)currentModel.type];
    NSInteger currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:faceKey];
    if ([self.delegate respondsToSelector:@selector(handleFaceEffects:sliderValue:name:)]) {
        [self.delegate handleFaceEffects:currentModel.type sliderValue:currentValue name:currentModel.beautyTitle];
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(20, 20,20,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (NSInteger)currentIndex
{
    return _lastIndex;
}

@end
