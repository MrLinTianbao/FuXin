//
//  ChatFaceHeleper.h
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChatFaceHeleper : NSObject

@property (nonatomic, strong) NSMutableArray *faceGroupArray;

+ (ChatFaceHeleper *) sharedFaceHelper;

- (NSArray *) getFaceArrayByGroupID:(NSString *)groupID;

+ (NSAttributedString *) formatMessageString:(NSString *)text;

@end
