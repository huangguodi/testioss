//
//  EditInfoViewController.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/12/1.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "EditInfoViewController.h"
#import "authPicCell.h"
#import "TZImagePickerController.h"
#import "authTextCell.h"
#import "authTextViewCell.h"
#import "authImpressCell.h"
#import <Qiniu/QiniuSDK.h>
#import "EditHeadCell.h"
#import "SoundRecordView.h"
#import "EditUserVoiceCell.h"
@interface EditInfoViewController ()<UITableViewDelegate,UITableViewDataSource,authPicCellDelegate,TZImagePickerControllerDelegate,authTextViewCellDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
{
    UITableView *editTable;
    NSArray *leftArray;
    NSArray *placeholdArray;
    NSMutableArray *singlePicArray;
    NSMutableArray *numPicArray;
    NSString *headerStr;
    NSString *thumbListStr;
    BOOL clickFirst;
    
    UITextField *nameT;
    NSString *nameStr;
    UITextField *phoneT;
    NSString *phoneStr;
    UITextField *sexT;
    NSString *sexStr;
    UITextField *heightT;
    NSString *heightStr;
    UITextField *boadT;
    NSString *boadStr;
    UITextField *starT;
    NSString *starStr;
    UITextField *improssT;
    NSString *improssStr;
    UITextField *cityT;
    NSString *cityStr;

    UITextView *introduceTextV;
    NSString *introduceStr;
    UITextView *autographTextV;
    NSString *autographStr;
    
    
    UIView *cityPickBack;
    UIPickerView *cityPicker;
    //省市区-数组
    NSArray *province;
    NSArray *city;
    NSArray *district;
    
    //省市区-字符串
    NSString *provinceStr;
    NSString *cityStrrrrrrr;
    NSString *districtStr;
    
    NSDictionary *areaDic;
    NSString *selectedProvince;

    UIView *starBackView;
    UIPickerView *starPicker;
    NSArray *starArray;
    NSMutableArray *starShowArray;
    
    UIView *impressBackView;
    NSArray *impressArray;
    UICollectionView *impressColloctionView;
    NSMutableArray *selectImpressA;
    NSArray *sureImpressA;
    authTextCell *impressCell;
    
    NSMutableArray *oldThumbArray;
    NSMutableArray *oldPhotosArray;
    NSMutableArray *oldImpressArray;

    UIImage *headerImg;
    
    BOOL islisten;
    BOOL voiceEnd;
    int oldVoiceTime;
    NSTimer *voicetimer;
    BOOL isRecordVoice;

}
@property(nonatomic,strong)SoundRecordView *soundView;
@property(nonatomic,strong)NSDictionary *userInfoDic;
@property(nonatomic,strong)NSString *audioPath;//音频路径
@property(nonatomic,strong)NSString *audioUrlStr;//音频路径

@property(nonatomic,assign)int voicetime;//音频时长
@property (nonatomic,strong) AVPlayer *voicePlayer;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

@end

@implementation EditInfoViewController
//获取个人信息
-(void)getUserMaterial
{
    [YBToolClass postNetworkWithUrl:@"User.getUserMaterial" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSLog(@"sssss---:%@",info);
                NSDictionary *infos = [info firstObject];
                _userInfoDic = infos;
                provinceStr = minstr([_userInfoDic valueForKey:@"province"]);
                cityStrrrrrrr = minstr([_userInfoDic valueForKey:@"city"]);
                districtStr = minstr([_userInfoDic valueForKey:@"district"]);
                _audioUrlStr = minstr([_userInfoDic valueForKey:@"audio"]);
                _voicetime = [minstr([_userInfoDic valueForKey:@"audio_length"]) intValue];
                [editTable reloadData];
            }
        } fail:^{
            
        }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self playFinished:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = YZMsg(@"编辑资料");
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:YZMsg(@"保存") forState:0];
    [self.rightBtn setTitleColor:normalColors forState:0];

    [self getUserMaterial];
    leftArray = @[YZMsg(@"头像"),YZMsg(@"昵称"),YZMsg(@"语音"),YZMsg(@"性别"),YZMsg(@"身高"),YZMsg(@"体重"),YZMsg(@"星座"),YZMsg(@"形象标签"),YZMsg(@"所在城市"),YZMsg(@"个人介绍"),YZMsg(@"个性签名")];
    placeholdArray = @[@"",YZMsg(@"请输入昵称"),YZMsg(@"请录制语音"),YZMsg(@"请选择性别"),YZMsg(@"请输入身高cm"),YZMsg(@"请输入体重kg"),YZMsg(@"请选择星座"),YZMsg(@"请选择形象标签"),YZMsg(@"请选择所在城市"),YZMsg(@"请编辑个人介绍"),YZMsg(@"请编辑个性签名")];

    singlePicArray = [NSMutableArray array];
    numPicArray = [NSMutableArray array];
    selectImpressA = [NSMutableArray array];
    _userInfoDic = [NSDictionary dictionary];
    voiceEnd = YES;
    isRecordVoice = NO;
    heightStr = @"";
    improssStr = @"";
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"area" ofType:@"plist"];
    areaDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *components = [areaDic allKeys];
    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray *provinceTmp = [[NSMutableArray alloc] init];
    for (int i=0; i<[sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[areaDic objectForKey: index] allKeys];
        [provinceTmp addObject: [tmp objectAtIndex:0]];
    }
    //---> //rk_3-7 修复首次加载问题
    province = [[NSArray alloc] initWithArray: provinceTmp];
    NSString *index = [sortedArray objectAtIndex:0];
    //NSString *selected = [province objectAtIndex:0];
    selectedProvince = [province objectAtIndex:0];
    NSDictionary *proviceDic = [NSDictionary dictionaryWithDictionary: [[areaDic objectForKey:index]objectForKey:selectedProvince]];
    
    NSArray *cityArray = [proviceDic allKeys];
    NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [proviceDic objectForKey: [cityArray objectAtIndex:0]]];
    //city = [[NSArray alloc] initWithArray: [cityDic allKeys]];
    
    NSArray *citySortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;//递减
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;//上升
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *m_array = [[NSMutableArray alloc] init];
    for (int i=0; i<[citySortedArray count]; i++) {
        NSString *index = [citySortedArray objectAtIndex:i];
        NSArray *temp = [[proviceDic objectForKey: index] allKeys];
        [m_array addObject: [temp objectAtIndex:0]];
    }
    city = [NSArray arrayWithArray:m_array];
    NSString *selectedCity = [city objectAtIndex: 0];
    district = [[NSArray alloc] initWithArray: [cityDic objectForKey: selectedCity]];

    /*
    starArray = @[YZMsg(@"白羊座"),YZMsg(@"金牛座"),YZMsg(@"双子座"),YZMsg(@"巨蟹座"),YZMsg(@"狮子座"),YZMsg(@"处女座"),YZMsg(@"天秤座"),YZMsg(@"天蝎座"),YZMsg(@"射手座"),YZMsg(@"摩羯座"),YZMsg(@"水瓶座"),YZMsg(@"双鱼座")];
    starShowArray = [NSMutableArray array];
    NSArray *dateAray = @[@"(3.21-4.19)",@"(4.20-5.20)",@"(5.21-6.21)",@"(6.22-7.22)",@"(7.23-8.22)",@"(8.23-9.22)",@"(9.23-10.23)",@"(10.24-11.22)",@"(11.23-12.21)",@"(12.22-1.19)",@"(1.20-2.18)",@"(2.19-3.20)"];
    for (int i = 0; i < starArray.count; i ++) {
        NSString *strS = [NSString stringWithFormat:@"%@%@",starArray[i],dateAray[i]];
        [starShowArray addObject:strS];
    }
    */
    starArray = [YBToolClass getStarArray];
    
    [self creatUI];

}

- (void)creatUI{
    editTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:0];
    editTable.delegate = self;
    editTable.dataSource = self;
    editTable.separatorStyle = 0;
    [self.view addSubview:editTable];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return leftArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf;
    if (indexPath.row == 0) {
        EditHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"editHeadCell%ld",indexPath.row]];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"EditHeadCell" owner:nil options:nil] lastObject];
        }
        cell.titleLb.text = leftArray[indexPath.row];
        
        if ([Config getavatar]) {
            [cell.headImg sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]]];
        }else{
            cell.headImg.image =[UIImage imageNamed:@"edit_默认头像"];
        }

        return cell;

    }else if (indexPath.row == 2){
        EditUserVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"editUserVoiceCell%ld",indexPath.row]];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"EditUserVoiceCell" owner:nil options:nil] lastObject];
        }
        if (_audioUrlStr.length > 0) {
            cell.audioImg.hidden = NO;
            cell.voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
        }

        cell.voiceEvent = ^{
            [weakSelf audioImgClick];
        };
        return cell;

    }else {
        if (indexPath.row < 9) {
            authTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"authTextCell_%ld",indexPath.row]];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"authTextCell" owner:nil options:nil] lastObject];
            }
            cell.titleL.text = leftArray[indexPath.row];
            cell.textT.placeholder = placeholdArray[indexPath.row];
            [cell.textT addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
            switch (indexPath.row) {
                case 1:
                    nameStr = minstr([_userInfoDic valueForKey:@"user_nickname"]);
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = nameStr;
                    nameT = cell.textT;
                    break;
                case 3:
                    sexStr =minstr([_userInfoDic valueForKey:@"sex"]);
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    if (sexStr) {
                        if ([sexStr isEqual:@"1"]) {
                            cell.textT.text = YZMsg(@"男");
                        }else{
                            cell.textT.text = YZMsg(@"女");
                        }
                    }else{
                        cell.textT.text = sexStr;
                    }
                    sexT = cell.textT;
                    break;
                case 4:
                    heightStr =minstr([_userInfoDic valueForKey:@"height"]);
                    cell.rightImgV.hidden = YES;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeNumberPad;
                    cell.textT.text = heightStr;
                    heightT = cell.textT;
                    if (heightStr.length > 0 && ![YBToolClass checkNull:headerStr]) {
                        cell.lllllll.text = @"cm";
                    }else{
                        cell.lllllll.text = @"";
                    }
                    break;
                case 5:
                    boadStr =minstr([_userInfoDic valueForKey:@"weight"]);

                    cell.rightImgV.hidden = YES;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeNumberPad;
                    cell.textT.text = boadStr;
                    boadT = cell.textT;
                    if (boadStr.length > 0) {
                        cell.lllllll.text = @"kg";
                    }else{
                        cell.lllllll.text = @"";
                    }
                    break;
                case 6:
                    starStr = minstr([_userInfoDic valueForKey:@"constellation"]);
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    
                    cell.textT.text = starStr;
                    //rk_fy
                    //cell.textT.text = [YBToolClass getStartWithId:starStr];
                    
                    starT = cell.textT;
                    break;
                case 7:
                    sureImpressA =[_userInfoDic valueForKey:@"label_list"];
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = improssStr;
                    improssT = cell.textT;

                    if (sureImpressA.count > 0) {
                        cell.textT.hidden = YES;
                        [self creatSelectImpressView:cell];
                    }else{
                        cell.textT.hidden = NO;
                    }
                    break;
                case 8:{
                    NSString *dizhi = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStrrrrrrr,districtStr];
                    cityStr = dizhi;
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = cityStr;
                    cityT = cell.textT;
                }
                    break;
                    
                default:
                    break;
            }
            return cell;

        }else{
            introduceStr =minstr([_userInfoDic valueForKey:@"intr"]);
            authTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"authTextViewCell_%ld",indexPath.row]];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"authTextViewCell" owner:nil options:nil] lastObject];
                cell.placeholdLabel.text = YZMsg(@"请编辑个人介绍(必填)");
            }
            cell.delegate = self;
            cell.titleL.text = leftArray[indexPath.row];
            cell.placeholdLabel.text = placeholdArray[indexPath.row];
            if (indexPath.row == 9) {
                cell.isAutograph = NO;
                if (introduceStr.length > 0) {
                    cell.placeholdLabel.hidden = YES;
                }else{
                    cell.placeholdLabel.hidden = NO;
                }
                cell.textV.text = introduceStr;
                introduceTextV = cell.textV;
                cell.wordNumL.text  = [NSString stringWithFormat:@"%ld/40",introduceStr.length];
            }else{
                autographStr =minstr([_userInfoDic valueForKey:@"signature"]);

                cell.isAutograph = YES;
                if (autographStr.length > 0) {
                    cell.placeholdLabel.hidden = YES;
                }else{
                    cell.placeholdLabel.hidden = NO;
                }
                cell.textV.text = autographStr;
                autographTextV = cell.textV;
                cell.wordNumL.text  = [NSString stringWithFormat:@"%ld/40",autographStr.length];

            }
            return cell;

        }

    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 80;
    }else{
        if (indexPath.row < 9) {
            return 45;
        }else
        {
            return 120;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self didSelectPicBtn:YES];
    }else if (indexPath.row == 2){
        [self playFinished:nil];
        [self showAudioView];
    } else if (indexPath.row == 3) {
        //性别
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"请选择性别") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *manAction = [UIAlertAction actionWithTitle:YZMsg(@"男") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sexT.text = YZMsg(@"男");
            sexStr = @"1";
            [self changeRightBtnState];
        }];
        [alertContro addAction:manAction];
        [manAction setValue:color32 forKey:@"_titleTextColor"];

        UIAlertAction *womanAction = [UIAlertAction actionWithTitle:YZMsg(@"女") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sexT.text = YZMsg(@"女");
            sexStr = @"2";
            [self changeRightBtnState];
        }];
        [alertContro addAction:womanAction];
        [womanAction setValue:color32 forKey:@"_titleTextColor"];

        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertContro addAction:sureAction];
        [sureAction setValue:color96 forKey:@"_titleTextColor"];

        [self presentViewController:alertContro animated:YES completion:nil];

    }else if (indexPath.row == 6) {
        //星座
        [self selectStarType];
    }else if (indexPath.row == 7) {
        //印象
        [self showAllImpressView];
    }else if (indexPath.row == 8) {
        //城市
        [self selectCityType];
    }

}
#pragma mark ============图片选择=============
- (void)didSelectPicBtn:(BOOL)isSingle{
    TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imagePC.preferredLanguage = [lagType isEqual:ZH_CN] ? @"zh-Hans":@"en";
    imagePC.allowCameraLocation = YES;
    imagePC.allowTakeVideo = NO;
    imagePC.allowPickingVideo = NO;
    imagePC.showSelectBtn = NO;
    imagePC.allowCrop = YES;
    imagePC.allowPickingOriginalPhoto = NO;
    imagePC.cropRect = CGRectMake(0, (_window_height-_window_width)/2, _window_width, _window_width);
    imagePC.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:imagePC animated:YES completion:nil];
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    headerImg = photos[0];
    EditHeadCell *cell =(EditHeadCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.headImg.image = headerImg;
}

- (void)removeImage:(NSIndexPath *)index andSingle:(BOOL)isSingle{
}
#pragma mark =========录音==========
-(void)showAudioView{
    WeakSelf;
    if (_soundView) {
        [_soundView removeFromSuperview];
        _soundView = nil;
    }
    _soundView = [[SoundRecordView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)andMaxTime:15];
    _soundView.backgroundColor = RGBA(29, 29, 29, 0.3);
    _soundView.hideBlock = ^{
        [weakSelf.soundView removeFromSuperview];
        weakSelf.soundView =nil;
    };
    _soundView.recordEvent = ^(NSString * _Nonnull audioPath, int voiceTime) {
        weakSelf.audioPath = audioPath;
        weakSelf.voicetime = voiceTime;
        oldVoiceTime = voiceTime;
        [weakSelf.soundView removeFromSuperview];
        weakSelf.soundView =nil;
        [weakSelf showVoiceBtn];
        isRecordVoice = YES;


    };
    [self.view addSubview:_soundView];
}
//展示录音
-(void)showVoiceBtn{
    EditUserVoiceCell *cell =(EditUserVoiceCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell.audioImg.hidden = NO;
    cell.voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
}
#pragma mark ============输入框=============
- (void)textChange:(UITextField *)textfield{
    if (textfield == nameT) {
        nameStr = textfield.text;
        nameStr = [nameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (textfield == phoneT) {
        if (textfield.text.length > 11) {
            textfield.text = [textfield.text substringToIndex:11];
        }

        phoneStr = textfield.text;
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (textfield == heightT) {
        heightStr = textfield.text;
        heightStr = [heightStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        authTextCell *cell = (authTextCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        if (heightStr.length > 0) {
            cell.lllllll.text = @"cm";
        }else{
            cell.lllllll.text = @"";
        }
    }
    if (textfield == boadT) {
        boadStr = textfield.text;
        boadStr = [boadStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        authTextCell *cell = (authTextCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        if (boadStr.length > 0) {
            cell.lllllll.text = @"kg";
        }else{
            cell.lllllll.text = @"";
        }
    }
    [self changeRightBtnState];
}
- (void)changeStr:(NSString *)str andIsAutograph:(BOOL)isAutograph{
    if (isAutograph) {
        autographStr = str;
    }else{
        introduceStr = str;
    }
    [self changeRightBtnState];
}
- (void)changeRightBtnState{
//    if (singlePicArray.count > 0 && numPicArray.count > 0 && nameStr.length > 0 && phoneStr.length > 0&& sexStr.length > 0&& cityStr.length > 0&& heightStr.length > 0&& boadStr.length > 0&& sexStr.length > 0&& starStr.length > 0 && introduceStr.length > 0 && autographStr.length > 0) {
//        self.rightBtn.userInteractionEnabled = YES;
//        [self.rightBtn setTitleColor:normalColors forState:0];
//    }else{
//        self.rightBtn.userInteractionEnabled = NO;
//        [self.rightBtn setTitleColor:[normalColors colorWithAlphaComponent:0.3] forState:0];
//
//    }
}
#pragma mark ============pickview=============
- (void)selectCityType{
    if (!cityPickBack) {
        cityPickBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        cityPickBack.backgroundColor = RGB_COLOR(@"#000000", 0.3);
        [self.view addSubview:cityPickBack];
        UITapGestureRecognizer *taps = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePicker)];
        taps.delegate = self;
        [cityPickBack addGestureRecognizer:taps];

        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-240, _window_width, 40)];
        titleView.backgroundColor = RGB_COLOR(@"#ececec", 1);
        [cityPickBack addSubview:titleView];
        UILabel *pickTitleL = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-50, 0, 100, 40)];
        pickTitleL.textAlignment = NSTextAlignmentCenter;
//        pickTitleL.text = @"选择地区";
        pickTitleL.font = [UIFont systemFontOfSize:13];
        [titleView addSubview:pickTitleL];
        
        UIButton *cancleBtn = [UIButton buttonWithType:0];
        cancleBtn.frame = CGRectMake(0, 0, 60, 40);
        cancleBtn.tag = 100;
        [cancleBtn setTitle:YZMsg(@"取消") forState:0];
        [cancleBtn setTitleColor:color96 forState:0];
        cancleBtn.titleLabel.font = SYS_Font(13);
        [cancleBtn addTarget:self action:@selector(cityCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancleBtn];
        UIButton *sureBtn = [UIButton buttonWithType:0];
        sureBtn.frame = CGRectMake(_window_width-60, 0, 60, 40);
        sureBtn.tag = 101;
        [sureBtn setTitle:YZMsg(@"确定") forState:0];
        sureBtn.titleLabel.font = SYS_Font(13);
        [sureBtn setTitleColor:normalColors forState:0];
        [sureBtn addTarget:self action:@selector(cityCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:sureBtn];
        
        cityPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, _window_height-200, _window_width, 200)];
        cityPicker.backgroundColor = [UIColor whiteColor];
        cityPicker.delegate = self;
        cityPicker.dataSource = self;
        cityPicker.showsSelectionIndicator = YES;
        [cityPicker selectRow: 0 inComponent: 0 animated: YES];
        [cityPickBack addSubview:cityPicker];
    }else{
        cityPickBack.hidden = NO;
    }
    
}
- (void)cityCancleOrSure:(UIButton *)button{
    if (button.tag == 100) {
        //return;
    }else{
        NSInteger provinceIndex = [cityPicker selectedRowInComponent: 0];
        NSInteger cityIndex = [cityPicker selectedRowInComponent: 1];
        NSInteger districtIndex = [cityPicker selectedRowInComponent: 2];
        
        provinceStr = [province objectAtIndex: provinceIndex];
        cityStrrrrrrr = [city objectAtIndex: cityIndex];
        districtStr = [district objectAtIndex:districtIndex];
        NSString *dizhi = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStrrrrrrr,districtStr];
        cityT.text = dizhi;
        cityStr = dizhi;
    }
    cityPickBack.hidden = YES;
    
}

- (void)selectStarType{
    if (!starBackView) {
        starBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        starBackView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
        [self.view addSubview:starBackView];
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-190, _window_width, 40)];
        titleView.backgroundColor = RGB_COLOR(@"#ececec", 1);
        [starBackView addSubview:titleView];
        
        UIButton *cancleBtn = [UIButton buttonWithType:0];
        cancleBtn.frame = CGRectMake(0, 0, 60, 40);
        cancleBtn.tag = 200;
        [cancleBtn setTitle:YZMsg(@"取消") forState:0];
        [cancleBtn setTitleColor:color96 forState:0];
        cancleBtn.titleLabel.font = SYS_Font(13);
        [cancleBtn addTarget:self action:@selector(starCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancleBtn];
        UIButton *sureBtn = [UIButton buttonWithType:0];
        sureBtn.frame = CGRectMake(_window_width-60, 0, 60, 40);
        sureBtn.tag = 201;
        [sureBtn setTitle:YZMsg(@"确定") forState:0];
        sureBtn.titleLabel.font = SYS_Font(13);
        [sureBtn setTitleColor:normalColors forState:0];
        [sureBtn addTarget:self action:@selector(starCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:sureBtn];
        
        starPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, _window_height-150, _window_width, 150)];
        starPicker.backgroundColor = [UIColor whiteColor];
        starPicker.delegate = self;
        starPicker.dataSource = self;
        starPicker.showsSelectionIndicator = YES;
        [starPicker selectRow: 0 inComponent: 0 animated: YES];
        [starBackView addSubview:starPicker];
    }else{
        starBackView.hidden = NO;
    }
    
}
- (void)starCancleOrSure:(UIButton *)button{
    if (button.tag == 200) {
        //return;
    }else{
        NSInteger index = [starPicker selectedRowInComponent: 0];
        //starStr = [starArray objectAtIndex: index];
        NSDictionary *subs = starArray[index];
        NSString *title = minstr([subs valueForKey:@"name"]);
        NSString *title_en = minstr([subs valueForKey:@"name_en"]);
        
        starStr = title;
        //rk_fy
        //starStr = minstr([subs valueForKey:@"id"]);
        
        if ([lagType isEqual:ZH_CN]) {
            starT.text = title;
        }else{
            starT.text = title_en;
        }
    }
    starBackView.hidden = YES;
    
}
-(void)hidePicker{
    cityPickBack.hidden = YES;
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if ([NSStringFromClass([touch.view class]) isEqual:@"UIView"]) {
//        return NO;
//    }
//    return YES;
//}
#pragma mark- Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == cityPicker) {

        return 3;
    }else{
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == cityPicker) {

        if (component == 0) {
            return [province count];
        }
        else if (component == 1) {
            return [city count];
        }
        else {
            return [district count];
        }
    }else{
        return [starArray count];
    }
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == cityPicker) {
        if (component == 0) {
            return [province objectAtIndex: row];
        }
        else if (component == 1) {
            return [city objectAtIndex: row];
        }
        else {
            return [district objectAtIndex: row];
        }
    }else{
        //return [starShowArray objectAtIndex: row];
        NSDictionary *subs = starArray[row];
        NSString *titleS = minstr([subs valueForKey:@"name"]);
        if (![lagType isEqual:ZH_CN]) {
            titleS = minstr([subs valueForKey:@"name_en"]);
        }
        NSString *showStr = [NSString stringWithFormat:@"%@%@",titleS,[subs valueForKey:@"time"]];
        return showStr;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == cityPicker) {

        if (component == 0) {
            selectedProvince = [province objectAtIndex: row];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [areaDic objectForKey: [NSString stringWithFormat:@"%ld", row]]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
            NSArray *cityArray = [dic allKeys];
            NSArray *sortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;//递减
                }
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;//上升
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i=0; i<[sortedArray count]; i++) {
                NSString *index = [sortedArray objectAtIndex:i];
                NSArray *temp = [[dic objectForKey: index] allKeys];
                [array addObject: [temp objectAtIndex:0]];
            }
            
            city = [[NSArray alloc] initWithArray: array];
            
            NSDictionary *cityDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
            district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [city objectAtIndex: 0]]];
            [cityPicker selectRow: 0 inComponent: 1 animated: YES];
            [cityPicker selectRow: 0 inComponent: 2 animated: YES];
            [cityPicker reloadComponent: 1];
            [cityPicker reloadComponent: 2];
            
        } else if (component == 1) {
            NSString *provinceIndex = [NSString stringWithFormat: @"%ld", [province indexOfObject: selectedProvince]];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [areaDic objectForKey: provinceIndex]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
            NSArray *dicKeyArray = [dic allKeys];
            NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: row]]];
            NSArray *cityKeyArray = [cityDic allKeys];
            
            district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [cityKeyArray objectAtIndex:0]]];
            [cityPicker selectRow: 0 inComponent: 2 animated: YES];
            [cityPicker reloadComponent: 2];
        }
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (pickerView == cityPicker) {

        if (component == 0) {
            return 80;
        }
        else if (component == 1) {
            return 100;
        }
        else {
            return 115;
        }
    }else{
        return _window_width;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    if (pickerView == cityPicker) {

        if (component == 0) {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width/3, 30)];
            myView.textAlignment = NSTextAlignmentCenter;
            myView.text = [province objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:14];
            myView.backgroundColor = [UIColor clearColor];
        }
        else if (component == 1) {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width/3, 30)];
            myView.textAlignment = NSTextAlignmentCenter;
            myView.text = [city objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:14];
            myView.backgroundColor = [UIColor clearColor];
        }
        else {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width/3, 30)];
            myView.textAlignment = NSTextAlignmentCenter;
            myView.text = [district objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:14];
            myView.backgroundColor = [UIColor clearColor];
        }
    }else{
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        //myView.text = [starShowArray objectAtIndex:row];
        NSDictionary *subs = starArray[row];
        NSString *titleS = minstr([subs valueForKey:@"name"]);
        if (![lagType isEqual:ZH_CN]) {
            titleS = minstr([subs valueForKey:@"name_en"]);
        }
        myView.text = [NSString stringWithFormat:@"%@%@",titleS,[subs valueForKey:@"time"]];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];

    }
    return myView;
}
#pragma mark ============印象=============
- (void)showAllImpressView{
    if (impressArray.count > 0) {
        impressBackView.hidden = NO;
    }else{
        [YBToolClass postNetworkWithUrl:@"User.getLabelList" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                impressArray = info;
                [self creatImpressBackView];

            }
        } fail:^{

        }];
    }
}
- (void)creatImpressBackView{
    impressBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    impressBackView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    [self.view addSubview:impressBackView];
    NSInteger count = 0;
    if (impressArray.count%3 == 0) {
        count = impressArray.count/3;
    }else{
        count = impressArray.count/3+1;
    }
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-70-ShowDiff-32*count, _window_width, 30)];
    titleView.backgroundColor = RGB_COLOR(@"#ececec", 1);
    [impressBackView addSubview:titleView];
    
    UIButton *cancleBtn = [UIButton buttonWithType:0];
    cancleBtn.frame = CGRectMake(0, 0, 60, 30);
    cancleBtn.tag = 300;
    [cancleBtn setTitle:YZMsg(@"取消") forState:0];
    [cancleBtn setTitleColor:color96 forState:0];
    cancleBtn.titleLabel.font = SYS_Font(13);
    [cancleBtn addTarget:self action:@selector(impressCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:cancleBtn];
    UIButton *sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(_window_width-60, 0, 60, 30);
    sureBtn.tag = 301;
    [sureBtn setTitle:YZMsg(@"确定") forState:0];
    sureBtn.titleLabel.font = SYS_Font(13);
    [sureBtn setTitleColor:normalColors forState:0];
    [sureBtn addTarget:self action:@selector(impressCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:sureBtn];
    
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, titleView.bottom, _window_width, _window_height-titleView.bottom)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [impressBackView addSubview:whiteView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    label.text = YZMsg(@"请选择形象标签，最多可选择三个");
    label.textColor = color96;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = SYS_Font(11);
    [whiteView addSubview:label];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(70, 22);
    flow.minimumLineSpacing = 10;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(5, 10,5, 10);
    
    impressColloctionView = [[UICollectionView alloc]initWithFrame:CGRectMake((_window_width-270)/2,40, 270, whiteView.height-40) collectionViewLayout:flow];
    impressColloctionView.delegate   = self;
    impressColloctionView.dataSource = self;
    impressColloctionView.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:impressColloctionView];
    [impressColloctionView registerNib:[UINib nibWithNibName:@"authImpressCell" bundle:nil] forCellWithReuseIdentifier:@"authImpressCELL"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return impressArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = impressArray[indexPath.row];
//    NSString *str = minstr([dic valueForKey:@"id"]);
    if ([selectImpressA containsObject:dic]) {
        [selectImpressA removeObject:dic];
    }else{
        if (selectImpressA.count == 3) {
            [MBProgressHUD showError:YZMsg(@"最多选择三项")];
            return;
        }
        [selectImpressA addObject:dic];
    }
    [impressColloctionView reloadData];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    authImpressCell *cell = (authImpressCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"authImpressCELL" forIndexPath:indexPath];
    NSDictionary *dic = impressArray[indexPath.row];

//    NSString *str = minstr([dic valueForKey:@"id"]);
    BOOL isCons = NO;
    for (NSDictionary *ssss in selectImpressA) {
        if ([dic isEqual:ssss]) {
            isCons = YES;
        }
    }
    cell.titleL.text = minstr([dic valueForKey:@"name"]);
    if ([lagType isEqual:EN]) {
        cell.titleL.text = minstr([dic valueForKey:@"name_en"]);
    }
    UIColor *color= RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
    cell.titleL.layer.borderColor = color.CGColor;
    if (isCons) {
        cell.titleL.backgroundColor = color;
        cell.titleL.textColor = [UIColor whiteColor];
    }else{
        cell.titleL.textColor = color;
        cell.titleL.backgroundColor = [UIColor clearColor];
    }

    return cell;
}
- (void)impressCancleOrSure:(UIButton *)button{
    if (button.tag == 300) {
        if (sureImpressA.count > 0) {
            selectImpressA = [sureImpressA mutableCopy];
        }
        //return;
    }else{
        if (oldImpressArray.count > 0) {
            [oldImpressArray removeAllObjects];
            sureImpressA = @[];
        }
        sureImpressA = selectImpressA;
        [self creatSelectImpressView:nil];
    }
    impressBackView.hidden = YES;
    
}
- (void)creatSelectImpressView:(authTextCell *)cell{
    if (!cell) {
        cell = (authTextCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
    }
    
    if (cell) {
        cell.rightImgV.hidden = NO;
        if (sureImpressA.count > 0) {
            cell.textT.hidden = YES;
        }else{
            cell.textT.hidden = NO;
            cell.textT.text = @"";
        }
        [cell.editView removeAllSubviews];
        improssStr = @"";
        CGFloat speace = 0.00;
        for (int i = 0; i < sureImpressA.count; i++) {
            NSDictionary *dic = sureImpressA[i];
            UIColor *color = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);;
            NSString *showStr = minstr([dic valueForKey:@"name"]);
            if ([lagType isEqual:EN]) {
                showStr = minstr([dic valueForKey:@"name_en"]);
            }
            CGFloat width = [[YBToolClass sharedInstance] widthOfString:showStr andFont:SYS_Font(11) andHeight:22] + 20;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((_window_width-100)-width-speace, 11.5, width, 22)];
            label.textColor = [UIColor whiteColor];
            label.layer.cornerRadius = 11;
            label.layer.masksToBounds = YES;
            label.text = minstr([dic valueForKey:@"name"]);
            if ([lagType isEqual:EN]) {
                label.text = minstr([dic valueForKey:@"name_en"]);
            }
            label.font = SYS_Font(11);
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = color;
            [cell.editView addSubview:label];
            speace += (width + 10);
            if ([dic valueForKey:@"id"]) {
                improssStr = [improssStr stringByAppendingFormat:@"%@,",minstr([dic valueForKey:@"id"])];
            }else{
                improssStr = [improssStr stringByAppendingFormat:@"%@,",minstr([dic valueForKey:@"name"])];
                if ([lagType isEqual:EN]) {
                    improssStr = [improssStr stringByAppendingFormat:@"%@,",minstr([dic valueForKey:@"name_en"])];
                }
            }
        }
        [self changeRightBtnState];

    }
}
- (void)rightBtnClick{
    WeakSelf;
    [[YBStorageManage shareManage]getCOSInfo:^(int code) {
        if (code == 0) {
            [weakSelf startUploadPics];
        }
    }];
}
-(void)startUploadPics{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block int uploadStateCode = 0;
    
    if (headerImg) {
        NSString *coverImgName = [YBToolClass getNameBaseCurrentTime:@"thumb.png"];
        dispatch_group_async(group, queue, ^{
            [[YBStorageManage shareManage]yb_storageImg:headerImg andName:coverImgName progress:^(CGFloat percent) {
                
            } complete:^(int code, NSString *key) {
                if (code != 0) {
                    uploadStateCode = -1;
                }
                headerStr = key;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }else{
        headerStr = @"";
    }
    _audioUrlStr = @"";
    if (_audioPath) {
        
        dispatch_group_async(group, queue, ^{
            NSString *voiceName = [YBToolClass getNameBaseCurrentTime:@"_user_audio.m4a"];
            [[YBStorageManage shareManage]yb_storageVideoOrVoice:self.audioPath andName:voiceName progress:^(CGFloat percent) {

            } complete:^(int code, NSString *key) {
                if (code != 0) {
                    uploadStateCode = -1;
                }
                _audioUrlStr = key;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });

    }
    WeakSelf;
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            if (uploadStateCode == 0) {
                [weakSelf submitAllMessage];
            }else {
                [MBProgressHUD showError:YZMsg(@"提交失败")];
            }
            
        });
    });
    
}
- (void)submitAllMessage{
    
    NSLog(@"======headerStr:%@ \n nameStr:%@ \n _audioUrlStr:%@ \n sexStr:%@ \n heightStr:%@ \n boadStr:%@ \n starStr:%@ \n improssStr:%@ \n provinceStr:%@\n cityStrrrrrrr:%@\n districtStr:%@\n signature:%@\n introduceStr:%@",headerStr,nameStr,_audioUrlStr,sexStr,heightStr,boadStr,starStr,improssStr,provinceStr,cityStrrrrrrr,districtStr,introduceStr,autographStr);
    NSDictionary *dic = @{
                          @"avatar":headerStr,
                          @"name":nameStr,
                          @"audio":_audioUrlStr,
                          @"audio_length":@(_voicetime),
                          @"sex":sexStr,
                          @"height":heightStr,
                          @"weight":boadStr,
                          @"constellation":starStr,
                          @"label":improssStr,
                          @"province":provinceStr,
                          @"city":cityStrrrrrrr,
                          @"district":districtStr,
                          @"intr":introduceStr,
                          @"signature":autographStr
                          };
    [YBToolClass postNetworkWithUrl:@"User.upUserInfo" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:YZMsg(@"提交失败")];

    }];
}
#pragma mark ==播放音频===
-(void)audioImgClick{
    EditUserVoiceCell *cell =(EditUserVoiceCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

    int floattotal = self.voicetime;
    
    islisten = !islisten;
    if (islisten) {
        voiceEnd = NO;
        if (_voicePlayer) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
            [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
            [_voicePlayer removeObserver:self forKeyPath:@"status"];
            [_voicePlayer pause];
            _voicePlayer = nil;
        }else{
        }
        NSURL * url;
        if (isRecordVoice) {
            url= [NSURL fileURLWithPath:self.audioPath isDirectory:NO];
        }else{
            url = [NSURL URLWithString:_audioUrlStr];
        }
        
        AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
        _voicePlayer = [[AVPlayer alloc]initWithPlayerItem:songItem];
        [_voicePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        //        _voicePlayer.automaticallyWaitsToMinimizeStalling = NO;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        WeakSelf;
        _playbackTimeObserver = [_voicePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            //当前播放的时间
            CGFloat floatcurrent = CMTimeGetSeconds(time);
            NSLog(@"floatcurrent = %.1f",floatcurrent);
            //总时间
            
            cell.voiceTimeLb.text =[NSString stringWithFormat:@"%.0fs",(floattotal-floatcurrent) > 0 ? (floattotal-floatcurrent) : 0];
            
        }];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        _voicePlayer.volume = 1;

        [_voicePlayer play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        
    }else{
        cell.vioceImgNormal.hidden = NO;
        
        cell.animationView.hidden = YES;
        if (_voicePlayer) {
            [_voicePlayer pause];
        }
    }

}

- (void)playFinished:(NSNotification *)not{
    EditUserVoiceCell *cell =(EditUserVoiceCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

    voiceEnd = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
    [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
    [_voicePlayer removeObserver:self forKeyPath:@"status"];
    [_voicePlayer pause];
    _voicePlayer = nil;
    
    cell.animationView.hidden = YES;
    cell.voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
    cell.vioceImgNormal.hidden = NO;
    
}
- (void)appDidEnterBackground:(NSNotification *)not{
    if (_voicePlayer) {
        [_voicePlayer pause];
        [self playFinished:not];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"----播放失败----------");
                [MBProgressHUD showError:YZMsg(@"播放失败")];
                voiceEnd = NO;
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                EditUserVoiceCell *cell =(EditUserVoiceCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                voiceEnd = YES;
                cell.vioceImgNormal.hidden = YES;
                cell.animationView.hidden = NO;
            }
                break;
            case AVPlayerStatusFailed:
            {
                [MBProgressHUD showError:YZMsg(@"播放失败")];
                voiceEnd = NO;
            }
                break;
        }
    }
}

-(void)voicedaojishi{
    EditUserVoiceCell *cell =(EditUserVoiceCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    oldVoiceTime--;
    cell.voiceTimeLb.text = [NSString stringWithFormat:@"%ds",oldVoiceTime];
}

-(void)timerPause{
    [voicetimer setFireDate:[NSDate distantFuture]];
}
-(void)timerBegin{
    [voicetimer setFireDate:[NSDate date]];
}
-(void)timerEnd{
    [voicetimer invalidate];
}

@end
