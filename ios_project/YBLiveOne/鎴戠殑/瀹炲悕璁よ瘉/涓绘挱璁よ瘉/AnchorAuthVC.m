//
//  AnchorAuthVC.m
//  YBLiveOne
//
//  Created by ybRRR on 2021/11/26.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "AnchorAuthVC.h"
#import "ShowDetailVC.h"
@interface AnchorAuthVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
{
    UIScrollView *backScroll;
    UIView *picView1;
    UIView *picView2;
    UIView *picView3;

    NSString *peopleImgStr;
    NSString *backImgStr;
    NSString *peopleVideoStr;
    NSString *videoPathStr;
    NSString *videoPathFormatStr;

    NSString *outputPath;
    
    UIImage *peopleImg;
    UIImage *backImg;
    UIImage *peopleVideoImg;

    UIButton *peopleBtn;
    UIButton *backBtn;
    UIButton *peopleVideoBtn;
    UIButton *playVideoBtn;
    
    NSString *selectType;
    
    NSMutableArray *backWallArr;
    
    UIView *backWallView;
    UIView *line;
    UIView *backView;
    UILabel *rpicT;
    UILabel *picTsub2;
    UIButton *subBtn;
    
    NSMutableArray *upWallImgArr;//上传用标题数组

}
@end

@implementation AnchorAuthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = YZMsg(@"主播认证");
    self.view.backgroundColor = RGBA(245, 245, 245, 1);
    backWallArr = [NSMutableArray array];
    peopleImgStr = @"";
    backImgStr = @"";
    peopleVideoStr = @"";
    videoPathStr = @"";
    videoPathFormatStr = @"";
    [self createUI];
    //status：-1 没有提交认证  0 审核中  1  通过  2 拒绝
    NSString *typeStr =minstr([_authDic valueForKey:@"status"]);
    if ([typeStr isEqual:@"-1"]) {
        [backWallArr addObject:@""];
        [self addBackWallPic];
        subBtn.layer.cornerRadius = 22;
        subBtn.layer.masksToBounds = YES;
        CAGradientLayer*gradientLayer =  [CAGradientLayer layer];
        gradientLayer.frame=subBtn.bounds;
        gradientLayer.startPoint=CGPointMake(0,0);
        gradientLayer.endPoint=CGPointMake(1,0);
        gradientLayer.locations = @[@(0),@(1.0)];//渐变点
        [gradientLayer setColors:@[(id)[RGBA(178,1,253,1) CGColor],(id)[RGBA(115,3,251,1) CGColor]]];//渐变数组
        [subBtn.layer addSublayer:gradientLayer];
        [subBtn setTitle:YZMsg(@"提交认证") forState:0];
        playVideoBtn.hidden = YES;
        [subBtn setTitleColor:UIColor.whiteColor forState:0];
        subBtn.titleLabel.font = [UIFont systemFontOfSize:14];

    }else{
        NSArray *wallArr = [self.authDic valueForKey:@"backwall_list_format"];
        [backWallArr addObjectsFromArray:wallArr];
        [backWallArr addObject:@""];
        [self setUIData];
    }


}
-(void)setUIData{
    peopleImgStr = minstr([self.authDic valueForKey:@"thumb"]);
    backImgStr = minstr([self.authDic valueForKey:@"backwall"]);
    peopleVideoStr = minstr([self.authDic valueForKey:@"video_thumb"]);
    videoPathStr = minstr([self.authDic valueForKey:@"video"]);
    videoPathFormatStr = minstr([self.authDic valueForKey:@"video_format"]);
    
    [peopleBtn sd_setImageWithURL:[NSURL URLWithString:minstr([self.authDic valueForKey:@"thumb_format"])] forState:0];
    [peopleVideoBtn sd_setImageWithURL:[NSURL URLWithString:minstr([self.authDic valueForKey:@"video_thumb_format"])] forState:0];
    if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"0"]) {
        [subBtn setTitle:YZMsg(@"审核中") forState:0];
        [subBtn setBackgroundColor:UIColor.grayColor];
        subBtn.hidden = NO;
        subBtn.userInteractionEnabled = NO;
        peopleBtn.userInteractionEnabled  = NO;
        peopleVideoBtn.userInteractionEnabled = NO;
        [backWallArr removeLastObject];

    }else if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"2"]){
        subBtn.hidden = NO;

        CAGradientLayer*gradientLayer =  [CAGradientLayer layer];
        gradientLayer.frame=subBtn.bounds;
        gradientLayer.startPoint=CGPointMake(0,0);
        gradientLayer.endPoint=CGPointMake(1,0);
        gradientLayer.locations = @[@(0),@(1.0)];//渐变点
        [gradientLayer setColors:@[(id)[RGBA(178,1,253,1) CGColor],(id)[RGBA(115,3,251,1) CGColor]]];//渐变数组
        [subBtn.layer addSublayer:gradientLayer];
        subBtn.layer.masksToBounds = YES;
        [subBtn setTitle:YZMsg(@"审核失败，请重新上传") forState:0];
    }else if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"1"]){
        subBtn.hidden = YES;
        //审核通过
        peopleBtn.userInteractionEnabled  = NO;
        peopleVideoBtn.userInteractionEnabled = NO;
        [backWallArr removeLastObject];
    }
    [self addBackWallPic];

    [subBtn setTitleColor:UIColor.whiteColor forState:0];
    subBtn.titleLabel.font = [UIFont systemFontOfSize:14];
}

-(void)createUI{
    backScroll = [[UIScrollView alloc]init];
    backScroll.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height);
    backScroll.backgroundColor = UIColor.clearColor;
    [self.view addSubview:backScroll];
    
    UILabel *titleLb = [[UILabel alloc]init];
    //titleLb.frame = CGRectMake(12, 10, _window_width-24, 30);
    titleLb.font = [UIFont systemFontOfSize:13];
    titleLb.textColor = UIColor.blackColor;
    titleLb.text = YZMsg(@"以下信息均为必填项，为保证您的利益，请如实填写");
    titleLb.numberOfLines = 0;
    [backScroll addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(backScroll.mas_width).offset(-24);
        make.left.equalTo(backScroll.mas_left).offset(12);
        make.top.equalTo(backScroll.mas_top).offset(10);
    }];
    
    backView = [[UIView alloc]init];
    backView.backgroundColor = UIColor.whiteColor;
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    [backScroll addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLb.mas_left);
        make.right.equalTo(titleLb.mas_right);
        make.top.equalTo(titleLb.mas_bottom).offset(10);
    }];
    
    
    UILabel *picT = [[UILabel alloc]init];
    picT.font = [UIFont systemFontOfSize:15];
    picT.textColor = UIColor.blackColor;
    picT.text = YZMsg(@"真人照片");
    [backView addSubview:picT];
    [picT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.mas_left).offset(22);
        make.top.equalTo(backView.mas_top).offset(10);
    }];
    UILabel *picTsub1 = [[UILabel alloc]init];
    picTsub1.font = [UIFont systemFontOfSize:11];
    picTsub1.textColor = UIColor.grayColor;
    picTsub1.text = YZMsg(@"* 请上传一张本人真实照片，将作为列表封面展示");
    picTsub1.numberOfLines = 0;
    [backView addSubview:picTsub1];
    [picTsub1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(picT.mas_left);
        make.top.equalTo(picT.mas_bottom).offset(10);
        make.right.lessThanOrEqualTo(backView.mas_right).offset(-22);
    }];
    
    picView1 = [self picImageView:@"img"];
    [backView addSubview:picView1];
    [picView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(picTsub1.mas_left);
        make.top.equalTo(picTsub1.mas_bottom).offset(5);
        make.width.mas_equalTo(96);
        make.height.mas_equalTo(128);
    }];
    peopleBtn = [UIButton buttonWithType:0];
    peopleBtn.tag = 10000;
    peopleBtn.imageView.contentMode =UIViewContentModeScaleAspectFill;
    [peopleBtn addTarget:self action:@selector(selectImgeClick:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:peopleBtn];
    [peopleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(picView1);
    }];
    
    picTsub2 = [[UILabel alloc]init];
    picTsub2.font = [UIFont systemFontOfSize:11];
    picTsub2.textColor = UIColor.grayColor;
    picTsub2.text = YZMsg(@"* 请务必上传至少一张本人真实照片，将作为个人主页背景墙展示");
    picTsub2.numberOfLines = 0;
    [backView addSubview:picTsub2];
    [picTsub2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(picT.mas_left);
        make.top.equalTo(picView1.mas_bottom).offset(10);
        make.right.lessThanOrEqualTo(backView.mas_right).offset(-22);
    }];
    
    backWallView = [[UIView alloc]init];
    [backView addSubview:backWallView];
    [backWallView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(picTsub2.mas_left);
        make.top.equalTo(picTsub2.mas_bottom).offset(5);
        make.right.equalTo(backView.mas_right).offset(-22);
    }];

    [self addBackWallPic];

    line = [[UIView alloc]init];
    line.backgroundColor = RGBA(245, 245, 245, 1);
    [backView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backWallView.mas_left);
        make.top.equalTo(backWallView.mas_bottom).offset(10);
        make.right.equalTo(backView.mas_right).offset(-12);
        make.height.mas_equalTo(1);
    }];
    
    rpicT = [[UILabel alloc]init];
    rpicT.font = [UIFont systemFontOfSize:15];
    rpicT.textColor = UIColor.blackColor;
    rpicT.text = YZMsg(@"真人视频");
    [backView addSubview:rpicT];
    [rpicT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(picT.mas_left);
        make.top.equalTo(line.mas_top).offset(10);
    }];

    picView3 = [self picImageView:@"video"];
    [backView addSubview:picView3];
    [picView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rpicT.mas_left);
        make.top.equalTo(rpicT.mas_bottom).offset(5);
        make.width.mas_equalTo(96);
        make.height.mas_equalTo(128);
    }];
    peopleVideoBtn = [UIButton buttonWithType:0];
    peopleVideoBtn.tag = 10002;
    peopleVideoBtn.imageView.contentMode =UIViewContentModeScaleAspectFill;
    [peopleVideoBtn addTarget:self action:@selector(selectImgeClick:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:peopleVideoBtn];
    [peopleVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(picView3);
    }];
    
    [backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(picView3.mas_bottom).offset(10);
    }];
    
    
    playVideoBtn = [UIButton buttonWithType:0];
    [playVideoBtn setImage:[UIImage imageNamed:@"anchorVideo"] forState:0];
    [backView addSubview:playVideoBtn];
    [playVideoBtn addTarget:self action:@selector(playVideoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [playVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(peopleVideoBtn);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.view layoutIfNeeded];
    backScroll.contentSize = CGSizeMake(_window_width, backView.height+480);
    
    subBtn = [UIButton buttonWithType:0];
    subBtn.frame = CGRectMake(40, _window_height-60-ShowDiff, _window_width-80, 44);
    subBtn.layer.cornerRadius = 22;
    [subBtn addTarget:self action:@selector(anchorSubClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subBtn];

}


-(UIView *)picImageView:(NSString *)type{
    UIView *picView = [[UIView alloc]init];
    picView.backgroundColor = RGBA(242,242,242,1);
    picView.layer.cornerRadius = 5;
    picView.layer.masksToBounds = YES;
    
    UILabel *picbottomT = [[UILabel alloc]init];
    picbottomT.font = [UIFont systemFontOfSize:14];
    if ([type isEqual:@"img"]) {
        picbottomT.text = YZMsg(@"添加图片");
    }else{
        picbottomT.text = YZMsg(@"添加视频");

    }
    picbottomT.textColor = normalColors;
    picbottomT.textAlignment = NSTextAlignmentCenter;
    [picView addSubview:picbottomT];
    [picbottomT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(picView.mas_bottom).offset(-20);
        make.centerX.equalTo(picView.mas_centerX);
    }];
    UIImageView *addImg = [[UIImageView alloc]init];
    addImg.image = [UIImage imageNamed:@"authImgadd"];
    [picView addSubview:addImg];
    [addImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(picbottomT.mas_top).offset(-20);
        make.centerX.equalTo(picbottomT.mas_centerX);
        make.width.height.mas_equalTo(31);
    }];

    return  picView;
}
-(void)addBackWallPic{
    [backWallView removeAllSubviews];
    NSLog(@"----=-=-=-=-=backwallimg:%@",backWallArr);
    MASViewAttribute *img_bottom;
    for (int i = 0; i < backWallArr.count; i ++) {
        if (i >5) {
            return;
        }
        UIView *picView222 = [self picImageView:@"img"];
        [backWallView addSubview:picView222];
        if (i <3) {
            [picView222 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(backWallView).offset(i *100);
                make.top.equalTo(backWallView.mas_top);
                make.width.mas_equalTo(96);
                make.height.mas_equalTo(128);
            }];
            [backWallView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(picView222.mas_bottom).offset(10);
                make.left.equalTo(picTsub2.mas_left);
                make.top.equalTo(picTsub2.mas_bottom).offset(5);
                make.right.equalTo(backView.mas_right).offset(-22);

            }];
            img_bottom = picView222.mas_bottom;
        }else{
            [picView222 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(backWallView).offset((i-3) *100);
                make.top.equalTo(img_bottom).offset(10);
                make.width.mas_equalTo(96);
                make.height.mas_equalTo(128);
            }];
            [backWallView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(picView222.mas_bottom).offset(10);
                make.left.equalTo(picTsub2.mas_left);
                make.top.equalTo(picTsub2.mas_bottom).offset(5);
                make.right.equalTo(backView.mas_right).offset(-22);
            }];

        }

        backBtn = [UIButton buttonWithType:0];
        backBtn.tag = 10001;
        backBtn.imageView.contentMode =UIViewContentModeScaleAspectFill;
        [backBtn addTarget:self action:@selector(selectImgeClick:) forControlEvents:UIControlEventTouchUpInside];
        [picView222 addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(picView222);
        }];
        BOOL haveImgBool = NO;
        if ([backWallArr[i] isKindOfClass:[UIImage class]]) {
            [backBtn setImage:backWallArr[i] forState:0];
            haveImgBool = YES;
        }else{
            NSString *imgUrl =backWallArr[i];
            if (imgUrl.length > 1) {
                [backBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:0];
                haveImgBool = YES;
            }
        }

        UIButton *deleteBtn = [UIButton buttonWithType:0];
        [deleteBtn setBackgroundColor:RGB_COLOR(@"#FC3D3E", 1)];
        [deleteBtn setTitle:YZMsg(@"-") forState:0];
        [deleteBtn setTitleColor:UIColor.whiteColor forState:0];
        deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        deleteBtn.layer.cornerRadius = 10;
        deleteBtn.layer.masksToBounds = YES;
        [deleteBtn addTarget:self action:@selector(deleteimgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = 20000+i;
        [picView222 addSubview:deleteBtn];
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(picView222).offset(5);
            make.right.equalTo(picView222).offset(-5);
            make.width.height.mas_equalTo(20);
        }];
        if (haveImgBool) {
            deleteBtn.hidden = NO;
        }else{
            deleteBtn.hidden = YES;
        }
        if ([minstr([_authDic valueForKey:@"status"]) isEqual:@"1"] ||[minstr([_authDic valueForKey:@"status"]) isEqual:@"0"]){
            deleteBtn.hidden = YES;
            backBtn.userInteractionEnabled = NO;
        }
    }
    [self.view layoutSubviews];

}

-(void)playVideoBtnClick{
    ShowDetailVC *detail = [[ShowDetailVC alloc]init];
    detail.videoPath =videoPathFormatStr;
    detail.backcolor = @"video";
    detail.fromStr = @"trendlist";
    [[YBAppDelegate sharedAppDelegate]pushViewController:detail animated:YES];

}
-(void)deleteimgBtnClick:(UIButton *)sender{
    NSInteger tags =sender.tag-20000;
    NSMutableArray *arr =backWallArr;
    [arr removeObjectAtIndex:tags];
    backWallArr = arr;
    [self addBackWallPic];
}

-(void)selectImgeClick:(UIButton *)sender{
    NSInteger sendertag = sender.tag;
    switch (sendertag) {
        case 10000:
            selectType = @"0";
            [self selectphotoclick];
            break;
        case 10001:
            selectType = @"1";
            [self selectphotoclick];

            break;
        case 10002:
            selectType = @"2";
            [self selectVideoClick];
            break;
        default:
            break;
    }
}
#pragma mark ==提交认证==
-(void)anchorSubClick{

    //判断背景墙图片有木有
    BOOL iswallImg = NO;
    for (int i = 0; i < backWallArr.count; i ++) {
        if ([backWallArr[i] isKindOfClass:[UIImage class]]) {
            iswallImg = YES;
            break;
        }else{
            NSString *imgUrl =backWallArr[i];
            if (imgUrl.length > 1) {
                iswallImg = YES;
                break;
            }
        }
    }
    NSLog(@"iswallIMg------:%d",iswallImg);
    if (!peopleImg && peopleImgStr.length < 1) {
        [MBProgressHUD showError:YZMsg(@"请上传列表封面")];
        return;
    }else if (!iswallImg && backImgStr.length < 1){
        [MBProgressHUD showError:YZMsg(@"请上传背景墙封面")];
        return;
    }else if (!peopleVideoImg &&peopleVideoStr.length < 1){
        [MBProgressHUD showError:YZMsg(@"请上传视频")];
        return;
    }
    WeakSelf;
    [[YBStorageManage shareManage]getCOSInfo:^(int code) {
        if (code == 0) {
            [weakSelf startUpload];
        }
    }];

}
-(void)startUpload{
    [MBProgressHUD showMessage:@""];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    WeakSelf;
    //封面照
    if (peopleImg) {
        dispatch_group_async(group, queue, ^{
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"_peopleImg.png"];
            [[YBStorageManage shareManage]yb_storageImg:peopleImg andName:imageName progress:^(CGFloat percent) {
                
            }complete:^(int code, NSString *key) {

                peopleImgStr = minstr(key);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    //背景墙
    upWallImgArr = [NSMutableArray array];
    for (int i = 0; i < backWallArr.count; i ++) {
        if ([backWallArr[i] isKindOfClass:[UIImage class]]) {
            UIImage *image =backWallArr[i];
            NSData *imageData = UIImagePNGRepresentation(image);
            if (!imageData) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:YZMsg(@"图片错误")];
                return;
            }

            dispatch_group_async(group, queue, ^{
                NSString *countImgStr = [NSString stringWithFormat:@"_backImg%d.png",i];
                NSString *imageName = [YBToolClass getNameBaseCurrentTime:countImgStr];
                [[YBStorageManage shareManage]yb_storageImg:image andName:imageName progress:^(CGFloat percent) {
                    
                }complete:^(int code, NSString *key) {
                    [upWallImgArr addObject:minstr(key)];
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            });

        }else{
            NSString *imgthumb =backWallArr[i];
            if (imgthumb.length > 1) {
                NSArray *imgArr = [imgthumb componentsSeparatedByString:@"/"];
                imgthumb = [imgArr lastObject];
                [upWallImgArr addObject:imgthumb];
            }
        }

    }
    
    //视频封面
    if (peopleVideoImg) {
        dispatch_group_async(group, queue, ^{
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"_peopleVideoImg.png"];
            [[YBStorageManage shareManage]yb_storageImg:peopleVideoImg andName:imageName progress:^(CGFloat percent) {
                
            }complete:^(int code, NSString *key) {
                peopleVideoStr = minstr(key);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    //视频路径
    if (![YBToolClass checkNull:outputPath]) {
        dispatch_group_async(group, queue, ^{
            NSString *videoName = [YBToolClass getNameBaseCurrentTime:@"_peopleVideo_video.mp4"];
            [[YBStorageManage shareManage]yb_storageVideoOrVoice:outputPath andName:videoName progress:^(CGFloat percent) {
                
            } complete:^(int code, NSString *key) {
                videoPathStr = key;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }

    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf goResServer];
        });
        NSLog(@"任务完成执行");
    });

}
-(void)goResServer{
    NSMutableArray * sortTitleArr = [self compareArrWithArray:upWallImgArr];
    backImgStr = @"";
    for (NSString *wallStr in sortTitleArr) {
        if (backImgStr.length == 0) {
            backImgStr = wallStr;
        }else{
            backImgStr = [NSString stringWithFormat:@"%@,%@",backImgStr,wallStr];
        }
    }
    NSLog(@"backIMgStr-------:%@",backImgStr);
    NSDictionary *parDic = @{@"uid":[Config getOwnID],@"token":[Config getOwnToken],@"thumb":peopleImgStr,@"backwall":backImgStr,@"video_thumb":peopleVideoStr,@"video":videoPathStr};
    [YBToolClass postNetworkWithUrl:@"Auth.setAuthorAuth" andParameter:parDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            [[YBAppDelegate sharedAppDelegate]popViewController:YES];
        }else{
        }
            [MBProgressHUD showError:msg];

        } fail:^{
    }];

}
-(NSMutableArray *)compareArrWithArray:(NSArray *)arr{
    //图片排序
     NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    //这块取出数组中的数字，  请根据自己数组而定
    for (int i = 0; i < arr.count; i++) {
        NSArray *array = [arr[i] componentsSeparatedByString:@"_image"];
        NSString *str_t = [array lastObject];
        
        NSArray *array_t =[str_t componentsSeparatedByString:@"_cover"];
        NSString *str = [array_t firstObject];

        [dict setValue:arr[i] forKey:str];
    }

    NSArray *arrKey = [dict allKeys];
    //将key排序
    NSArray *sortedArray = [arrKey sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        return[obj1 compare:obj2 options:NSNumericSearch];//正序
    }];
    
    NSMutableArray *orderValueArray=[NSMutableArray array];
    
    //根据key的顺序提取相应value
    for (NSString *key in sortedArray) {
        [orderValueArray addObject:[dict objectForKey:key]];
    }
    return orderValueArray;
}

#pragma mark ====选择视频========
-(void)selectVideoClick{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:YZMsg(@"拍摄") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
        NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
        ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
        [self presentViewController:ipc animated:YES completion:nil];
        ipc.videoMaximumDuration = MAX_RECORD_TIME;
        ipc.delegate = self;//设置委托
        
    }];
    [picAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:picAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];

}
- (UIImage*)getVideoFirstViewImage:(NSURL *)path {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
}

#pragma mark ====选择相册========
-(void)selectphotoclick{
    
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:YZMsg(@"拍摄") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
    }];
    [picAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:picAction];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:YZMsg(@"本地照片") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self selLocalPic];
    }];
    [photoAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:photoAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];

}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;
    imagePickerController.allowsEditing = YES;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:imagePickerController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        if ([selectType isEqual:@"0"]) {
            peopleImg = image;
            [peopleBtn setImage:peopleImg forState:0];
        }else if ([selectType isEqual:@"1"]){
            [backWallArr insertObject:image atIndex:backWallArr.count-1];
            [self addBackWallPic];
        }
    }else{
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        outputPath =[sourceURL path];
        videoPathFormatStr = outputPath;
        UIImage *viodeimg =[self getVideoFirstViewImage:[NSURL fileURLWithPath:outputPath]];
        peopleVideoImg = viodeimg;
        [peopleVideoBtn setImage:peopleVideoImg forState:0];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

-(void)selLocalPic {
    TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imagePC.preferredLanguage = [lagType isEqual:ZH_CN] ? @"zh-Hans":@"en";
    imagePC.showSelectBtn = NO;
    imagePC.allowCrop = NO;
    imagePC.allowPickingOriginalPhoto = NO;
    imagePC.oKButtonTitleColorNormal = normalColors;
    imagePC.allowTakePicture = NO;
    imagePC.allowTakeVideo = NO;
    imagePC.allowPickingVideo = NO;
    imagePC.allowPickingMultipleVideo = NO;
    imagePC.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:imagePC animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSLog(@"------多选择图片--：%@",photos);
    UIImage* image = photos[0];
    if ([selectType isEqual:@"0"]) {
        peopleImg = image;
        [peopleBtn setImage:peopleImg forState:0];
    }else if ([selectType isEqual:@"1"]){
        [backWallArr insertObject:image atIndex:backWallArr.count-1];
        [self addBackWallPic];
    }
}

@end
