//
//  TXBaseBeautyView.m
//  YBVideo
//
//  Created by YB007 on 2019/12/13.
//  Copyright © 2019 cat. All rights reserved.
//

#import "TXBaseBeautyView.h"
#import "V8HorizontalPickerView.h"

@interface TXBaseBeautyView()<UIGestureRecognizerDelegate,V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource>

@property(nonatomic,copy)TXBeautyBlock beautyEvent;

@property(nonatomic,strong)UIView *toolBar;
@property(nonatomic,strong)UIButton *beautyBtn;
@property(nonatomic,strong)UIButton *filterBtn;

@property(nonatomic,strong)UIView *beautyPage;
@property(nonatomic,strong)UISlider *beautySlider;
@property(nonatomic,strong)UISlider *whiteSlider;

@property(nonatomic,strong)UIView *filterPage;
@property(nonatomic,strong)NSMutableArray *filterArray;
@property(nonatomic,strong)V8HorizontalPickerView *filterPicker;

@end

@implementation TXBaseBeautyView

+(void)saveBaseBeautyValue:(CGFloat)value {
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    [users setFloat:value forKey:@"tx_base_beauty"];
    [users synchronize];
}
+(CGFloat)getBaseBeautyValue {
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    CGFloat getValue = [users floatForKey:@"tx_base_beauty"];
    return getValue;
}

+(void)saveBaseWhiteValue:(CGFloat)value{
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    [users setFloat:value forKey:@"tx_base_white"];
    [users synchronize];
}
+(CGFloat)getBaseWhiteValue {
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    CGFloat getValue = [users floatForKey:@"tx_base_white"];
    return getValue;
}

+(void)saveFilterIndex:(NSInteger)value {
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    [users setInteger:value forKey:@"tx_base_filterindex"];
    [users synchronize];
}
+(NSInteger)getFilterIndex {
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    NSInteger getValue = [users integerForKey:@"tx_base_filterindex"];
    return getValue;
}


+(instancetype)showBaseBeauty:(TXBeautyBlock)complete {
    return [[self alloc]initBaseBeauty:complete];
}

- (instancetype)initBaseBeauty:(TXBeautyBlock)complete {
    self = [super init];
    if (self) {
        self.beautyEvent = complete;
        self.frame = [UIScreen mainScreen].bounds;
        [self filterArrayInit];
        [self createUI];
    }
    return self;
}
-(void)createUI {
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    ges.delegate = self;
    [self addGestureRecognizer:ges];
    
    [self addSubview:self.toolBar];
    [self addSubview:self.beautyPage];
    [_beautyPage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_toolBar.mas_top);
        make.width.centerX.mas_equalTo(_toolBar);
    }];
    [self addSubview:self.filterPage];
    [_filterPage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_toolBar.mas_top);
        make.width.centerX.equalTo(_toolBar);
        make.height.mas_equalTo(160);
    }];
    
    [self clickBeautyBtn];
}
-(void)dismiss {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
    if (self.beautyEvent) {
        self.beautyEvent(@"基础美颜-关闭", 0,@"");
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;{
    if ([touch.view isDescendantOfView:self.toolBar] ||
        [touch.view isDescendantOfView:self.beautyPage] ||
        [touch.view isDescendantOfView:self.filterPage]) {
        return NO;
    }
    return YES;
}

#pragma makr - 工具条
- (UIView *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-42-ShowDiff, _window_width, 42+ShowDiff)];
        _toolBar.backgroundColor = RGB_COLOR(@"#000000", 0.6);
        
        _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beautyBtn setTitle:YZMsg(@"美颜") forState:0];
        [_beautyBtn setTitleColor:GrayText forState:0];
        _beautyBtn.titleLabel.font = SYS_Font(13);
        [_beautyBtn setTitleColor:Pink_Cor forState:UIControlStateSelected];
        [_beautyBtn addTarget:self action:@selector(clickBeautyBtn) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_beautyBtn];
        [_beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_toolBar);
            make.height.mas_equalTo(42);
            make.centerX.equalTo(_toolBar.mas_centerX).multipliedBy(0.5);
            make.width.mas_equalTo(80);
        }];
        
        _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_filterBtn setTitle:YZMsg(@"滤镜") forState:0];
        [_filterBtn setTitleColor:GrayText forState:0];
        _filterBtn.titleLabel.font =  _beautyBtn.titleLabel.font;
        [_filterBtn setTitleColor:Pink_Cor forState:UIControlStateSelected];
        [_filterBtn addTarget:self action:@selector(clickFilterBtn) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_filterBtn];
        [_filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.equalTo(_beautyBtn);
            make.centerX.equalTo(_toolBar.mas_centerX).multipliedBy(1.5);
        }];
        
    }
    return _toolBar;
}

-(void)clickBeautyBtn {
    _filterBtn.selected = NO;
    _beautyBtn.selected = YES;
    _beautyPage.hidden = NO;
    _filterPage.hidden = YES;
}
-(void)clickFilterBtn {
    _filterBtn.selected = YES;
    _beautyBtn.selected = NO;
    _beautyPage.hidden = YES;
    _filterPage.hidden = NO;
    [_filterPicker scrollToElement:[TXBaseBeautyView getFilterIndex] animated:NO];
}
#pragma mark - 美颜
- (UIView *)beautyPage {
    if (!_beautyPage) {
        _beautyPage = [[UIView alloc]init];
        _beautyPage.backgroundColor = RGB_COLOR(@"#000000", 0.4);
        
        UILabel *beautyL = [[UILabel alloc]init];
        beautyL.textColor = [UIColor whiteColor];
        beautyL.font = SYS_Font(13);
        beautyL.text = YZMsg(@"美颜");
        [_beautyPage addSubview:beautyL];
        [beautyL mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([lagType isEqual:ZH_CN]) {
                make.width.mas_equalTo(40);
            }else{
                make.width.mas_equalTo(80);
            }
            make.height.mas_equalTo(20);
            make.left.equalTo(_beautyPage.mas_left).offset(5);
            make.top.equalTo(_beautyPage.mas_top).offset(20);
        }];
        _beautySlider = [[UISlider alloc]init];
        _beautySlider.minimumValue = 0;
        _beautySlider.maximumValue = 9;
        _beautySlider.value = [TXBaseBeautyView getBaseBeautyValue];
        [_beautySlider setThumbImage:[UIImage imageNamed:@"button_slider"] forState:UIControlStateNormal];
        [_beautySlider setMinimumTrackImage:[YBToolClass getImgWithColor:Pink_Cor] forState:UIControlStateNormal];
        [_beautySlider setMaximumTrackImage:[UIImage imageNamed:@"wire"] forState:UIControlStateNormal];
        [_beautySlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        _beautySlider.tag = 100;
        [_beautyPage addSubview:_beautySlider];
        [_beautySlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(beautyL.mas_right).offset(10);
            make.right.equalTo(_beautyPage.mas_right).offset(-10);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(beautyL);
        }];
        
        //
        UILabel *whiteL = [[UILabel alloc]init];
        whiteL.textColor = [UIColor whiteColor];
        whiteL.font = SYS_Font(13);
        whiteL.text = YZMsg(@"美白");
        [_beautyPage addSubview:whiteL];
        [whiteL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.left.equalTo(beautyL);
            make.top.equalTo(beautyL.mas_bottom).offset(20);
            make.bottom.equalTo(_beautyPage.mas_bottom).offset(-20);
        }];
        _whiteSlider = [[UISlider alloc]init];
        _whiteSlider.minimumValue = 0;
        _whiteSlider.maximumValue = 9;
        _whiteSlider.value = [TXBaseBeautyView getBaseWhiteValue];
        [_whiteSlider setThumbImage:[UIImage imageNamed:@"button_slider"] forState:UIControlStateNormal];
        [_whiteSlider setMinimumTrackImage:[YBToolClass getImgWithColor:Pink_Cor]  forState:UIControlStateNormal];
        [_whiteSlider setMaximumTrackImage:[UIImage imageNamed:@"wire"] forState:UIControlStateNormal];
        [_whiteSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        _whiteSlider.tag = 101;
        [_beautyPage addSubview:_whiteSlider];
        [_whiteSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.equalTo(_beautySlider);
            make.centerY.equalTo(whiteL);
        }];
        
    }
    return _beautyPage;
}
-(void)sliderValueChange:(UISlider *)slider {
    int ssTag = (int)slider.tag;
    NSString *eventStr = ssTag == 100?@"基础美颜-美颜":@"基础美颜-美白";
    if (ssTag == 100) {
        [TXBaseBeautyView saveBaseBeautyValue:slider.value];
    }else {
        [TXBaseBeautyView saveBaseWhiteValue:slider.value];
    }
    if (self.beautyEvent) {
        self.beautyEvent(eventStr, slider.value,@"");
    }
}
#pragma mark - 滤镜
- (UIView *)filterPage {
    if (!_filterPage) {
        _filterPage = [[UIView alloc]init];
        _filterPage.backgroundColor = RGB_COLOR(@"#000000", 0.4);
        
        _filterPicker = [[V8HorizontalPickerView alloc] init];
//        _filterPicker.frame = CGRectMake(0, 10, _window_width, 140);
        _filterPicker.textColor = [UIColor grayColor];
        _filterPicker.elementFont = [UIFont fontWithName:@"" size:14];
        _filterPicker.delegate = self;
        _filterPicker.dataSource = self;
        _filterPicker.selectedMaskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_selected"]];
        [_filterPage addSubview:_filterPicker];
        [_filterPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_filterPage.mas_height).offset(-20);
            make.width.centerX.centerY.equalTo(_filterPage);
        }];
        
    }
    return _filterPage;
}
#pragma mark - HorizontalPickerView DataSource
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    if(picker == _filterPicker) {
        return [_filterArray count];
    }
    return 0;
}

#pragma mark - HorizontalPickerView Delegate Methods
- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index {
    if(picker == _filterPicker) {
        V8LabelNode *v = [_filterArray objectAtIndex:index];
        return [[UIImageView alloc] initWithImage:v.face];
    }
    return nil;
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    
    return 90;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    
    if (picker == _filterPicker) {
        [TXBaseBeautyView saveFilterIndex:index];
        [self setFilter:(int)index];
    }
}
- (void)setFilter:(int)index {
    NSString* lookupFileName = @"";
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_white:
            lookupFileName = @"filter_white";
            break;
        case FilterType_langman:
            lookupFileName = @"filter_langman";
            break;
        case FilterType_qingxin:
            lookupFileName = @"filter_qingxin";
            break;
        case FilterType_weimei:
            lookupFileName = @"filter_weimei";
            break;
        case FilterType_fennen:
            lookupFileName = @"filter_fennen";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"filter_huaijiu";
            break;
        case FilterType_landiao:
            lookupFileName = @"filter_landiao";
            break;
        case FilterType_qingliang:
            lookupFileName = @"filter_qingliang";
            break;
        case FilterType_rixi:
            lookupFileName = @"filter_rixi";
            break;
        default:
            break;
    }
    
    NSString * path = [[NSBundle mainBundle] pathForResource:lookupFileName ofType:@"png"];
    if (path != nil && index != FilterType_None)    {
        if (self.beautyEvent) {
            self.beautyEvent(@"基础美颜-滤镜", -1,path);
        }
    }else    {
        if (self.beautyEvent) {
            self.beautyEvent(@"基础美颜-滤镜", -1,nil);
        }
    }
}
-(void)filterArrayInit {
    _filterArray = [NSMutableArray new];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"原图");
           v.face = [UIImage imageNamed:getImagename(@"orginal")];
           v;
       })];
       
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"美白");
           v.face = [UIImage imageNamed:getImagename(@"fwhite")];
           v;
       })];
       
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"浪漫");
           v.face = [UIImage imageNamed:getImagename(@"langman")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"清新");
           v.face = [UIImage imageNamed:getImagename(@"qingxin")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"唯美");
           v.face = [UIImage imageNamed:getImagename(@"weimei")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"粉嫩");
           v.face = [UIImage imageNamed:getImagename(@"fennen")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"怀旧");
           v.face = [UIImage imageNamed:getImagename(@"huaijiu")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"蓝调");
           v.face = [UIImage imageNamed:getImagename(@"landiao")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"清凉");
           v.face = [UIImage imageNamed:getImagename(@"qingliang")];
           v;
       })];
       [_filterArray addObject:({
           V8LabelNode *v = [V8LabelNode new];
           v.title = YZMsg(@"日系");
           v.face = [UIImage imageNamed:getImagename(@"rixi")];
           v;
       })];
}
@end
