//
//  ListViewController.m
//  Networking
//
//  Created by 隐风 on 14-8-7.
//  Copyright (c) 2014年 隐风. All rights reserved.
//

#import "ListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebViewController.h"

@interface ListViewController () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection* connection;

@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, strong) NSArray* items;

@end

@implementation ListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURL* url = [NSURL URLWithString:@"http://h5.waptest.taobao.com/json/wv/items.json"];
    
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Connection data delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseData:self.data];
}

#pragma mark - Private method

- (void)parseData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary* responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    self.items = [responseDic objectForKey:@"items"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSDictionary* item = [self.items objectAtIndex:indexPath.row];
    NSString* name = [item objectForKey:@"name"];
    NSString* price = [item objectForKey:@"price"];
    NSString* url = [item objectForKey:@"img"];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = price;
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WebViewController* web = [[WebViewController alloc] init];
    
    NSDictionary* item = [self.items objectAtIndex:indexPath.row];
    NSString* url = [item objectForKey:@"url"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [web.webView loadRequest:request];
    
    [self.navigationController pushViewController:web animated:YES];
}

@end
