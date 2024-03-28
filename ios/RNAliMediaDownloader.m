//
//  RNAliMediaDownloader.m
//  AliyunVideoClient_Entrance
//
//  Created by wsk on 2022/12/6.
//  Copyright © 2022 Aliyun. All rights reserved.
//

#import "RNAliMediaDownloader.h"
#import <AliyunMediaDownloader/AliyunMediaDownloader.h>
#import <React/RCTLog.h>
#import "AliMediaDownloader+vid.h"

NSString* const EK_downloaderOnPrepared             = @"downloaderOnPrepared";
NSString* const EK_downloaderOnError                = @"downloaderOnError";
NSString* const EK_downloaderOnDownloadingProgress  = @"downloaderOnDownloadingProgress";
NSString* const EK_downloaderOnProcessingProgress   = @"downloaderOnProcessingProgress";
NSString* const EK_downloaderOnCompletion           = @"downloaderOnCompletion";

@interface RNAliMediaDownloader ()
@property (nonatomic,strong)NSMutableDictionary<NSString*, AliMediaDownloader*> *preDownloaders;
@property (nonatomic,strong)NSMutableDictionary<NSString*, AliMediaDownloader*> *downloaders;
@end

@implementation RNAliMediaDownloader

RCT_EXPORT_MODULE(RNAliMediaDownloader)

/**
 @brief 初始化下载对象
 */
- (instancetype)init {
  if (self = [super init]) {
  }
  return self;
}

-(NSArray<NSString *> *)supportedEvents{
    return @[
      EK_downloaderOnPrepared,
      EK_downloaderOnError,
      EK_downloaderOnDownloadingProgress,
      EK_downloaderOnProcessingProgress,
      EK_downloaderOnCompletion
    ];
}

- (NSDictionary *)constantsToExport {
    return @{
        @"onPrepared": EK_downloaderOnPrepared,
        @"onError": EK_downloaderOnError,
        @"onProcessingProgress": EK_downloaderOnProcessingProgress,
        @"onDownloadingProgress": EK_downloaderOnDownloadingProgress,
        @"onCompletion": EK_downloaderOnCompletion
    };
}

- (NSString*)mapKey:(NSString*)vid trackIndex:(int)trackIndex {
  NSString *key = [NSString stringWithFormat:@"%@-%@", vid, @(trackIndex)];
  return key;
}

/**
 @brief 删除下载文件
 @param saveDir 文件保存路径
 @param vid     vid
 @param format  格式
 @param index   vid对应的下载索引
 */
RCT_EXPORT_METHOD(deleteFile:(NSString*)saveDir
                  vid:(NSString*)vid
                  format:(NSString*)format
                  index:(int)index
                  callback:(RCTResponseSenderBlock)callback) {
    RCTLogInfo(@"rn_media_downloader deleteFile vid = %@ trackIndex = %d", vid, index);

    int result = [AliMediaDownloader deleteFile:saveDir vid:vid format:format index:index];
    callback(@[[NSNumber numberWithInt:result]]);
    
    /// 如果是准备中、下载中删除
    NSString *key = [self mapKey:vid trackIndex:index];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    if (downloader) {
      RCTLogInfo(@"rn_media_downloader deleteFile downloaders");

      [downloader deleteFile];
      [downloader destroy];
      self.downloaders[key] = nil;
    }

    downloader = [self.preDownloaders objectForKey:vid];
    if (downloader) {
      RCTLogInfo(@"rn_media_downloader deleteFile preDownloaders");
      [downloader destroy];
      self.preDownloaders[vid] = nil;
    }
}

/**
 @brief 销毁下载对象
 */
RCT_EXPORT_METHOD(destroyWithVid:(NSString*)vid trackIndex:(int)trackIndex) {
    
  RCTLogInfo(@"rn_media_downloader destroyWithVid vid = %@ trackIndex = %d", vid, trackIndex);

  NSString *key = [self mapKey:vid trackIndex:trackIndex];
  
  AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
  if (downloader) {
    [downloader destroy];
    self.downloaders[key] = nil;
  }

  downloader = [self.preDownloaders objectForKey:vid];
  if (downloader) {
    [downloader destroy];
    self.preDownloaders[vid] = nil;
  }
}

/**
 @brief 使用AVPVidStsSource准备播放
 @param source vid sts的播放方式
 */
RCT_EXPORT_METHOD(prepareWithVid:(NSString*)vid
                  accessKeyId:(NSString *) accessKeyId
                  accessKeySecret:(NSString *) accessKeySecret
                  securityToken:(NSString *) securityToken
                  region:(NSString *) region) {
    RCTLogInfo(@"rn_media_downloader prepareWithVid vid = %@", vid);

    AVPVidStsSource *source = [[AVPVidStsSource alloc] initWithVid:vid
                                                      accessKeyId:accessKeyId
                                                  accessKeySecret:accessKeySecret
                                                    securityToken:securityToken
                                                            region:region];
  
    AliMediaDownloader * downloader = [[AliMediaDownloader alloc] init];
    downloader.mm_vid = vid;
    downloader.delegate = (id<AMDDelegate>)self;
    self.preDownloaders[downloader.mm_vid] = downloader;
    [downloader prepareWithVid:source];
}

/**
 @brief 鉴权过期，更新AVPVidStsSource信息，
 @param source vid sts的信息
 */
RCT_EXPORT_METHOD(updateWithVid:(NSString*)vid
                  trackIndex:(int) trackIndex
                  accessKeyId:(NSString *) accessKeyId
                  accessKeySecret:(NSString *) accessKeySecret
                  securityToken:(NSString *) securityToken
                  region:(NSString *) region) {
    RCTLogInfo(@"rn_media_downloader updateWithVid vid = %@ trackIndex = %d", vid, trackIndex);

    AVPVidStsSource *source = [[AVPVidStsSource alloc] initWithVid:vid
                                                      accessKeyId:accessKeyId
                                                  accessKeySecret:accessKeySecret
                                                    securityToken:securityToken
                                                            region:region];
    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    [downloader updateWithVid:source];
}

/**
 @brief 设置下载的保存路径
 @param dir 保存文件夹
 */
RCT_EXPORT_METHOD(setSaveDirectory:(NSString*)dir vid:(NSString*)vid trackIndex:(int)trackIndex) {
    RCTLogInfo(@"rn_media_downloader setSaveDirectory vid = %@ trackIndex = %d", vid, trackIndex);

    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    [downloader setSaveDirectory:dir];
}

/**
 @brief 开始下载
 */
RCT_EXPORT_METHOD(startWithVid:(NSString*)vid trackIndex:(int)trackIndex) {
    RCTLogInfo(@"rn_media_downloader startWithVid vid = %@ trackIndex = %d", vid, trackIndex);

    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    [downloader start];
}

/**
 @brief 停止下载
 */
RCT_EXPORT_METHOD(stopWithVid:(NSString*)vid trackIndex:(int)trackIndex) {
    RCTLogInfo(@"rn_media_downloader stopWithVid vid = %@ trackIndex = %d", vid, trackIndex);
    
    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    [downloader stop];
}

/**
 @brief 获取下载config
 */
RCT_EXPORT_METHOD(getConfigWithVid:(NSString*)vid trackIndex:(int)trackIndex callback:(RCTPromiseResolveBlock)callback) {
    RCTLogInfo(@"rn_media_downloader getConfigWithVid vid = %@ trackIndex = %d", vid, trackIndex);

    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    AVDConfig *config = [downloader getConfig];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"timeoutMs"] = @(config.timeoutMs);
    dic[@"connnectTimoutMs"] = @(config.connnectTimoutMs);
    dic[@"referer"] = config.referer;
    dic[@"userAgent"] = config.userAgent;
    dic[@"httpProxy"] = config.httpProxy;
    callback(dic);
}

/**
 @brief 设置下载config
 */
RCT_EXPORT_METHOD(setConfig:(int)timeoutMs
                  connnectTimoutMs:(int)connnectTimoutMs
                  referer:(NSString*)referer
                  userAgent:(NSString*)userAgent
                  httpProxy:(NSString*)httpProxy
                  vid:(NSString*)vid
                  trackIndex:(int)trackIndex
) {
    RCTLogInfo(@"rn_media_downloader setConfig vid = %@ trackIndex = %d", vid, trackIndex);

    AVDConfig *config = [[AVDConfig alloc] init];
    config.timeoutMs = timeoutMs;
    config.connnectTimoutMs = connnectTimoutMs;
    config.referer = referer;
    config.userAgent = userAgent;
    config.httpProxy = httpProxy;
  
    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    AliMediaDownloader *downloader = [self.downloaders objectForKey:key];
    [downloader setConfig:config];
}

/**
 @brief 设置下载的trackIndex
 @param trackIndex 从prepare回调中可以获取所有index
 */
RCT_EXPORT_METHOD(selectTrack:(int)trackIndex vid:(NSString*)vid) {
    RCTLogInfo(@"rn_media_downloader selectTrack vid = %@ trackIndex = %d", vid, trackIndex);

    AliMediaDownloader *downloader = self.preDownloaders[vid];

    downloader.mm_trackIndex = @(trackIndex).stringValue;
    [downloader selectTrack:trackIndex];
  
    NSString *key = [self mapKey:vid trackIndex:trackIndex];
    self.downloaders[key] = downloader;
  
    self.preDownloaders[vid] = nil;
}

/**
 @brief 获取SDK版本号信息
 */
RCT_EXPORT_METHOD(getSDKVersion:(RCTPromiseResolveBlock)callback) {
    RCTLogInfo(@"rn_media_downloader getSDKVersion");

    NSString *version = [AliMediaDownloader getSDKVersion];
    callback(version);
}

- (NSMutableDictionary<NSString*,AliMediaDownloader*> *)downloaders {
  if(!_downloaders) {
    _downloaders = [[NSMutableDictionary<NSString*,AliMediaDownloader*> alloc] init];
  }
  return _downloaders;
}

- (NSMutableDictionary<NSString*,AliMediaDownloader*> *)preDownloaders {
  if(!_preDownloaders) {
    _preDownloaders = [[NSMutableDictionary<NSString*,AliMediaDownloader*> alloc] init];
  }
  return _preDownloaders;
}
@end

#pragma mark - <AMDDelegate>
@interface RNAliMediaDownloader (AMDDelegate)<AMDDelegate>
@end
@implementation RNAliMediaDownloader (AMDDelegate)
/**
 @brief 下载准备完成事件回调
 @param downloader 下载downloader指针
 @param info 下载准备完成回调，@see AVPMediaInfo
 */
-(void)onPrepared:(AliMediaDownloader*)downloader mediaInfo:(AVPMediaInfo*)info {
  RCTLogInfo(@"rn_media_downloader onPrepared vid = %@", downloader.mm_vid);

  NSMutableArray *tracks = [NSMutableArray array];
  
  [info.tracks enumerateObjectsUsingBlock:^(AVPTrackInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSMutableDictionary *track = [NSMutableDictionary dictionary];
    track[@"trackIndex"] = @(obj.trackIndex);
    track[@"trackDefinition"] = obj.trackDefinition;
    track[@"vodFormat"] = obj.vodFormat;
    track[@"vodFileSize"] = @(obj.vodFileSize);
    [tracks addObject:track];
  }];
  
  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  body[@"vid"] = downloader.mm_vid;
  body[@"tracks"] = tracks;
  [self sendEventWithName:EK_downloaderOnPrepared body:body];
}

/**
 @brief 错误代理回调
 @param downloader 下载downloader指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliMediaDownloader*)downloader errorModel:(AVPErrorModel *)errorModel {
  RCTLogInfo(@"rn_media_downloader onError vid = %@ code = %@", downloader.mm_vid, @(errorModel.code));

  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  body[@"vid"] = downloader.mm_vid;
  body[@"trackIndex"] = downloader.mm_trackIndex;
  body[@"code"] = @(errorModel.code);
  body[@"message"] = errorModel.message;
  [self sendEventWithName:EK_downloaderOnError body:body];
}

/**
 @brief 下载进度回调
 @param downloader 下载downloader指针
 @param percent 下载进度 0-100
 */
- (void)onDownloadingProgress:(AliMediaDownloader*)downloader percentage:(int)percent {
  RCTLogInfo(@"rn_media_downloader onDownloadingProgress vid = %@-%@ percent = %d", downloader.mm_vid, downloader.mm_trackIndex, percent);

  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  body[@"vid"] = downloader.mm_vid;
  body[@"trackIndex"] = downloader.mm_trackIndex;
  body[@"percent"] = @(percent);
  [self sendEventWithName:EK_downloaderOnDownloadingProgress body:body];
}

/**
 @brief 下载文件的处理进度回调
 @param downloader 下载downloader指针
 @param percent 下载进度 0-100
 */
- (void)onProcessingProgress:(AliMediaDownloader*)downloader percentage:(int)percent {
  RCTLogInfo(@"rn_media_downloader onProcessingProgress vid = %@-%@ percent = %d", downloader.mm_vid, downloader.mm_trackIndex, percent);

  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  body[@"vid"] = downloader.mm_vid;
  body[@"trackIndex"] = downloader.mm_trackIndex;
  body[@"percent"] = @(percent);
  [self sendEventWithName:EK_downloaderOnProcessingProgress body:body];
}

/**
 @brief 下载完成回调
 @param downloader 下载downloader指针
 */
- (void)onCompletion:(AliMediaDownloader*)downloader {
  RCTLogInfo(@"rn_media_downloader onCompletion vid = %@-%@-%@", downloader.mm_vid, downloader.mm_trackIndex, downloader.downloadedFilePath);

  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  body[@"vid"] = downloader.mm_vid;
  body[@"trackIndex"] = downloader.mm_trackIndex;
  body[@"filePath"] = [downloader downloadedFilePath];
  [self sendEventWithName:EK_downloaderOnCompletion body:body];
}
@end
