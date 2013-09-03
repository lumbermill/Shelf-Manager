//
//  ViewController.m
//  Shelf-Manager_Demo
//
//  Created by 國武　正督 on 2013/08/30.
//  Copyright (c) 2013年 Rz.inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *xLinesArray;
@property (strong, nonatomic) NSMutableArray *yLinesArray;

@end

@implementation ViewController

UITapGestureRecognizer *singleTap1;
UITapGestureRecognizer *singleTap2;
UITapGestureRecognizer *doubleTap1;
UITapGestureRecognizer *doubleTap2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    // ジェスチャーレコグナイザー生成
    // 1本指でシングルタップ
    singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap1:)];
    
    // 2本指でシングルタップ
    singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap2:)];
    [singleTap2 setNumberOfTouchesRequired:2];

    // 1本指でダブルタップ
    doubleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDtapGesture:)];
    [doubleTap1 setNumberOfTapsRequired:2];
    
    // 2本指でダブルタップ
    doubleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDtapGesture:)];
    [doubleTap2 setNumberOfTouchesRequired:2];
    [doubleTap2 setNumberOfTapsRequired:2];

    [singleTap1 requireGestureRecognizerToFail:doubleTap1];
    [singleTap2 requireGestureRecognizerToFail:doubleTap2];
    [self.view addGestureRecognizer:singleTap1];
    [self.view addGestureRecognizer:singleTap2];
    [self.view addGestureRecognizer:doubleTap1];
    [self.view addGestureRecognizer:doubleTap2];
    //[self.view setExclusiveTouch:YES];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
// 同一Viewで複数のジェスチャーを認識させるためのメソッド
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
*/

// Viewへの1本指シングルタッチが開始したときに呼び出されるメソッド
- (void)handleSingleTap1:(UITapGestureRecognizer*)recognizer {
    
    CGPoint point = [recognizer locationInView:self.view];
    /*
    UIImage *linesUIImage = [UIImage imageNamed:@"0218.png"];
    CGRect rect = CGRectMake(point.x - linesUIImage.size.width/2,
                             0,
                             linesUIImage.size.width,
                             linesUIImage.size.height);
    */
    CGRect rect = CGRectMake(point.x - 5,
                             0,
                             10,
                             self.view.frame.size.height);
    //UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    //imageView.image = linesUIImage;
    imageView.backgroundColor = [UIColor redColor];
    imageView.userInteractionEnabled = YES;
    
    // ダブルタップ
    UITapGestureRecognizer *dTapGestureX = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewDtapGesture:)];
    [dTapGestureX setNumberOfTapsRequired:2];
    //dTapGestureX.delegate = self;
    [imageView addGestureRecognizer:dTapGestureX];

    // ドラッグ
    UIPanGestureRecognizer *panGestureX = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureX:)];
    //panGestureX.delegate = self;
    //panGestureX.minimumNumberOfTouches = 1;
    //panGestureX.maximumNumberOfTouches = 1;
    //[panGestureX requireGestureRecognizerToFail:singleTap1];
    //[panGestureX requireGestureRecognizerToFail:singleTap2];
    [imageView addGestureRecognizer:panGestureX];

    /*
    // 長押し
    UILongPressGestureRecognizer *longPressX = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressX.delegate = self;
    [longPressX requireGestureRecognizerToFail:singleTap1];
    [longPressX requireGestureRecognizerToFail:singleTap2];
    [imageView addGestureRecognizer:longPressX];
    */
    
    [_xLinesArray addObject:imageView];
    [self.view addSubview:imageView];
    
}
// Viewへの2本指シングルタッチが開始したときに呼び出されるメソッド
- (void)handleSingleTap2:(UITapGestureRecognizer*)recognizer {
    
    CGPoint point = [recognizer locationInView:self.view];
    //UIImage *linesUIImage = [UIImage imageNamed:@"0218.png"];
    /*
    CGRect rect = CGRectMake(0,
                             point.y - linesUIImage.size.height/2,
                             linesUIImage.size.width,
                             linesUIImage.size.height);
     */
    CGRect rect = CGRectMake(0,
                             point.y - 5,
                             self.view.frame.size.width,
                             10);
    //UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    //imageView.image = linesUIImage;
    imageView.backgroundColor = [UIColor greenColor];
    imageView.userInteractionEnabled = YES;
    
    // ダブルタップ
    UITapGestureRecognizer *dTapGestureY = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewDtapGesture:)];
    [dTapGestureY setNumberOfTapsRequired:2];
    //dTapGestureY.delegate = self;
    [imageView addGestureRecognizer:dTapGestureY];
    
    // ドラッグ
    UIPanGestureRecognizer *panGestureY = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureY:)];
    //panGestureY.delegate = self;
    //panGestureY.minimumNumberOfTouches = 1;
    //panGestureY.maximumNumberOfTouches = 1;
    //[panGestureY requireGestureRecognizerToFail:singleTap1];
    //[panGestureY requireGestureRecognizerToFail:singleTap2];
    [imageView addGestureRecognizer:panGestureY];
    
    /*
    // 長押し
    UILongPressGestureRecognizer *longPressY = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressY.delegate = self;
    [longPressY requireGestureRecognizerToFail:singleTap1];
    [longPressY requireGestureRecognizerToFail:singleTap2];
    [imageView addGestureRecognizer:longPressY];
     */
     
    [_yLinesArray addObject:imageView];
    [self.view addSubview:imageView];
    
    // -90°回転
    //imageView.transform = CGAffineTransformMakeRotation(-90*M_PI/180);
    
}


// Viewへのダブルタップが行われたときに呼び出されるメソッド
- (void)handleDtapGesture:(UITapGestureRecognizer*)recognizer {
    // なにもしない
}

// ImageViewへのダブルタップが行われたときに呼び出されるメソッド
- (void)handleImageViewDtapGesture:(UITapGestureRecognizer*)recognizer {
    
    // ImageViewを削除
    [recognizer.view removeFromSuperview];
}

/*
// ImageViewへの長押しが行われたときに呼び出されるメソッド
- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            NSLog(@"長押し検知");
            // 長押しを検知した場合の処理
            // ImageViewを削除
            [recognizer.view removeFromSuperview];
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
            
        case UIGestureRecognizerStateCancelled:
            break;
            
        case UIGestureRecognizerStateFailed:
            break;
            
        case UIGestureRecognizerStateEnded:
            // 指が離された場合の処理
            break;
    }
}
*/

// ImageViewをドラッグしたときに呼び出されるメソッド
 - (void)handlePanGestureX:(UIPanGestureRecognizer *)recognizer {
          
     // タッチした座標を取得
     CGPoint center = recognizer.view.center;
     CGPoint distance = [recognizer translationInView:self.view];
     
     // センターの座標に移動距離を加える
     center.x = center.x + distance.x;
     center.y = center.y + 0;
     
     // 中心の再設定
     recognizer.view.center = center;
     
     // 移動距離をリセット
     [recognizer setTranslation:CGPointZero inView:self.view];
     
}
- (void)handlePanGestureY:(UIPanGestureRecognizer *)recognizer {
    
    // タッチした座標を取得
    CGPoint center = recognizer.view.center;
    CGPoint distance = [recognizer translationInView:self.view];
    
    // センターの座標に移動距離を加える
    center.x = center.x + 0;
    center.y = center.y + distance.y;
    
    // 中心の再設定
    recognizer.view.center = center;
    
    // 移動距離をリセット
    [recognizer setTranslation:CGPointZero inView:self.view];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
