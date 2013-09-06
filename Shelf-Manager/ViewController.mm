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
@synthesize converter;
@synthesize effBufImage;
@synthesize photoView;

UITapGestureRecognizer *singleTap1;
UITapGestureRecognizer *singleTap2;
UITapGestureRecognizer *doubleTap1;
UITapGestureRecognizer *doubleTap2;
UIPinchGestureRecognizer *pinchGesture;

// アクティビティインジケータ
UIActivityIndicatorView *indicator;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Converterクラスのオーバーライド
    NSString *className = @"ShelfManager";
    Class aClass = NSClassFromString(className);
    converter = [[aClass alloc]init];
    
    // ScrollViewの設定
    self.scrollView.delegate = self;
    
    // スライダーの初期値を通知
    converter.gain = _levelSlider.value;
    converter.gain2nd = _levelSlider2nd.value;
    _label01.text = [converter getGainFormat];
    _label02.text = [converter getGain2ndFormat];

    // アクティビティインジケータ作成
    indicator = [[UIActivityIndicatorView alloc]init];
    // 位置を指定（画面の中央に表示する）
    indicator.center = self.view.center;
    indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    // スタイルをセット
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.color = [UIColor redColor];
    // UIActivityIndicatorViewのインスタンスをビューに追加
    [self.view addSubview:indicator];

}

- (void)addGestureRecognizer {
    
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
    [photoView addGestureRecognizer:singleTap1];
    [photoView addGestureRecognizer:singleTap2];
    [photoView addGestureRecognizer:doubleTap1];
    [photoView addGestureRecognizer:doubleTap2];
    //[photoView setExclusiveTouch:YES];
    
}


// 画像選択ボタン
- (IBAction)photoSelectBtn:(id)sender {
    
    // アクションシートを作る
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc]
                   initWithTitle:@"写真を選択します"
                   delegate:self
                   cancelButtonTitle:@"キャンセル"
                   destructiveButtonTitle:nil
                   otherButtonTitles:@"フォトライブラリ",@"カメラ起動", nil];
    
    // アクションシートを表示する
    [actionSheet showInView:self.view];

}

// アクションシートで選択されたときの処理
- (void)actionSheet: (UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    switch (buttonIndex) {
        case 0: {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        case 1: {
            // カメラはAVFoundationクラスで実装
            // いまは未実装
            break;
        }
    }
    
    // 使用可能かどうかチェックする
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        
        // イメージピッカーを作る
        UIImagePickerController* picker = [[UIImagePickerController alloc]init];
        picker.sourceType = sourceType;
        picker.delegate = self;
        
        // イメージピッカーを表示する
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else {
        // エラー処理
        NSLog(@"Photo Err!!");
    }    
}


// UIImagePickerの呼び出し
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    effBufImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        // 表示関係一式
        [self createViews];
        
        // リフレッシュボタン有効
        self.refreshBtnOutlet.enabled = YES;
        
        // スライス保存ボタン有効
        self.sliceSaveBtnOutlet.enabled = YES;
        
    }];
}


// scrollViewとimageViewの設定
- (void)createViews {
    
    // subViewの削除
    for(UIView *removeView in [photoView subviews]){
        [removeView removeFromSuperview];
    }
    for(UIView *removeView in [self.scrollView subviews]){
        [removeView removeFromSuperview];
    }
    
    // 配列の初期化
    _xLinesArray = [[NSMutableArray alloc]init];
    _yLinesArray = [[NSMutableArray alloc]init];
    
    // 静止画の変換と表示
    // photoViewの設定
    CGRect photoViewFrame = CGRectZero;
    photoViewFrame.size = effBufImage.size;
    photoView = [[UIImageView alloc]initWithFrame:photoViewFrame];
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    photoView.userInteractionEnabled = YES;
    
    // scrollViewの設定
    self.scrollView.contentSize = photoView.bounds.size;
    [self.scrollView addSubview: photoView];
    
    // 直線検出と画像の表示
    [self photoImageViewing];
    
    // ジェスチャーレコグナイザ実装
    [self addGestureRecognizer];
    
    // 直線検出したポイントを書き出す
    [self.scrollView setContentOffset:CGPointZero];
    [self hitStraightLinesWritting];
    
    /*
    // センタリング
    CGPoint center = CGPointMake(photoView.frame.size.width / 2 - self.view.frame.size.width / 2,
                                 photoView.frame.size.height / 2 - self.view.frame.size.height / 2);
    [self.scrollView setContentOffset:center];
    */
    
    // スケール設定する
    float   hScale, vScale, minScale;
    hScale = CGRectGetWidth(self.view.bounds) / photoView.frame.size.width;
    vScale = CGRectGetHeight(self.view.bounds) / photoView.frame.size.height;
    minScale = MIN(hScale, vScale);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;

}


// 静止画の変換と表示
- (void) photoImageViewing {
    
    // 画像を選択してないとエラーになるので回避処理
    if (effBufImage) {
        
        // アクティビティインジケータを表示
        [indicator startAnimating];
        // RunLoopに戻らないと表示されないので、一瞬戻す
        [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        
        // OpenCVでの画像処理
        cv::Mat src_img = [Utils CVMatFromUIImage:effBufImage];
        src_img = [converter convert:src_img];
        //UIImage *effectedImage = [Utils UIImageFromCVMat:src_img];
        //photoView.image = effectedImage;
        photoView.image = effBufImage;
        
        // アクティビティインジケータが動いていたら止める
        if (indicator.isAnimating) {
            [indicator stopAnimating];
        }
    }
}


// 再画像処理ボタン
- (IBAction)refreshBtn:(id)sender {
    
    // 表示関係一式
    [self createViews];
}


// 直線検出したポイントを反映させる
- (void)hitStraightLinesWritting {
    
    CGPoint point = CGPointZero;
    
    for (int i=0; i < [converter.apicesX count]; i++)
    {        
        point.x = [[converter.apicesX objectAtIndex:i] intValue];
        [self singleTap1:point];        
    }
    
    for (int j=0; j < [converter.apicesY count]; j++)
    {
        point.y = [[converter.apicesY objectAtIndex:j] intValue];
        [self singleTap2:point];
    }
}

// スライス画像保存ボタン
- (IBAction)sliceSaveBtn:(id)sender {
    
    // 更新された直線の座標配列
    NSMutableArray *appliedApicesX = [[NSMutableArray alloc]init];
    NSMutableArray *appliedApicesY = [[NSMutableArray alloc]init];
    
    // X軸方向の検出ポイント
    for (int i=0; i < [_xLinesArray count]; i++)
    {
        UIImageView *imageView = [_xLinesArray objectAtIndex:i];
        if ([[NSNumber numberWithInt:imageView.center.x]intValue] >= 0 &&
            [[NSNumber numberWithInt:imageView.center.x]intValue] <=
            photoView.frame.size.width / self.scrollView.zoomScale) {
            // OpenCVが範囲外を返してくることがあるようなので回避
            [appliedApicesX addObject:[NSNumber numberWithInt:imageView.center.x]];
        }
        NSLog(@"pointX: %d",[[NSNumber numberWithInt:imageView.center.x]intValue]);
    }
    // Y軸方向の検出ポイント
    for (int j=0; j < [_yLinesArray count]; j++)
    {
        UIImageView *imageView = [_yLinesArray objectAtIndex:j];
        if ([[NSNumber numberWithInt:imageView.center.y]intValue] >= 0 &&
            [[NSNumber numberWithInt:imageView.center.y]intValue] <=
            photoView.frame.size.height / self.scrollView.zoomScale) {
            // OpenCVが範囲外を返してくることがあるようなので回避
            [appliedApicesY addObject:[NSNumber numberWithInt:imageView.center.y]];
        }
        NSLog(@"pointY: %d",[[NSNumber numberWithInt:imageView.center.y]intValue]);
    }
    
    // 直線が２本以上ないとスライスできないので判定する
    if (appliedApicesX.count < 2 || appliedApicesY.count < 2)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"エラー"
                              message:@"直線は２本以上必要です"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
        // アラートビューを表示
        [alert show];
    }
    else
    {
        CGRect rect;
        CGPoint ptCxy1, ptCxy2;
        UIImage *srcUIImg = effBufImage;
        UIImage *sliceImg;
        
        // 昇順で並べ替え
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        NSArray *sorted_apicesX = [appliedApicesX sortedArrayUsingDescriptors:@[sortDescriptor]];
        NSArray *sorted_apicesY = [appliedApicesY sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        // 保存ディレクトリを指定
        NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/shelf-manager"];
        
        if ([FileManager fileExistsAtPath:docDir]) {
            // なにもしない
        } else {
            [FileManager createDirectory:docDir];
        }
        
        // 保存ディレクトリの中身を空にする
        NSArray *savedFilesPNG = [FileManager fileNamesAtDirectoryPath:docDir extension:@"png"];
        NSArray *savedFilesJPG = [FileManager fileNamesAtDirectoryPath:docDir extension:@"jpg"];
        for (int i=0; i < [savedFilesPNG count]; i++)
        {
            if ([FileManager removeFilePath:[docDir stringByAppendingString:[savedFilesPNG objectAtIndex:i]]]) {
                NSLog(@"removePNG OK");
            } else {
                NSLog(@"removePNG NG");
            }
        }
        for (int i=0; i < [savedFilesJPG count]; i++)
        {
            if ([FileManager removeFilePath:[docDir stringByAppendingString:[savedFilesJPG objectAtIndex:i]]]) {
                NSLog(@"removeJPG OK");
            } else {
                NSLog(@"removeJPG NG");
            }
        }
        
        // 保存ディレクトリ＋ファイル名を指定
        NSString *photoFilePathJPG;
        NSString *photoFilePathPNG;
        
        int k = 0;
        for (int i=0; i < [sorted_apicesX count]-1; i++) {
            for (int j=0; j < [sorted_apicesY count]-1; j++) {
                
                ptCxy1.x = [[sorted_apicesX objectAtIndex:i] intValue];
                ptCxy1.y = [[sorted_apicesY objectAtIndex:j] intValue];
                ptCxy2.x = [[sorted_apicesX objectAtIndex:i+1] intValue];
                ptCxy2.y = [[sorted_apicesY objectAtIndex:j+1] intValue];
                
                // UIImageでトリミング
                rect = CGRectMake(ptCxy1.x, ptCxy1.y, ptCxy2.x - ptCxy1.x, ptCxy2.y - ptCxy1.y);
                CGImageRef sliceCGImg = CGImageCreateWithImageInRect(srcUIImg.CGImage, rect);
                sliceImg = [UIImage imageWithCGImage:sliceCGImg];
                CGImageRelease(sliceCGImg);
                
                // 保存ディレクトリ＋ファイル名を指定
                photoFilePathJPG = [[docDir stringByAppendingString:[NSString stringWithFormat:@"/slicephoto_x%02d", i]]
                                    stringByAppendingString:[NSString stringWithFormat:@"_y%02d.jpg", j]];
                photoFilePathPNG = [[docDir stringByAppendingString:[NSString stringWithFormat:@"/slicephoto_x%02d", i]]
                                    stringByAppendingString:[NSString stringWithFormat:@"_y%02d.png", j]];
                
                /*
                 // 圧縮率を指定しJPEGファイルで保存する
                 if ([UIImageJPEGRepresentation(sliceImg, 1.0f) writeToFile:photoFilePathJPG atomically:YES]) {
                 NSLog(@"save OK");
                 } else {
                 NSLog(@"save NG");
                 }
                 */
                
                // PNGファイルで保存する
                if ([UIImagePNGRepresentation(sliceImg) writeToFile:photoFilePathPNG atomically:YES]) {
                    NSLog(@"save OK");
                } else {
                    NSLog(@"save NG");
                }
                
                k++;
            }
        }
    }
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
    point.x = (point.x + self.scrollView.contentOffset.x) / self.scrollView.zoomScale;
    point.y = (point.y + self.scrollView.contentOffset.y) / self.scrollView.zoomScale;
    [self singleTap1:point];
    
}
// Viewへの2本指シングルタッチが開始したときに呼び出されるメソッド
- (void)handleSingleTap2:(UITapGestureRecognizer*)recognizer {
    
    CGPoint point = [recognizer locationInView:self.view];
    point.x = (point.x + self.scrollView.contentOffset.x) / self.scrollView.zoomScale;
    point.y = (point.y + self.scrollView.contentOffset.y) / self.scrollView.zoomScale;
    [self singleTap2:point];

}

- (void)singleTap1:(CGPoint)point {

    CGFloat viewWidth = 40;
    CGFloat lineWidth = 6;
    CGRect rect = CGRectMake(point.x - viewWidth/2,
                             0,
                             viewWidth,
                             photoView.frame.size.height / self.scrollView.zoomScale);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    
    
    // imageView内に直線を描画する　開始
    UIGraphicsBeginImageContext(imageView.frame.size);
    
    // 描画領域をimageViewの大きさで生成
    [imageView.image drawInRect:
     CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    
    // 描画書式の設定
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(lineWidth/2, 0.0), 1.5, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, viewWidth/2 - lineWidth/2, 0);  // 始点
    CGContextAddLineToPoint(context, viewWidth/2 - lineWidth/2, imageView.frame.size.height); // 終点
        
    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(context);
    
    // 描画領域を画像（UIImage）としてimageViewにセット
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画処理の終了
    UIGraphicsEndImageContext();
    
    
    // ダブルタップ
    UITapGestureRecognizer *dTapGestureX = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewDtapGesture:)];
    [dTapGestureX setNumberOfTapsRequired:2];
    //dTapGestureX.delegate = self;
    [imageView addGestureRecognizer:dTapGestureX];
    
    // ドラッグ
    UIPanGestureRecognizer *panGestureX = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureX:)];
    //panGestureX.delegate = self;
    [imageView addGestureRecognizer:panGestureX];
    
    /*
     // 長押し
     UILongPressGestureRecognizer *longPressX = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
     longPressX.delegate = self;
     [longPressX requireGestureRecognizerToFail:singleTap1];
     [longPressX requireGestureRecognizerToFail:singleTap2];
     [imageView addGestureRecognizer:longPressX];
     */
    
    // imageViewを配列に追加
    [_xLinesArray addObject:imageView];
    [photoView addSubview:imageView];
}
- (void)singleTap2:(CGPoint)point {
    
    CGFloat viewWidth = 40;
    CGFloat lineWidth = 6;
    CGRect rect = CGRectMake(0,
                             point.y - viewWidth/2,
                             photoView.frame.size.width / self.scrollView.zoomScale,
                             viewWidth);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    
    
    // imageView内に直線を描画する　開始
    UIGraphicsBeginImageContext(imageView.frame.size);
    
    // 描画領域をimageViewの大きさで生成
    [imageView.image drawInRect:
     CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    
    // 描画書式の設定
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, lineWidth/2), 1.5, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, 0, viewWidth/2 - lineWidth/2);  // 始点
    CGContextAddLineToPoint(context, imageView.frame.size.width, viewWidth/2 - lineWidth/2 ); // 終点
    
    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(context);
    
    // 描画領域を画像（UIImage）としてimageViewにセット
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画処理の終了
    UIGraphicsEndImageContext();
    
    
    // ダブルタップ
    UITapGestureRecognizer *dTapGestureY = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewDtapGesture:)];
    [dTapGestureY setNumberOfTapsRequired:2];
    //dTapGestureY.delegate = self;
    [imageView addGestureRecognizer:dTapGestureY];
    
    // ドラッグ
    UIPanGestureRecognizer *panGestureY = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureY:)];
    //panGestureY.delegate = self;
    [imageView addGestureRecognizer:panGestureY];
    
    /*
     // 長押し
     UILongPressGestureRecognizer *longPressY = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
     longPressY.delegate = self;
     [longPressY requireGestureRecognizerToFail:singleTap1];
     [longPressY requireGestureRecognizerToFail:singleTap2];
     [imageView addGestureRecognizer:longPressY];
     */
    
    // imageViewを配列に追加
    [_yLinesArray addObject:imageView];
    [photoView addSubview:imageView];
}




// Viewへのダブルタップが行われたときに呼び出されるメソッド
- (void)handleDtapGesture:(UITapGestureRecognizer*)recognizer {
    // なにもしない
}

// ImageViewへのダブルタップが行われたときに呼び出されるメソッド
- (void)handleImageViewDtapGesture:(UITapGestureRecognizer*)recognizer {
    
    // 該当のimageViewが配列のどれなのか検索
    NSInteger indexX = [_xLinesArray indexOfObject:recognizer.view];
    NSInteger indexY = [_yLinesArray indexOfObject:recognizer.view];

    // 該当imageViewを配列から削除
    if (indexX != NSNotFound) {
        NSLog(@"Xの%d番目です", indexX);
        [_xLinesArray removeObjectAtIndex:indexX];
    }
    else if (indexY != NSNotFound) {
        NSLog(@"Yの%d番目です", indexY);
        [_yLinesArray removeObjectAtIndex:indexY];
    }
    
    // ImageViewをsubviewから削除
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
     center.x = center.x + distance.x / self.scrollView.zoomScale;
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
    center.y = center.y + distance.y / self.scrollView.zoomScale;
    
    // 中心の再設定
    recognizer.view.center = center;
    
    // 移動距離をリセット
    [recognizer setTranslation:CGPointZero inView:self.view];
    
}

// ピンチイン/アウトで拡大縮小
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView
{
	return photoView;
}

- (IBAction)levelSlider:(UISlider *)sender {
    converter.gain = [sender value];
    _label01.text = [converter getGainFormat];
}
- (IBAction)levelSlider2nd:(UISlider *)sender {
    converter.gain2nd = [sender value];
    _label02.text = [converter getGain2ndFormat];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
