/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Module:   V2TXLivePremier @ TXLiteAVSDK
 * Function: V2TXLive 高级接口
 */
#import "V2TXLiveDef.h"
#import "TXLiteAVSymbolExport.h"
NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                      V2TXLive 高级接口
//
/////////////////////////////////////////////////////////////////////////////////

@protocol V2TXLivePremierObserver;
@protocol V2TXLivePremier <NSObject>

/**
 * 获取 SDK 版本号
 */
+ (NSString *)getSDKVersionStr;

/**
 * 设置 V2TXLivePremier 回调接口
 */
+ (void)setObserver:(id<V2TXLivePremierObserver>)observer;

/**
 * 设置 Log 的配置信息
 */
+ (V2TXLiveCode)setLogConfig:(V2TXLiveLogConfig *)config;

/**
 * 设置 SDK 接入环境
 *
 * @note 如您的应用无特殊需求，请不要调用此接口进行设置。
 * @param env 目前支持 “default” 和 “GDPR” 两个参数。
 *        - default：默认环境，SDK 会在全球寻找最佳接入点进行接入。
 *        - GDPR：所有音视频数据和质量统计数据都不会经过中国大陆地区的服务器。
 */
+ (V2TXLiveCode)setEnvironment:(const char *)env;

/**
 * 设置 SDK 的授权 License
 *
 * 文档地址：https://cloud.tencent.com/document/product/454/34750。
 * @param url licence的地址。
 * @param key licence的秘钥。
 */
#if TARGET_OS_IPHONE
+ (void)setLicence:(NSString *)url key:(NSString *)key;
#endif

/**
 * 设置 SDK sock5 代理配置
 *
 * @param host sock5 代理服务器的地址。
 * @param port sock5 代理服务器的端口。
 * @param username sock5 代理服务器的验证的用户名。
 * @param password sock5 代理服务器的验证的密码。
 */
+ (V2TXLiveCode)setSocks5Proxy:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password;

/**
 * 开启/关闭对最终系统要播放出的音频数据的监听回调
 *
 * @param enable 是否开启。 【默认值】：false。
 * @param format 设置回调出的 AudioFrame 的格式。
 */
+ (V2TXLiveCode)enableAudioPlayoutObserver:(BOOL)enable format:(V2TXLiveAudioFrameObserverFormat *)format;

/**
 * 设置 userId
 *
 * @param userId 业务侧自身维护的用户/设备id。
 */
+ (void)setUserId:(NSString *)userId;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      V2TXLive 高级回调接口
//
/////////////////////////////////////////////////////////////////////////////////

@protocol V2TXLivePremierObserver <NSObject>
@optional

/**
 * 自定义 Log 输出回调接口
 */
- (void)onLog:(V2TXLiveLogLevel)level log:(NSString *)log;

/**
 * setLicence 接口回调
 *
 * @param result 设置 licence 结果 0 成功，负数失败。
 * @param reason 设置 licence 失败原因。
 */
- (void)onLicenceLoaded:(int)result Reason:(NSString *)reason;

/**
 * 将各路待播放音频混合之后并在最终提交系统播放之前的数据回调
 *
 * 当您设置完音频数据自定义回调之后，SDK 内部会把各路待播放的音频混合之后的音频数据，在提交系统播放之前，以 PCM 格式的形式通过本接口回调给您。
 * - 此接口回调出的音频时间帧长固定为 0.02s，格式为 PCM 格式。
 * - 由时间帧长转化为字节帧长的公式为 `采样率 × 时间帧长 × 声道数 × 采样点位宽`。
 * - 以 SDK 默认的音频录制格式 48000 采样率、单声道、16 采样点位宽为例，字节帧长为 `48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节`。
 * @param frame PCM 格式的音频数据帧。
 * @note
 * 1. 请不要在此回调函数中做任何耗时操作，由于 SDK 每隔 20ms 就要处理一帧音频数据，如果您的处理时间超过 20ms，就会导致声音异常。
 * 2. 此接口回调出的音频数据是可读写的，也就是说您可以在回调函数中同步修改音频数据，但请保证处理耗时。
 * 3. 此接口回调出的是对各路待播放音频数据的混合，但其中并不包含耳返的音频数据。
 */
- (void)onPlayoutAudioFrame:(V2TXLiveAudioFrame *)frame;

@end

LITEAV_EXPORT @interface V2TXLivePremier : NSObject<V2TXLivePremier>

@end

NS_ASSUME_NONNULL_END
