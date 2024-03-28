//
//  AliMediaDownloader+vid.m
//  rnTemplate
//
//  Created by wsk on 2022/12/7.
//

#import "AliMediaDownloader+vid.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation AliMediaDownloader (vid)
- (void)setMm_vid:(NSString *)mm_vid {
  objc_setAssociatedObject(self, @selector(mm_vid), mm_vid, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)mm_vid {
  return objc_getAssociatedObject(self, @selector(mm_vid));
}

- (void)setMm_trackIndex:(NSString *)mm_trackIndex {
  objc_setAssociatedObject(self, @selector(mm_trackIndex), mm_trackIndex, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)mm_trackIndex {
  return objc_getAssociatedObject(self, @selector(mm_trackIndex));
}
@end
