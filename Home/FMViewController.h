//
//  FMViewController.h
//  iSpace
//
//  Created by bear on 14-5-26.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface FMViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , RefreshProptor>
{
    UIButton *selectedButton ;
}
@property(nonatomic , retain)NSMutableArray *fmArr ;

@property (weak, nonatomic) IBOutlet BaseTableView *fmTableView;
@property(nonatomic , retain)MJRefreshBaseView *refreshView;

@end
