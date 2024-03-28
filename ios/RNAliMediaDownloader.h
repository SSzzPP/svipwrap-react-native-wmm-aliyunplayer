//
//  RNAliMediaDownloader.h
//  AliyunVideoClient_Entrance
//
//  Created by wsk on 2022/12/6.
//  Copyright © 2022 Aliyun. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

extern NSString* const _Nullable EK_downloaderOnPrepared;
extern NSString* const _Nullable EK_downloaderOnError;
extern NSString* const _Nullable EK_downloaderOnDownloadingProgress;
extern NSString* const _Nullable EK_downloaderOnProcessingProgress;
extern NSString* const _Nullable EK_downloaderOnCompletion;

NS_ASSUME_NONNULL_BEGIN

@interface RNAliMediaDownloader : RCTEventEmitter<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
