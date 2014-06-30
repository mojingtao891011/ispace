//
//  BaseTableView.m
//  ewee
//
//  Created by 莫景涛 on 14-5-29.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseTableView.h"
#import "MJRefresh.h"

@implementation BaseTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if (self.isNeedPullRefresh) {
            [self addHeader];
        }
        if (self.isNeedPullDownRefresh) {
            [self addFooter];
        }

    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.isNeedPullRefresh) {
         [self addHeader];
    }
    if (self.isNeedPullDownRefresh) {
        [self addFooter];
    }
    
}
- (void)addHeader
{
    
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
       // NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
       // NSLog(@"%@----刷新完毕", refreshView.class);
        
        // [[NSNotificationCenter defaultCenter]postNotificationName:@"www" object:refreshView];
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
               // NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
               // NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    if (self.isComeInRefresh) {
        [header beginRefreshing];//一进来就刷新
    }
    _header = header;
}
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    //[self reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    if (_dele && [_dele respondsToSelector:@selector(refreshFethNetData:)]) {
         [_dele refreshFethNetData:refreshView];
    }
}
- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];
        
       // NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
}

@end
