//
//  BaseTableView.h
//  ewee
//
//  Created by 莫景涛 on 14-5-29.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@protocol RefreshProptor <NSObject>

- (void)refreshFethNetData:(MJRefreshBaseView *)refreshView ;

@end

@interface BaseTableView : UITableView
{
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}
@property(nonatomic , assign)BOOL isNeedPullRefresh ;            //是否需要开启下拉刷新默认为no
@property(nonatomic , assign)BOOL isNeedPullDownRefresh ;   //是否需要开启上拉刷新默认为no
@property(nonatomic , assign)BOOL isComeInRefresh ;               //是否一进来就刷新

@property(nonatomic , assign)id<RefreshProptor>dele ;

@end
