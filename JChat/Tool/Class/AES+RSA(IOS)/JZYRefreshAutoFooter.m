//
//  JZYRefreshAutoFooter.m
//  LifeSharingProject
//
//  Created by JZY_DEV on 2018/3/30.
//  Copyright © 2018年 郑木田. All rights reserved.
//

#import "JZYRefreshAutoFooter.h"

@implementation JZYRefreshAutoFooter
- (void)prepare{
    [super prepare];
    
    //所有的自定义东西都放在这里
//    [self setTitle:GCLocalizedString(@"普通闲置状态") forState:MJRefreshStateIdle];
//    [self setTitle:GCLocalizedString(@"松开就可以进行刷新的状态") forState:MJRefreshStatePulling];
//    [self setTitle:GCLocalizedString(@"正在刷新中的状态") forState:MJRefreshStateRefreshing];
//    [self setTitle:GCLocalizedString(@"即将刷新的状态") forState:MJRefreshStateWillRefresh];
//    [self setTitle:GCLocalizedString(@"所有数据加载完毕，没有更多的数据了") forState:MJRefreshStateNoMoreData];
    
    
    self.automaticallyChangeAlpha = YES;
    
}




- (void)placeSubviews{
    [super placeSubviews];
    
    
}
@end
