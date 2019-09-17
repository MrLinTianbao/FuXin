//
//  MJOCManager.h
//  JChat
//
//  Created by longma on 2019/7/26.
//  Copyright © 2019年 HXHG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MJOCManager : NSObject
//当前周周一到周日日期
+ (NSArray *)mj_currentWeekTimes;
+ (UIImage *)mj_firstFrameWithVideoURL:(NSURL *)url Size:(CGSize)size;
+ (UIImage*) mj_getVideoPreViewImage:(NSURL *)path;
+ (id)arrayOrDicWithObject:(id)origin;
@end

