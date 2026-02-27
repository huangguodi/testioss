/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Author: ianyanzhang
 */
#import <Foundation/Foundation.h>
#import "TXPlayerAuthParams.h"
#import "TXLiteAVSymbolExport.h"

/**
 * 下载视频的清晰度
 */
typedef NS_ENUM(NSInteger, TXVodQuality) {

    ///原画
    TXVodQualityOD = 0,

    ///流畅
    TXVodQualityFLU,

    ///标清
    TXVodQualitySD,

    ///高清
    TXVodQualityHD,

    ///全高清
    TXVodQualityFHD,

    /// 2K
    TXVodQuality2K,

    /// 4K
    TXVodQuality4K,
};

/**
 * 下载错误码
 */
typedef NS_ENUM(NSInteger, TXDownloadError) {

    ///下载成功
    TXDownloadSuccess = 0,

    /// fileid鉴权失败
    TXDownloadAuthFaild = -5001,

    ///无此清晰度文件
    TXDownloadNoFile = -5003,

    ///格式不支持
    TXDownloadFormatError = -5004,

    ///网络断开
    TXDownloadDisconnet = -5005,

    ///获取HLS解密key失败
    TXDownloadHlsKeyError = -5006,

    ///下载目录访问失败
    TXDownloadPathError = -5007,
};

/**
 * 下载状态
 */
typedef NS_ENUM(NSInteger, TXVodDownloadMediaInfoState) {
    TXVodDownloadMediaInfoStateInit = 0,
    TXVodDownloadMediaInfoStateStart = 1,
    TXVodDownloadMediaInfoStateStop = 2,
    TXVodDownloadMediaInfoStateError = 3,
    TXVodDownloadMediaInfoStateFinish = 4,
};

/**
 * 下载源，通过fileid方式下载
 */
LITEAV_EXPORT @interface TXVodDownloadDataSource : NSObject

/// fileid信息
@property(nonatomic, strong) TXPlayerAuthParams *auth;

///下载清晰度，默认高清（获取下载信息时，此参数需和下载视频时使用的参数一致）
@property(nonatomic, assign) TXVodQuality quality;

///如地址有加密，请填写token
@property(nonatomic, copy) NSString *token;

///清晰度模板。如果后台转码是自定义模板，请在这里填写模板名。templateName和quality同时设置时，以templateName为v准
@property(nonatomic, copy) NSString *templateName;

///文件Id
@property(nonatomic, copy) NSString *fileId;

///签名信息
@property(nonatomic, copy) NSString *pSign;

///应用appId。必填
@property(nonatomic, assign) int appId;

///账户名称，默认值为‘default’
@property(nonatomic, copy) NSString *userName;

/// HLS EXT-X-KEY 加解密参数
@property(nonatomic, copy) NSString *overlayKey;

@property(nonatomic, copy) NSString *overlayIv;

@end

LITEAV_EXPORT @interface TXVodDownloadMediaInfo : NSObject

/**
 * fileid下载对象（url下载时为可选，fileid下载时此参数为必填参数）
 */
@property(nonatomic, strong) TXVodDownloadDataSource *dataSource;

/**
 * 下载地址（使用私有加密下载时，请使用fileid对象下载）
 */
@property(nonatomic, copy) NSString *url;

/**
 * 账户名称
 */
@property(nonatomic, copy) NSString *userName;

/**
 * 时长
 */
@property(nonatomic, assign) int duration;

/**
 * 可播放时长
 */
@property(nonatomic, assign) int playableDuration;

/**
 * 文件总大小，单位：byte
 */
@property(nonatomic, assign) int size;

/**
 * 已下载大小，单位：byte
 */
@property(nonatomic, assign) int downloadSize;

/**
 * 分段总数
 */
@property(nonatomic, assign) int segments;

/**
 * 已下载的分段数
 */
@property(nonatomic, assign) int downloadSegments;

/**
 * 进度
 */
@property(nonatomic, assign) float progress;

/**
 * 播放路径，视频下载完成后可传给TXVodPlayer进行本地文件播放
 *
 * @discussion 此参数用于下载播放时，需要通过`getDownloadMediaInfoList` 或 `getDownloadMediaInfo:` 接口获取得到，不可以私下保存
 */
@property(nonatomic, copy) NSString *playPath;

/**
 * 下载速度，byte每秒
 */
@property(nonatomic, assign) int speed;

@property(nonatomic, assign) TXVodDownloadMediaInfoState downloadState;

- (BOOL)isDownloadFinished;

@end

@protocol TXVodDownloadDelegate <NSObject>

/**
 * 下载开始
 */
- (void)onDownloadStart:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载进度
 */
- (void)onDownloadProgress:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载停止
 */
- (void)onDownloadStop:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载完成
 */
- (void)onDownloadFinish:(TXVodDownloadMediaInfo *)mediaInfo;

/**
 * 下载错误
 */
- (void)onDownloadError:(TXVodDownloadMediaInfo *)mediaInfo errorCode:(TXDownloadError)code errorMsg:(NSString *)msg;

/**
 * 下载HLS，遇到加密的文件，将解密key给外部校验
 *
 * @param mediaInfo 下载对象
 * @param url Url地址
 * @param data 服务器返回
 * @return 0：校验正确，继续下载；否则校验失败，抛出下载错误（SDK 获取失败）
 */
- (int)hlsKeyVerify:(TXVodDownloadMediaInfo *)mediaInfo url:(NSString *)url data:(NSData *)data;

@end

LITEAV_EXPORT @interface TXVodDownloadManager : NSObject

/**
 * 下载任务回调
 */
@property(nonatomic, weak) id<TXVodDownloadDelegate> delegate;

/**
 * 设置 HTTP 头
 */
@property(nonatomic, strong) NSDictionary *headers;

/**
 * 是否支持私有加密模式(配置为系统播放器请设置为NO，自研播放器设置为YES), 默认设置为YES
 */
@property(nonatomic, assign) BOOL supportPrivateEncryptMode;

/**
 * 全局单例接口
 */
+ (TXVodDownloadManager *)shareInstance;

/**
 * 设置下载文件的根目录。
 *
 * @discussion 此处设置的下载目录优先以 ‘ TXPlayerGlobalSetting #setCacheFolderPath’ 设置为准
 * @param path 目录地址，如不存在，将自动创建
 * @warning 开始下载前必须设置，否则不能下载
 */
- (void)setDownloadPath:(NSString *)path;

/**
 * 下载文件
 *
 * @param source 下载源。
 * @return 成功返回下载对象，否则nil
 * @warning 目前只支持hls下载
 */
- (TXVodDownloadMediaInfo *)startDownload:(TXVodDownloadDataSource *)source;

/**
 * 下载文件
 *
 * @param username username
 * @param url url
 */
- (TXVodDownloadMediaInfo *)startDownload:(NSString *)username url:(NSString *)url;

/**
 * 停止下载
 *
 * @param media 停止下载对象
 */
- (void)stopDownload:(TXVodDownloadMediaInfo *)media;

/**
 * 删除下载产生的文件
 *
 * @return 文件正在下载将无法删除，返回NO
 */
- (BOOL)deleteDownloadFile:(NSString *)playPath;

/**
 * 删除下载信息
 *
 * @param downloadMediaInfo downloadMediaInfo
 */
- (void)deleteDownloadMediaInfo:(TXVodDownloadMediaInfo *)downloadMediaInfo;

/**
 * 获取下载列表, 调用此接口要确保之前通过 ' startDownload: ' 接口启动过下载任务
 *
 * @return 返回查询到的下载文件信息列表
 */
- (NSArray<TXVodDownloadMediaInfo *> *)getDownloadMediaInfoList;

/**
 * 获取下载信息，调用此接口要确保之前通过 ' startDownload: ' 接口启动过下载任务
 *
 * @param media 待查询的下载文件信息描述
 * @return 返回查询到的下载文件信息
 */
- (TXVodDownloadMediaInfo *)getDownloadMediaInfo:(TXVodDownloadMediaInfo *)media;

/**
 * 获取HLS EXT-X-KEY 加解密的overlayKey和overlayIv
 *
 * @param appId appId
 * @param userName userName
 * @param fileId fileId
 * @param qualityId qualityId
 */
- (NSString *)getOverlayKeyIv:(int)appId userName:(NSString *)userName fileId:(NSString *)fileId qualityId:(int)qualityId;

/**
 * 加密相关
 *
 * 获取加密随机数
 */
+ (NSString *)genRandomHexStringForHls;

/**
 * 加密
 *
 * @param originHexStr originHexStr
 */
+ (NSString *)encryptHexStringHls:(NSString *)originHexStr;

@end
