//
//  EmptyView.m
//  FactoryHelper
//
//  Created by myios on 2017/7/21.
//  Copyright © 2017年 郑惠珠. All rights reserved.
//

#import "EmptyView.h"

#define ViewBGColor [UIColor whiteColor]
#define TitleFontSize 15
#define TitleColor [UIColor grayColor]
/* 屏幕尺寸 */
#define Screen_Height [[UIScreen mainScreen] bounds].size.height
#define Screen_Width [[UIScreen mainScreen] bounds].size.width

/* 设计图与屏幕尺寸比值 */
#define Screen_Ratio_x(x) (x * (Screen_Width/750.0f))

#define CustomFontSize(x) [UIFont systemFontOfSize:Screen_Ratio_x(x)]
#define CustomColorWithHex(x) [UIColor colorWithHex:x]

@implementation EmptyView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
//        [MBProgressHUD showLoadToView:nil];
//        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
// 显示空白页面  文本提示
+ (void)showEmptyViewWithImage:(UIImage *)showImage withText:(NSString *)str withView:(UIView *)view{
    
    EmptyView *emptyView = [[EmptyView alloc] initWithFrame:view.bounds];
    //emptyView.backgroundColor = ViewBGColor;
    [view addSubview:emptyView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:showImage];
    imageView.frame = CGRectMake(view.frame.size.width/2-emptyView.frame.size.width * 22/75/2, view.frame.size.height/3, emptyView.frame.size.width * 22/75, emptyView.frame.size.width * 22/75);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [emptyView addSubview:imageView];
    
        
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+ imageView.frame.origin.y + Screen_Ratio_x(40), emptyView.frame.size.width, Screen_Ratio_x(90))];
    textLabel.text = str;
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = CustomFontSize(30);
    textLabel.textAlignment = NSTextAlignmentCenter;
    [emptyView addSubview:textLabel];
    
    
}
////
- (void)showEmptyViewWithImage:(UIImage *)showImage
                         Title:(NSString *)title
                         DetailTitle:(NSString *)detailTitle
                         buttonTitle:(NSString *)buttonTitle
                         withView:(UIView *)view
{
    
    //self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0  alpha:1];
    //图片
    UIImageView *imageView = [[UIImageView alloc] initWithImage:showImage];
    
    CGFloat imageView_W = self.frame.size.width * 15/50;
    
    imageView.frame = CGRectMake(view.frame.size.width/2 - imageView_W/2, view.frame.size.height/3.5, imageView_W, imageView_W);
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:imageView];
    
    //标题
    CGFloat title_w = self.frame.size.width/2;
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.frame = CGRectMake(view.frame.size.width/2 - title_w/2, imageView.frame.size.height+ imageView.frame.origin.y, title_w, 50);
    titleLable.font = [UIFont systemFontOfSize:TitleFontSize];
    titleLable.textColor = [UIColor blackColor];
    titleLable.numberOfLines = 2;
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = title;
    [self addSubview:titleLable];

    
    //按钮
    if(buttonTitle){
        CGFloat btnWidth = [EmptyView widthForString:buttonTitle fontSize:Screen_Ratio_x(30) andHeight:100]+Screen_Ratio_x(120);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(view.frame.size.width/2 - btnWidth/2, titleLable.frame.size.height+ titleLable.frame.origin.y + Screen_Ratio_x(40), btnWidth, Screen_Ratio_x(90));
        [button setTitle:buttonTitle forState:0];
        [button setTitleColor:[UIColor whiteColor] forState:0];
        [button addTarget:self action:@selector(buttonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = CustomFontSize(30);
        button.layer.borderColor = [UIColor redColor].CGColor;
        button.layer.borderWidth = 0.5;
        button.layer.cornerRadius = 2;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor yellowColor];
        [self addSubview:button];
    }
   

    [view addSubview:self];
}

// 移除空白页面
+ (void)hideEmptyView:(UIView *)supView {
    
    EmptyView *emptyView = [EmptyView emptyViewForView:supView];
    
    if (emptyView != nil) {
        [emptyView removeFromSuperview];
    }
}

- (void)buttonDidTouch: (UIButton *)sender {
    
    [self.delegate reloadData:sender];
}

+ (EmptyView *)emptyViewForView:(UIView *)supView {
    NSEnumerator *subViewsEnum = [supView.subviews reverseObjectEnumerator];
    for (UIView *subView in subViewsEnum) {
        if ([subView isKindOfClass:self]) {
            return (EmptyView *)subView;
        }
    }
    return nil;
}

// 获取字符串的宽度
+(float) widthForString:(NSString *)value fontSize:(float)fontSize andHeight:(float)height
{
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    //                        sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.width;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
