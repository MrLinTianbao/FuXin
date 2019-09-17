//
//  EmptyView.h
//  FactoryHelper
//
//  Created by myios on 2017/7/21.
//  Copyright © 2017年 郑惠珠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    EMPTYVIEW_NO_DATA,
    EMPTYVIEW_NO_NET,
    
}EMPTYVIEWSTYLE;

@protocol EmptyViewDelegate <NSObject>

- (void)reloadData:(UIButton *)sender;

@end

@interface EmptyView : UIView
@property (nonatomic, assign) id<EmptyViewDelegate> delegate;
//@property (nonatomic, strong) EMPTYVIEWSTYLE emptyViewStyle;

// 显示空白页面
- (void)showEmptyViewWithImage:(UIImage *)showImage Title:(NSString *)title DetailTitle:(NSString *)detailTitle buttonTitle:(NSString *)buttonTitle withView:(UIView *)view;
// 显示空白页面
- (void)showEmptyViewWithImage:(UIImage *)showImage withText:(NSString *)str withView:(UIView *)view;
// 移除空白页面
+ (void)hideEmptyView:(UIView *)supView;
@end
