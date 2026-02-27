//
//  DisableLiveView.m
//  YBLive
//
//  Created by ybRRR on 2022/3/7.
//  Copyright © 2022 cat. All rights reserved.
//

#import "DisableLiveView.h"

@interface DisableLiveView ()<UIPickerViewDelegate,UIPickerViewDataSource>{
    UIPickerView *_timePick;
    NSArray *timeArr;
    NSInteger timeRow;
    NSString *selTimeStr;
}
@end

@implementation DisableLiveView

-(void)getLiveBanRules{
    [YBToolClass postNetworkWithUrl:@"Zlive.getLiveBanRules" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 0){
            timeArr = [NSArray arrayWithArray:info];
            [_timePick reloadAllComponents];
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(1, 1, 1, 0.4);
        timeArr = [NSArray array];

        [self createUI];
        [self getLiveBanRules];
    }
    return self;
}
-(void)createUI{
    UIView *backView = [[UIView alloc]init];
    backView.frame = CGRectMake(_window_width*0.2, 0, _window_width*0.6, _window_width*0.5);
    backView.center = self.center;
    backView.backgroundColor = UIColor.whiteColor;
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    [self addSubview:backView];
    
    UILabel *titleLb = [[UILabel alloc]init];
    titleLb.frame = CGRectMake(0, 10, backView.width, 20);
    titleLb.textColor = UIColor.blackColor;
    titleLb.font = [UIFont systemFontOfSize:14];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.text = YZMsg(@"请选择封禁时间");
    [backView addSubview:titleLb];
    
    UIButton *cancelBtn = [UIButton buttonWithType:0];
    cancelBtn.frame = CGRectMake(10, backView.height-45, backView.width/2-20, 34);
    [cancelBtn setTitle:YZMsg(@"取消") forState:0];
    [cancelBtn setTitleColor:UIColor.whiteColor forState:0];
    [cancelBtn setBackgroundColor:UIColor.lightGrayColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    cancelBtn.layer.cornerRadius = 17;
    cancelBtn.layer.masksToBounds = YES;
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:cancelBtn];
    
    UIButton *sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(backView.width/2+10, backView.height-45, backView.width/2-20, 34);
    [sureBtn setTitle:YZMsg(@"确定") forState:0];
    [sureBtn setTitleColor:UIColor.whiteColor forState:0];
    [sureBtn setBackgroundColor:normalColors];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    sureBtn.layer.cornerRadius = 17;
    sureBtn.layer.masksToBounds = YES;
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:sureBtn];

    _timePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, titleLb.bottom+10, backView.width, backView.height-titleLb.bottom-60)];
    _timePick.backgroundColor = [UIColor whiteColor];
    _timePick.delegate = self;
    _timePick.dataSource = self;
    _timePick.showsSelectionIndicator = YES;
    [_timePick selectRow: 0 inComponent: 0 animated: YES];
    [backView addSubview:_timePick];
}
-(void)sureBtnClick{
    if (self.btnEvent) {
        self.btnEvent(YZMsg(@"确定"),minstr([timeArr[timeRow] valueForKey:@"id"]));
    }
}
-(void)cancelBtnClick{
    if (self.btnEvent) {
        self.btnEvent(YZMsg(@"取消"),@"");
    }

}

#pragma mark--- Picker Data Source Methods-----
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return timeArr.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return minstr([timeArr[row] valueForKey:@"name"]);

}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selTimeStr = minstr([timeArr[row] valueForKey:@"name"]);
    timeRow = row;
    [_timePick reloadAllComponents];


}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    [[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
//    [[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        pickerLabel.font = [UIFont systemFontOfSize:15];
    }
    if (row == timeRow) {
        pickerLabel.backgroundColor = RGB_COLOR(@"#f0f0f0", 1);
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;

}





@end
