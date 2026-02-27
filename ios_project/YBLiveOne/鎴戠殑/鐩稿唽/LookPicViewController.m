//
//  LookPicViewController.m
//  YBLiveOne
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "LookPicViewController.h"
#import "minePicAuthViewController.h"
#import "MIneVideoViewController.h"
#import "JPVideoPlayerKit.h"
#import "YBEditImageViewController.h"
#import "RKActionSheet.h"
@interface LookPicViewController ()<UIScrollViewDelegate>{
    YBAlertView *alert;
    RKActionSheet *sheet;
}
@property (nonatomic,strong) UIImageView *backImgV;
@property (nonatomic,strong) UIScrollView *imgScroll;
@end

@implementation LookPicViewController
- (void)viewWillAppear:(BOOL)animated{
    if ([_wallModel.type isEqual:@"1"]) {
        [self.backImgV jp_resumePlayWithURL:[NSURL URLWithString:_wallModel.href]
                         bufferingIndicator:nil
                                controlView:[UIView new]
                               progressView:[UIView new]
                              configuration:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                              }];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([_wallModel.type isEqual:@"1"]) {
        [[JPVideoPlayerManager sharedManager]stopPlay];
    }
}
-(UIScrollView *)imgScroll {
    if (!_imgScroll) {
        _imgScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        _imgScroll.delegate = self;
        //底部不要透明，否则图片缩小的时候会看到被遮住的界面
        _imgScroll.backgroundColor = [UIColor blackColor];
        //最大级别
        _imgScroll.maximumZoomScale = 5;
        //初始化缩放级别
        self.imgScroll.zoomScale = 1;
        [self.view addSubview:_imgScroll];
    }
    return _imgScroll;
}
// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.backImgV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY);
}
// 设置UIScrollView中要缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.backImgV;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imgScroll];
    [self scrollViewDidZoom:self.imgScroll];

    _backImgV = [[UIImageView alloc]initWithFrame:self.imgScroll.bounds];
    _backImgV.contentMode = UIViewContentModeScaleAspectFit;
    _backImgV.userInteractionEnabled = YES;
    _backImgV.backgroundColor = UIColor.blackColor;
    _backImgV.clipsToBounds = YES;
    [self.imgScroll addSubview:_backImgV];
    CGSize maxSize = self.imgScroll.frame.size;
    CGFloat widthRatio = maxSize.width/_backImgV.size.width;
    CGFloat heightRatio = maxSize.height/_backImgV.size.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    self.imgScroll.minimumZoomScale = initialZoom;

    
    UILongPressGestureRecognizer *longGester = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImgGester:)];
    longGester.minimumPressDuration = 1;
    [_backImgV addGestureRecognizer:longGester];
    
    if (_model) {
        [_backImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    }else{
        [_backImgV sd_setImageWithURL:[NSURL URLWithString:_wallModel.thumb]];
    }
    UIImageView* mask_top = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100+statusbarHeight)];
    [mask_top setImage:[UIImage imageNamed:@"video_record_mask_top"]];
    [self.view addSubview:mask_top];

    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"video--返回"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:0];
    rightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);
    
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"三点白"] forState:0];
    [self.view  addSubview:rightBtn];

}
- (void)saveImgGester:(UIGestureRecognizer *)recognizer
{
    if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
       recognizer.state == UIGestureRecognizerStateBegan){
        WeakSelf;
        sheet = [[RKActionSheet alloc]initWithTitle:@""];
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"保存") complete:^{
            UIImageWriteToSavedPhotosAlbum(weakSelf.backImgV.image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }];
        [sheet addActionWithType:RKSheet_Cancle andTitle:YZMsg(@"取消") complete:^{
        }];
        [sheet showSheet];
    }
}

//指定回调方法
- (void)image: (UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (image == nil) {
        return;
    }
    NSString *msg;
    if(error != NULL){
        msg = YZMsg(@"保存图片失败") ;
    }else{
        msg = YZMsg(@"保存图片成功");
    }
    [MBProgressHUD showError:msg];
    NSLog(@"🌹🌹🌹🌹%@",msg);
}

- (void)doReturn{
    if (self.block) {
        self.block();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBtnClick{
    if (_wallModel) {
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:YZMsg(@"替换视频") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MIneVideoViewController *video = [[MIneVideoViewController alloc]init];
            video.isSelect = YES;
            video.oldID = _wallModel.wallID;
            [self.navigationController pushViewController:video animated:YES];
        }];
        [action1 setValue:color32 forKey:@"_titleTextColor"];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:YZMsg(@"替换图片") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            minePicAuthViewController *pic = [[minePicAuthViewController alloc]init];
            pic.isSelect = YES;
            pic.oldID = _wallModel.wallID;
            [self.navigationController pushViewController:pic animated:YES];
        }];
        [action2 setValue:color32 forKey:@"_titleTextColor"];
        
        
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:YZMsg(@"删除") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doDelThis];
        }];
        [action3 setValue:color32 forKey:@"_titleTextColor"];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
        [alertContro addAction:action1];
        [alertContro addAction:action2];
        [alertContro addAction:action3];
        [alertContro addAction:cancleAction];
        [self presentViewController:alertContro animated:YES completion:nil];

    }else{
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:YZMsg(@"设置为公开照片") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showAlertView];
        }];
        [action1 setValue:color32 forKey:@"_titleTextColor"];
        
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:YZMsg(@"设置为封面") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doSetFengmian];
        }];
        [action3 setValue:color32 forKey:@"_titleTextColor"];

        UIAlertAction *action2 = [UIAlertAction actionWithTitle:YZMsg(@"删除") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doDelThis];
        }];
        [action2 setValue:color32 forKey:@"_titleTextColor"];
        
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
        if ([_model.isprivate isEqual:@"1"]) {
            [alertContro addAction:action1];
        }else{
            if (![_model.status isEqual:@"0"]) {
                [alertContro addAction:action3];
            }
        }
        
        [alertContro addAction:action2];
        [alertContro addAction:cancleAction];
        [self presentViewController:alertContro animated:YES completion:nil];

    }

}
- (void)showAlertView{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:YZMsg(@"提示") andMessage:YZMsg(@"设置为公开照片后，将不可再设置为私密照片") andButtonArrays:@[YZMsg(@"取消"),YZMsg(@"设置")] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf setPublic];
        }else{
            [weakSelf removeAlertView];
        }
    }];
    [self.view addSubview:alert];
}
- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}
- (void)setPublic{
    [YBToolClass postNetworkWithUrl:@"Photo.setPublic" andParameter:@{@"photoid":_model.picID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            _model.isprivate = @"0";
            [self removeAlertView];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}
- (void)doSetFengmian{
    YBEditImageViewController *edit = [[YBEditImageViewController alloc]init];
    edit.originalImage = _backImgV.image;
    [self.navigationController pushViewController:edit animated:YES];

}
- (void)doDelThis{
    NSString *url;
    if (_model) {
        url = [NSString stringWithFormat:@"Photo.delPhoto&photoid=%@",_model.picID];
    }else{
        url = [NSString stringWithFormat:@"Wall.delWall&wallid=%@",_wallModel.wallID];
    }
    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if (_model) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMinePiclist" object:nil];
            }
            [self doReturn];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}

@end
