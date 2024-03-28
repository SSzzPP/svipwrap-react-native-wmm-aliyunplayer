//
//  AliyunPlayer.h
//  RNAliPlayer
//
//  Created by zlk on 2021/8/17.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import <AliyunPlayer/AliyunPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunPlayer : UIView<AVPDelegate>

//播放器对象~
@property(nonatomic,strong) AliPlayer * player;

//定义要暴露属性
@property(nonatomic,strong) NSString * source;
@property(nonatomic,assign) BOOL  setAutoPlay;
@property(nonatomic,assign) BOOL  setLoop;
@property(nonatomic,assign) BOOL  setMute;
@property(nonatomic,assign) BOOL  enableHardwareDecoder;
@property(nonatomic,assign) float  setVolume;
@property(nonatomic,assign) float  setSpeed;
@property(nonatomic,strong) NSString * setReferer;
@property(nonatomic,strong) NSString * setUserAgent;
@property(nonatomic,assign) int  setMirrorMode;
@property(nonatomic,assign) int  setRotateMode;
@property(nonatomic,assign) int  setScaleMode;
@property(nonatomic,strong) NSArray * configHeader;
@property(nonatomic,assign) int  selectBitrateIndex;
//缓存
@property(nonatomic, assign) BOOL setCache;

//定义要暴露的事件
@property (nonatomic, copy) RCTBubblingEventBlock onAliCompletion;
@property (nonatomic, copy) RCTBubblingEventBlock onAliError;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoadingBegin;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoadingProgress;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoadingEnd;
@property (nonatomic, copy) RCTBubblingEventBlock onAliPrepared;
@property (nonatomic, copy) RCTBubblingEventBlock onAliRenderingStart;
@property (nonatomic, copy) RCTBubblingEventBlock onAliSeekComplete;
@property (nonatomic, copy) RCTBubblingEventBlock onAliCurrentPositionUpdate;
@property (nonatomic, copy) RCTBubblingEventBlock onAliBufferedPositionUpdate;
@property (nonatomic, copy) RCTBubblingEventBlock onAliAutoPlayStart;
@property (nonatomic, copy) RCTBubblingEventBlock onAliLoopingStart;
@property (nonatomic, copy) RCTBubblingEventBlock onAliBitrateReady;
@property (nonatomic, copy) RCTBubblingEventBlock onAliBitrateChange;

-(void)startPlay;
-(void)pausePlay;
-(void)stopPlay;
-(void)reloadPlay;
-(void)restartPlay;
-(void)destroyPlay;
-(void)seekTo:(int) position;
/**
 * 播放本地视频
 * @param path 本地视频路径
 */
- (void)playLocalPath:(nonnull NSString *)path;

/**
 * 点播VidSts
 * @param  vid   视频ID（VideoId）
 * @param  accessKeyId 鉴权ID
 * @param  accessKeySecret 鉴权密钥
 * @param  securityToken 安全token
 * @param  region 接入地域
 */
- (void)playVidSts:(nonnull NSString *)vid
       accessKeyId:(nonnull NSString *)accessKeyId
   accessKeySecret:(nonnull NSString *)accessKeySecret
     securityToken:(nonnull NSString *)securityToken
            region:(nonnull NSString *)region;



/**
 *  是否是长度大于0的字符串
 *
 *  @param string 字符串
 *
 *  @return 返回结果
 */
+ (BOOL)bolString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
