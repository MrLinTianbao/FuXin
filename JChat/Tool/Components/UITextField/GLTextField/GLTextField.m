//
//  GlTextField.m
//  PayPasswordDemo
//
//  Created by 高磊 on 2017/1/24.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "GLTextField.h"

@implementation GLTextField

//禁止粘贴复制全选等 控制 UIMenuItem 的显示和隐藏：
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
