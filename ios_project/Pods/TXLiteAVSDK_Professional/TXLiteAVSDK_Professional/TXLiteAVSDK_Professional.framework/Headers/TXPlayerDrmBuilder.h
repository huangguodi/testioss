//  Copyright © 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

/**
 * 点播Drm构造器
 */
LITEAV_EXPORT @interface TXPlayerDrmBuilder : NSObject

///证书提供商url
@property(nonatomic, strong) NSString *deviceCertificateUrl;

///解密key url
@property(nonatomic, strong) NSString *keyLicenseUrl;

///播放链接
@property(nonatomic, strong) NSString *playUrl;

@end
