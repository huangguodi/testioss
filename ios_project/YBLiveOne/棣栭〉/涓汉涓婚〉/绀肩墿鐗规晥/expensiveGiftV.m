//
//  expensiveGiftV.m
//  yunbaolive
//
//  Created by 王敏欣 on 2017/1/9.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "expensiveGiftV.h"
#import "SDWebImageManager.h"

#import "AnchorViewController.h"
#import "LookVideoViewController.h"
#import "YBLookVideoVC.h"
#import "PersonMessageViewController.h"
#import "TChatController.h"

@implementation expensiveGiftV
-(instancetype)init{
    self = [super init];
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    if (self) {
        _haohuaCount = 0;
        _expensiveGiftCount = [NSMutableArray array];
    }
    return self;
}
-(void)sethaohuacount{
    if (_haohuaCount == 0) {
        _haohuaCount =1;
    }
    else{
        _haohuaCount = 0;
    }
}
-(void)addArrayCount:(NSDictionary *)dic{
    [_expensiveGiftCount addObject:dic];
}
-(void)stopHaoHUaLiwu{
    [expensiveGiftTime invalidate];
    expensiveGiftTime = nil;
    _expensiveGiftCount = nil;
}
-(void)enGiftEspensive{
    if (_expensiveGiftCount.count == 0 || _expensiveGiftCount == nil) {//判断队列中有item且不是满屏
        [expensiveGiftTime invalidate];
        expensiveGiftTime = nil;
        return;
    }
    NSDictionary *Dic = [_expensiveGiftCount firstObject];
    [_expensiveGiftCount removeObjectAtIndex:0];
    [self expensiveGiftPopView:Dic];
}
-(UIViewController *)getCurrentShowViewController
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowVC = [self recursiveFindCurrentShowViewControllerFromViewController:rootVC];
    return currentShowVC;
}

- (UIViewController *)recursiveFindCurrentShowViewControllerFromViewController:(UIViewController *)fromVC
{
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        return [self recursiveFindCurrentShowViewControllerFromViewController:[((UINavigationController *)fromVC) visibleViewController]];
    } else if ([fromVC isKindOfClass:[UITabBarController class]]) {
        return [self recursiveFindCurrentShowViewControllerFromViewController:[((UITabBarController *)fromVC) selectedViewController]];
    } else {
        if (fromVC.presentedViewController) {
            return [self recursiveFindCurrentShowViewControllerFromViewController:fromVC.presentedViewController];
        } else {
            return fromVC;
        }
    }
}
-(void)expensiveGiftPopView:(NSDictionary *)giftData{
    
    CGFloat seconds = [[giftData valueForKey:@"swftime"] floatValue];
    [self sethaohuacount];

    if ([minstr([giftData valueForKey:@"swftype"]) isEqual:@"1"]) {
        SVGAParser *parser = [[SVGAParser alloc] init];
        [parser parseWithURL:[NSURL URLWithString:minstr([giftData valueForKey:@"swf"])] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
            gifView = [[exoensiveGifGiftV alloc]initWithGiftData:giftData andVideoitem:videoItem];
            [self addSubview:gifView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [gifView removeFromSuperview];
                [self sethaohuacount];
                if (_expensiveGiftCount.count >0) {
                     //用于判断当前页面有没有被释放
                    UIViewController * showVC = [self getCurrentShowViewController];
                    if ([showVC isKindOfClass:[AnchorViewController class]] ||[showVC isKindOfClass:[LookVideoViewController class]]||[showVC isKindOfClass:[YBLookVideoVC class]]||[showVC isKindOfClass:[PersonMessageViewController class]]||[showVC isKindOfClass:[TChatController class]]) {
                        [self.delegate expensiveGiftdelegate:nil];
                    }
                }else{
                    NSLog(@"豪华礼物完毕111111");
                    if ([self.delegate respondsToSelector:@selector(endExpensiveGift)]) {
                        [self.delegate endExpensiveGift];
                    }

                }
            });
        } failureBlock:nil];
    }else{
        gifView = [[exoensiveGifGiftV alloc]initWithGiftData:giftData andVideoitem:nil];
        [self addSubview:gifView];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [gifView removeFromSuperview];
            [self sethaohuacount];
            if (_expensiveGiftCount.count >0) {
                [self.delegate expensiveGiftdelegate:nil];
            }else{
                NSLog(@"豪华礼物完毕222222");
                if ([self.delegate respondsToSelector:@selector(endExpensiveGift)]) {
                    [self.delegate endExpensiveGift];
                }

            }
        });
    }
}
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

@end
