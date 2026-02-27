//
//  RKLBSManager.h
//  YBVideo
//
//  Created by YB007 on 2020/10/19.
//  Copyright © 2020 cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
    placemarks: 地标 CLPlacemark类型
    pcaArray:   省、市、区
 */
typedef void (^RKLbsBlock)(NSArray<CLPlacemark *> *placemarks,NSArray <NSString *>*pcaArray);
typedef void (^TencentListBlock)(NSArray *list);

/// 针对海外利用经纬度获取更加精确的城市名称【需要开通海外权限】
static const BOOL exactCity = NO;

@interface RKLBSManager : NSObject

@property (nonatomic, assign)BOOL fromEdit;
+(instancetype)shareManager;

-(void)startLocation;
-(void)locationComplete:(RKLbsBlock)complete;

#pragma mark - 打开导航软件开始

-(void)showNavigationsWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName;

#pragma mark - 打开导航软件结束

#pragma mark - 周边
-(void)txMapPoisWithCoordinate:(CLLocationCoordinate2D)coordinate andPage:(NSInteger)page complete:(TencentListBlock)locList;

#pragma mark - 搜索地区
-(void)txSearch:(NSString *)keys coordinate:(CLLocationCoordinate2D)coordinate andPage:(NSInteger)page complete:(TencentListBlock)locList;
@end


