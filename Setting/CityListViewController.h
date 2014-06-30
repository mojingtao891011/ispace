//
//  CityListViewController.h
//  CityList
//
//  Created by Chen Yaoqiang on 14-3-6.
//
//

#import "BaseViewController.h"

@interface CityListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate , UISearchBarDelegate >

@property (nonatomic, strong) NSMutableDictionary *cities;

@property (nonatomic, strong) NSMutableArray *keys; //城市首字母
@property (nonatomic, strong) NSMutableArray *arrayCitys;   //城市数据
//@property (nonatomic, strong) NSMutableArray *arrayHotCity;
@property (nonatomic , retain) NSMutableArray *searchArr ;
@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic , assign)NSInteger selectedRow ;
@property(nonatomic , assign)NSInteger selectedSection ;
@property(nonatomic , assign)BOOL isSelected ;
@end
