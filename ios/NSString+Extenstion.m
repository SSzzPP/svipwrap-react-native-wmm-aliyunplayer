//
// Created by Jeverson Jee on 2023/1/11.
//

#import "NSString+Extenstion.h"

@implementation NSString (Extenstion)

- (NSString *)getNewerLocalPathWith:(NSSearchPathDirectory)type {
    NSRange sliceRange;
    NSMutableString *mutableString = @"".mutableCopy;
    if (self && [self containsString:@"/"]) {
        NSMutableArray *dirMuatableArray = [[self componentsSeparatedByString:@"/"] mutableCopy];
        NSString *tmpTypePath = NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES).firstObject;
        NSUInteger destinationObjIndex = [dirMuatableArray indexOfObject:tmpTypePath];
        if (destinationObjIndex) {
            NSUInteger tmpLeng = dirMuatableArray.count - destinationObjIndex;
            [mutableString appendString:tmpTypePath];
            sliceRange = NSMakeRange(destinationObjIndex, tmpLeng);
            @try {
                [dirMuatableArray removeObjectsInRange:sliceRange];
                [mutableString stringsByAppendingPaths:dirMuatableArray];
                return mutableString.copy;
            } @catch (NSException *exception) {
                return @"";
            }
        }
    }
    return mutableString;
}
@end