//
//  EnlargeImage.m
//  PresentLayer
//
//  Created by tiger on 16/8/23.
//  Copyright © 2016年 buystreet. All rights reserved.
//

#import "EnlargeImage.h"

@interface EnlargeImage ()


@end

@implementation EnlargeImage

- (void)viewDidLoad {
    [super viewDidLoad];
      _image.image = self.photo;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//当有一个或多个手指触摸事件在当前视图或window窗体中响应
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
      NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
      UITouch *touch = [allTouches anyObject];   //视图中的所有对象
      CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
      int x = point.x;
      int y = point.y;
     
      [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"touch (x, y) is (%d, %d)", x, y);}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
