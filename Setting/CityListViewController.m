//
//  CityListViewController.m
//  CityList
//
//  Created by Chen Yaoqiang on 14-3-6.
//
//

#import "CityListViewController.h"

@interface CityListViewController ()

@end

@implementation CityListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel.text = @"城市" ;
        [self.titleLabel sizeToFit];
        // Custom initialization
//        self.arrayHotCity = [NSMutableArray arrayWithObjects:@"广州市",@"北京市",@"天津市",@"西安市",@"重庆市",@"沈阳市",@"青岛市",@"济南市",@"深圳市",@"长沙市",@"无锡市", nil];
        self.keys = [NSMutableArray array];
        self.arrayCitys = [NSMutableArray array];
        self.searchArr = [[NSMutableArray alloc]initWithCapacity:10];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getCityData];
    
	// Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    UISearchBar * searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, ScreenWidth, 0);
    searchBar.delegate = self;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    //searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"请输入";
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.translucent = YES;
    searchBar.barStyle = UIBarStyleDefault;
    //searchBar.tintColor = [UIColor redColor];
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar;
    
    //    for(id cc in [searchBar subviews]){
//        NSLog(@"%@" , cc);
//        if([cc isKindOfClass:[UIButton class]]){
//            UIButton *btn = (UIButton *)cc;
//            [btn setTitle:@"取消"  forState:UIControlStateNormal];
//        }
//    }
   
}

#pragma mark - 获取城市数据
-(void)getCityData
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict"
                                                   ofType:@"plist"];
    self.cities = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    //初始化keys数组并按字母排列
    [self.keys addObjectsFromArray:[[self.cities allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
//    //添加热门城市
//    NSString *strHot = @"热";
//    [self.keys insertObject:strHot atIndex:0];
//    [self.cities setObject:_arrayHotCity forKey:strHot];
}

#pragma mark - tableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 250, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    
    NSString *key = [_keys objectAtIndex:section];
    if ([key rangeOfString:@"热"].location != NSNotFound) {
        titleLabel.text = @"热门城市";
    }
    else
        titleLabel.text = key;
    
    [bgView addSubview:titleLabel];
    
    return bgView;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return _keys;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *key = [_keys objectAtIndex:section];
    NSArray *citySection = [_cities objectForKey:key];
    return [citySection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSString *key = [_keys objectAtIndex:indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"CityTableViewCell" owner:self options:nil][0];
    }
    UILabel *cityNameLabel = (UILabel*)[cell.contentView viewWithTag:10];
    cityNameLabel.text = _cities[key][indexPath.row];
    
    UIImageView *redioImgView = (UIImageView*)[cell.contentView viewWithTag:11];
    if (indexPath.section == _selectedSection && indexPath.row == _selectedRow &&_isSelected) {
        redioImgView.image = [UIImage imageNamed:@"bt_radio_pressed"];
    }else{
         redioImgView.image = [UIImage imageNamed:@"bt_radio_normal"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_keys objectAtIndex:indexPath.section];
    _selectedSection = indexPath.section , _selectedRow = indexPath.row , _isSelected = YES ;
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"selectedCityNote" object:_cities[key][indexPath.row] ];
    NSLog(@"%@" , _cities[key][indexPath.row]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)selectedCity:(UIButton*)sender
{
    sender.selected = !sender.selected ;
}
#pragma mark-----UISearchBarDelegate
#pragma mark-----取消按钮被点击的时候
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil ;
    [self getCityData];
    [_tableView reloadData];
    [searchBar resignFirstResponder];
    
}
#pragma mark-----搜索按钮被点击的时候
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self getCityData];
    
    [_searchArr removeAllObjects];
    
    for (NSString *cityKey in [_cities allKeys]) {
        
        for (NSString *cityName in _cities[cityKey]) {
            
            NSRange foundObj=[cityName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(foundObj.length>0) {
                [_searchArr addObject:cityName];
                
            }
        }
    }
    [_cities removeAllObjects];
    [_keys removeAllObjects];
    [_cities setObject:_searchArr forKey:@"搜索结果"];
    [_keys addObject:@"搜索结果"] ;
    [_tableView reloadData];
    
     [searchBar resignFirstResponder];
}
#pragma mark-----搜索内容改变的时候，在这个方法里面实现实时显示结果
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        [_tableView reloadData];
        return ;
    }
    [self getCityData];
    
    [_searchArr removeAllObjects];
    
    for (NSString *cityKey in [_cities allKeys]) {
        
        for (NSString *cityName in _cities[cityKey]) {
            
            NSRange foundObj=[cityName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(foundObj.length>0) {
                
                [_searchArr addObject:cityName];
                
            }
        }
    }
    [_cities removeAllObjects];
    [_keys removeAllObjects];
    
    [_cities setObject:_searchArr forKey:@"搜索结果"];
    [_keys addObject:@"搜索结果"] ;
   
    [_tableView reloadData];
    
}
@end
