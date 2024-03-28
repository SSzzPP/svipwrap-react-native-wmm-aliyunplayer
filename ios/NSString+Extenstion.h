//
// Created by Jeverson Jee on 2023/1/11.
//

#import <Foundation/Foundation.h>

@interface NSString (Extenstion)

/**
 * @brief 因为rn 那边存储的沙盒路径为全路径，build 之后会找不到app
 * @param type @link{NSSearchPathDirectory} 枚举
 * @return 路径
 */
- (NSString *)getNewerLocalPathWith:(NSSearchPathDirectory)type;
@end