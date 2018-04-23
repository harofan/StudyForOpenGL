//
//  ViewController.m
//  OpegGLDemo
//
//  Created by 范杨 on 2018/4/17.
//  Copyright © 2018年 RPGLiker. All rights reserved.


#import "ViewController.h"
#import "SimpleTriangleViewController.h"
#import "AGLKViewViewController.h"
#import "SimpleTextureViewController.h"
#import "MultipleTexturesViewController.h"


#define ScreenWidth         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight        [[UIScreen mainScreen] bounds].size.height
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (copy, nonatomic) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}
#pragma mark - UI
- (void)initView{
    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:tableview];
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableview"];
    tableview.delegate = self;
    tableview.dataSource = self;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            SimpleTriangleViewController *vc = [[SimpleTriangleViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 1:
        {
            AGLKViewViewController *vc = [[AGLKViewViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 2:
        {
            SimpleTextureViewController *vc = [[SimpleTextureViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 3:
        {
            MultipleTexturesViewController *vc = [[MultipleTexturesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
        default:
            break;
    }
}

#pragma mark - data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableview" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - set && get
- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[@"简单三角形的渲染", @"自定义一个glview", @"渲染一个简单的纹理", @"渲染一个多重混合纹理"];
    }
    return _dataArray;
}

@end
