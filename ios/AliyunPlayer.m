//
//  AliyunPlayer.m
//  RNAliPlayer
//
//  Created by zlk on 2021/8/17.
//

#import "AliyunPlayer.h"
#import "NSString+Extenstion.h"
#import <React/RCTLog.h>

/** 检测字符串长度是都大于0 */
#define MMValidString(s) [AliyunPlayer bolString:s]

@implementation AliyunPlayer

- (AliPlayer *)player{
  if (!_player) {
    _player = [[AliPlayer alloc] init];
    _player.delegate = self;
    _player.playerView = self;
  }
  return _player;
}

-(void)startPlay{
    /** 去掉 self.source==nil 的判断, 和安卓逻辑同步  */
//  if (self.source==nil) {
//    return;
//  }
  [self.player start];
}
-(void)pausePlay{
  [self.player pause];
}
-(void)stopPlay{
  [self.player stop];
}
-(void)reloadPlay{
  [self.player reload];
}
-(void)restartPlay{
  [self.player seekToTime:0 seekMode:AVP_SEEKMODE_INACCURATE];
  [self.player start];
}
-(void)destroyPlay{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.player destroy];
    self.player = nil;
  });
}
- (void)seekTo:(int)position{
  [self.player seekToTime:position*1000 seekMode:AVP_SEEKMODE_INACCURATE];
}

/**
 * 播放本地视频
 * @param path 本地视频路径
 */
- (void)playLocalPath:(nonnull NSString *)path {
    RCTLogInfo(@"rn_media_player playLocalPath = %@", path);
    if (MMValidString(path)) {
        NSString *newerPath = [path getNewerLocalPathWith:NSDocumentDirectory];
        AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:newerPath];
        [self.player setUrlSource:urlSource];
        [self.player prepare];
        [self.player start];
    } else {
        RCTLogError(@"rn_media_player playLocalPath = %@", path);
    }
}

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
            region:(nonnull NSString *)region {

    RCTLogInfo(@"rn_media_player vid playVidSts %@ %@ %@ %@ %@", vid, accessKeyId, accessKeySecret, securityToken, region);
    
    
    if (!MMValidString(vid)) {
        RCTLogInfo(@"rn_media_player vid is empty");
        return;
    }
    
    if (!MMValidString(accessKeyId)) {
        RCTLogInfo(@"rn_media_player accessKeyId is empty");
        return;
    }
    
    if (!MMValidString(accessKeySecret)) {
        RCTLogInfo(@"rn_media_player accessKeySecret is empty");
        return;
    }
    
    if (!MMValidString(securityToken)) {
        RCTLogInfo(@"rn_media_player securityToken is empty");
        return;
    }
    
    if (!MMValidString(region)) {
        RCTLogInfo(@"rn_media_player region is empty");
        return;
    }
    
    AVPVidStsSource *source = [[AVPVidStsSource alloc] init];
    source.region           = region;          // 接入地域
    source.vid              = vid;             // 视频ID（VideoId）
    source.securityToken    = securityToken;   // 安全token
    source.accessKeySecret  = accessKeySecret; // 鉴权密钥
    source.accessKeyId      = accessKeyId;     // 鉴权ID
    [self.player setStsSource:source];         // 设置播放源
    [self.player prepare];
}

//定义要暴露属性
- (void)setSource:(NSString *)source{
  _source = source;
  if ([source containsString:@"http"]) {
    AVPUrlSource * urlSource = [[AVPUrlSource alloc] urlWithString:[source stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self.player setUrlSource:urlSource];
    [self.player prepare];
    return;
  }
  [self setAuthSource: source];
}
- (void)setAuthSource:(NSString *)authSource {
    if (authSource == nil) {
        RCTLogInfo(@"rn_media_player authSouce json string is empty");
        return;
    }
    NSData *authoSourceData = [authSource dataUsingEncoding:NSUTF8StringEncoding];
    NSError *transferError;
    NSDictionary *authSourceDic = [NSJSONSerialization JSONObjectWithData:authoSourceData options:NSJSONReadingMutableContainers error:&transferError];
    if (transferError) {
        RCTLogInfo(@"rn_media_player the authoSource transform json failured %@", authSource);
        return;
    }
    if (![authSourceDic.allKeys containsObject:@"Vid"] || ![authSourceDic.allKeys containsObject:@"PlayAuth"]) {
        RCTLogInfo(@"rn_media_player please check ur jsonString, as it doesnt contain vid or palyAuth");
        return;
    }
    NSString *vid = authSourceDic[@"Vid"];
    NSString *playAuth = authSourceDic[@"PlayAuth"];
    NSString *region = authSourceDic[@"Region"];
    if (vid == nil) {
        RCTLogInfo(@"rn_media_player authSource vid value is null");
        return;
    }
    if (playAuth == nil) {
        RCTLogInfo(@"rn_media_player authSource playAuth value is null");
        return;
    }
    if (region == nil) {
        RCTLogInfo(@"rn_media_player the region is null we use the cn-shanghai as default value");
        region = @"cn-shanghai";
    }
    AVPVidAuthSource *authSourceEntity = [[AVPVidAuthSource alloc] init];
    authSourceEntity.vid = vid;
    authSourceEntity.playAuth = playAuth; // 播放凭证
    authSourceEntity.region = region; // 点播服务的接入地域，默认为cn-shanghai
    [self.player setAuthSource:authSourceEntity];
    [self.player prepare];

}
- (void)setSetCache:(BOOL)setCache {
    _setCache = setCache;
    RCTLogInfo(@"rn_media_player need todo");
}
-(void)setSetAutoPlay:(BOOL)setAutoPlay{
  _setAutoPlay = setAutoPlay;
  [self.player setAutoPlay:setAutoPlay];
}
-(void)setSetLoop:(BOOL)setLoop{
  _setLoop = setLoop;
  [self.player setLoop:setLoop];
}
- (void)setSetMute:(BOOL)setMute{
  _setMute = setMute;
  [self.player setMuted:setMute];
}
- (void)setEnableHardwareDecoder:(BOOL)enableHardwareDecoder{
  _enableHardwareDecoder = enableHardwareDecoder;
  [self.player setEnableHardwareDecoder:enableHardwareDecoder];
}
- (void)setSetVolume:(float)setVolume{
  _setVolume = setVolume;
  [self.player setVolume:setVolume];
}
- (void)setSetSpeed:(float)setSpeed{
  _setSpeed = setSpeed;
  [self.player setRate:setSpeed];
}
- (void)setSetReferer:(NSString *)setReferer{
  _setReferer = setReferer;
  AVPConfig *config = [self.player getConfig];
  config.referer = setReferer;
  [self.player setConfig:config];
}
- (void)setSetUserAgent:(NSString *)setUserAgent{
  _setUserAgent = setUserAgent;
  AVPConfig *config = [self.player getConfig];
  config.userAgent = setUserAgent;
  [self.player setConfig:config];
}
- (void)setSetMirrorMode:(int)setMirrorMode{
  _setMirrorMode = setMirrorMode;
  switch (setMirrorMode) {
    case 0:
      [self.player setMirrorMode:AVP_MIRRORMODE_NONE];
      break;
    case 1:
      [self.player setMirrorMode:AVP_MIRRORMODE_HORIZONTAL];
      break;
    case 2:
      [self.player setMirrorMode:AVP_MIRRORMODE_VERTICAL];
      break;
    default:
      break;
  }
}
-(void)setSetRotateMode:(int)setRotateMode{
  _setRotateMode = setRotateMode;
  switch (setRotateMode) {
    case 0:
      [self.player setRotateMode:AVP_ROTATE_0];
      break;
    case 1:
      [self.player setRotateMode:AVP_ROTATE_90];
      break;
    case 2:
      [self.player setRotateMode:AVP_ROTATE_180];
      break;
    case 3:
      [self.player setRotateMode:AVP_ROTATE_270];
      break;
    default:
      break;
  }
}
- (void)setSetScaleMode:(int)setScaleMode{
  _setScaleMode = setScaleMode;
  switch (setScaleMode) {
    case 0:
      [self.player setScalingMode:AVP_SCALINGMODE_SCALEASPECTFIT];
      break;
    case 1:
      [self.player setScalingMode:AVP_SCALINGMODE_SCALEASPECTFILL];
      break;
    case 2:
      [self.player setScalingMode:AVP_SCALINGMODE_SCALETOFILL];
      break;
    default:
      break;
  }
}

- (void)setConfigHeader:(NSArray *)configHeader{
    _configHeader = configHeader;
    //先获取配置
    AVPConfig *config = [self.player getConfig];
    //定义header
    NSMutableArray *httpHeaders = [NSMutableArray arrayWithArray:configHeader];
    //设置header
    config.httpHeaders = httpHeaders;
    //设置配置给播放器
    [self.player setConfig:config];
}

- (void)setSelectBitrateIndex:(int)selectBitrateIndex{
    _selectBitrateIndex = selectBitrateIndex;
    if (selectBitrateIndex==-1) {
        [self.player selectTrack:SELECT_AVPTRACK_TYPE_VIDEO_AUTO];
    }
    else{
        [self.player selectTrack:selectBitrateIndex];
    }

}

#pragma mark - AVPDelegate
/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
  //提示错误，及stop播放
  self.onAliError(@{@"code":@(errorModel.code),@"message":errorModel.message});
  RCTLogError(@"rn_media_player onError code = %@ ()", @(errorModel.code), errorModel.message);
}
/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    AVPMediaInfo *mode = [player getMediaInfo];
    int width = 0;
    int height = 0;
    if (mode != nil && mode.tracks != nil && mode.tracks.count > 0) {
        width = mode.tracks[0].videoWidth;
        height = mode.tracks[0].videoHeight;
    }
  switch (eventType) {
    case AVPEventPrepareDone:
      // 准备完成
      if (self.onAliPrepared) {
         self.onAliPrepared(@{@"duration":@(player.duration/1000), @"width": @(width), @"height": @(height)});
      }
//      [_player setThumbnailUrl:@"https://p.qqan.com/up/2021-8/16292685053812604.jpg"];
      break;
    case AVPEventAutoPlayStart:
      // 自动播放开始事件
      if (self.onAliAutoPlayStart) {
         self.onAliAutoPlayStart(@{@"code":@"onAliAutoPlayStart", @"duration":@(mode.duration/1000), @"width": @(width), @"height": @(height)});
      }
      break;
    case AVPEventFirstRenderedStart:

      // 首帧显示
      if (self.onAliRenderingStart) {
        self.onAliRenderingStart(@{@"code":@"onRenderingStart", @"duration":@(mode.duration/1000), @"width": @(width), @"height": @(height)});
      }
      break;
    case AVPEventCompletion:
      // 播放完成
      if (self.onAliCompletion) {
        self.onAliCompletion(@{@"code":@"onAliCompletion", @"duration":@(mode.duration/1000), @"width": @(width), @"height": @(height)});
      }
      break;
    case AVPEventLoadingStart:
      // 缓冲开始
      if (self.onAliLoadingBegin) {

          self.onAliLoadingBegin(@{@"code":@"onAliLoadingBegin", @"duration":@(mode.duration/1000), @"width": @(width), @"height": @(height)});
      }
      break;
    case AVPEventLoadingEnd:
      // 缓冲完成
      if (self.onAliLoadingEnd) {
        self.onAliLoadingEnd(@{@"code":@"onAliLoadingEnd", @"duration":@(mode.duration/1000), @"width": @(width), @"height": @(height)});
      }
      break;
    case AVPEventSeekEnd:
      // 跳转完成
      if (self.onAliSeekComplete) {
        self.onAliSeekComplete(@{@"code":@"onAliSeekComplete"});
      }
      break;
    case AVPEventLoopingStart:
      // 循环播放开始
      if (self.onAliLoopingStart) {
        self.onAliLoopingStart(@{@"code":@"onAliLoopingStart"});
      }
      break;
    default:
      break;
  }
}
/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 后台播放获取播放进度
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gugongVideoNotifi" object:nil userInfo:@{@"positon":@(position), @"duration":@(player.duration)} ];
  if (self.onAliCurrentPositionUpdate) {
     self.onAliCurrentPositionUpdate(@{@"position":@(position/1000)});
  }
}
/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {

  if (self.onAliBufferedPositionUpdate) {
    self.onAliBufferedPositionUpdate(@{@"position":@(position/1000)});
  }
}

/**
 @brief 视频缓冲进度回调
 @param player 播放器player指针
 @param progress 缓存进度0-100
 */
/****
 @brief Buffer progress callback.
 @param player Player pointer.
 @param progress Buffer progress: from 0 to 100.
 */
- (void)onLoadingProgress:(AliPlayer*)player progress:(float)progress{
  if (self.onAliLoadingProgress) {
    self.onAliLoadingProgress(@{@"percent":@(progress)});
  }
}


/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组 参考AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    if (self.onAliBitrateReady) {
        NSMutableArray * trackArray = [NSMutableArray array];
        for (NSInteger i=0; i<info.count; i++) {
            AVPTrackInfo * track = info[i];
            if (track.trackBitrate>0) {
                [trackArray addObject:@{@"index":@(track.trackIndex),
                                        @"width":@(track.videoWidth),
                                        @"height":@(track.videoHeight),
                                        @"bitrate":@(track.trackBitrate)
                }];
            }

        }

        self.onAliBitrateReady(@{@"bitrates":trackArray});
    }
}

/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息 参考AVPTrackInfo
 @see AVPTrackInfo
 */
/****
 @brief Track switchover completion callback.
 @param player Player pointer.
 @param info Track switchover completion information. See AVPTrackInfo.
 @see AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info{
    if (self.onAliBitrateChange) {
        self.onAliBitrateChange(@{@"index":@(info.trackIndex),
                                  @"width":@(info.videoWidth),
                                  @"height":@(info.videoHeight)
                                });
    }
}


#pragma mark -  检测字符串长度是否大于0
+ (BOOL)bolNull:(NSObject *)object {
    BOOL result = NO;
    if ((object == [NSNull null]) || object == nil) {
        result = YES;
    }
    return result;
}

+ (BOOL)bolString:(NSString *)string {
    BOOL result = ![AliyunPlayer bolNull:string];
    if (result) {
        if ([string isKindOfClass:[NSString class]]) {
            result = string.length;
        } else {
            result = NO;
        }
    }
    return result;
}

@end

