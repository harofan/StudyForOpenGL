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
#import "MixedFragmentViewController.h"
#import "MultipleTexturesViewController.h"
#import "CustomTexturesViewController.h"
#import "SimpleLightViewController.h"
#import "EarthSphereViewController.h"


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
            MixedFragmentViewController *vc = [[MixedFragmentViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            case 4:
        {
            MultipleTexturesViewController *vc = [[MultipleTexturesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            case 5:
        {
            CustomTexturesViewController *vc = [[CustomTexturesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            case 6:
        {
            SimpleLightViewController *vc = [[SimpleLightViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            case 7:
        {
            EarthSphereViewController *vc = [[EarthSphereViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
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
        _dataArray = @[@"简单三角形的渲染", @"自定义一个glview", @"渲染一个简单的纹理", @"混合片元", @"多重纹理", @"自定义纹理", @"简单灯光", @"地球渲染"];
    }
    return _dataArray;
}

@end
