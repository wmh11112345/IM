//
//  ChartViewController.m
//  PresentLayer
//
//  Created by tiger on 16/8/11.
//  Copyright © 2016年 buystreet. All rights reserved.
//

#import "ChartViewController.h"
#import "ChartCell.h"

@interface ChartViewController ()

@end

@implementation ChartViewController


- (void)viewDidLoad
{
      [super viewDidLoad];
      // Do any additional setup after loading the view, typically from a nib.
      
      //获取数据
      
}

- (void)didReceiveMemoryWarning
{
      [super didReceiveMemoryWarning];
      // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
      return [self.events count] / 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
      return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
      //    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
      //    NSDictionary *event = [self.events objectAtIndex:(indexPath.section*2 + indexPath.row)];
      //    cell.label.text = [event objectForKey:@"name"];
      //    cell.imageView.image = [UIImage imageNamed:[event objectForKey:@"image"]];
      ChartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
      NSDictionary *event = [self.events objectAtIndex:(indexPath.section*2+indexPath.row)];
      cell.messege.text = [event objectForKey:@"name"];
     cell.userPhoto.image = [UIImage imageNamed:[event objectForKey:@"image"]];
      
      return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
      NSDictionary *event = [self.events objectAtIndex:(indexPath.section*2 + indexPath.row)];
      NSLog(@"select event name : %@", [event objectForKey:@"name"]);
      
}


@end
