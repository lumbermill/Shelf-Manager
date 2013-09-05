//
//  ShelfManager.m
//  OpenCVDemos
//
//  Created by 國武　正督 on 2013/08/23.
//  Copyright (c) 2013年 Rz.inc. All rights reserved.
//

#import "ShelfManager.h"

@implementation ShelfManager

- (cv::Mat)convert:(cv::Mat) src_img{
    
    // 直線検出(Houghlines)
    
    // 中間画像作成
    cv::Mat work_img = src_img;
    cv::Mat dst_img;
    
    // グレースケールに変換後、canny関数で輪郭を抽出
    cv::cvtColor(src_img, dst_img, CV_RGB2GRAY);

    // コントラストを上げる
    cv::equalizeHist(dst_img, dst_img);

    // ぼかしでノイズ低減
    //cv::medianBlur(dst_img, dst_img, 9);

    // 2値化　入力画像，出力画像，閾値，maxVal，閾値処理手法
    //cv::threshold(dst_img, dst_img, self.gain*255, 255, cv::THRESH_BINARY);
    // スライダ値によって閾値を変更
    
    // 入力画像，出力画像，閾値，maxVal，閾値処理手法
    //cv::threshold(dst_img, dst_img, self.gain*255, 255, cv::THRESH_TOZERO);
    // スライダ値によって閾値を変更

    cv::Canny(dst_img, dst_img, self.gain*255, self.gain*255, 3);
    
    int distance = self.gain2nd * 100 + 1;
    
    
    // 古典的Hough変換
    std::vector<cv::Vec2f> lines;
    // 入力画像，出力画像，距離分解能，角度分解能，閾値，*,*
    cv::HoughLines(dst_img, lines, distance, CV_PI/2, 200, 0, 0);
    // 閾値をスライダ値で可変

    // 頂点のピックアップ（原点でイニシャライズ）
    //NSMutableArray *apicesX = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
    //NSMutableArray *apicesY = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
    self.apicesX = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
    self.apicesY = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
    
    // 直線の描画
    std::vector<cv::Vec2f>::iterator it = lines.begin();
    for(; fmin(it!=lines.end(),50); ++it) {
        float rho = (*it)[0], theta = (*it)[1];
        
        cv::Point pt1, pt2, ptC;
        ptC.x = 0;
        ptC.y = 0;

        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        pt1.x = cv::saturate_cast<int>(x0 + 2000*(-b));
        pt1.y = cv::saturate_cast<int>(y0 + 2000*(a));
        pt2.x = cv::saturate_cast<int>(x0 - 2000*(-b));
        pt2.y = cv::saturate_cast<int>(y0 - 2000*(a));
        
        //直線描画
        //cv::line(work_img, pt1, pt2, cv::Scalar(255,0,0), 3, CV_AA);

        if (ptC.x == cv::saturate_cast<int>(x0)) {
            ptC.y = cv::saturate_cast<int>(y0);
            // Y軸方向の検出ポイント
           [self.apicesY addObject:[NSNumber numberWithInt:ptC.y]];
        }
        else if (ptC.y == cv::saturate_cast<int>(y0)) {
            // X軸方向の検出ポイント
            ptC.x = cv::saturate_cast<int>(x0);
            [self.apicesX addObject:[NSNumber numberWithInt:ptC.x]];
        }
    }
    
    // 頂点のピックアップ（原点の対角点）
    [self.apicesX addObject:[NSNumber numberWithInt:work_img.cols]];
    [self.apicesY addObject:[NSNumber numberWithInt:work_img.rows]];

    cv::Point ptCxy;
    for (int i=0; i < [self.apicesX count]; i++) {
        for (int j=0; j < [self.apicesY count]; j++) {
            
            ptCxy.x = [[self.apicesX objectAtIndex:i] intValue];
            ptCxy.y = [[self.apicesY objectAtIndex:j] intValue];

            // 画像，円の中心座標，半径，色，線太さ，種類
            //cv::circle(work_img, ptCxy, 10, cv::Scalar(0,200,0), -1);
        }
    }
   
    return work_img;
}

- (NSString *)getGainFormat{
    return [NSString stringWithFormat:@"Threshold\n %.2f",self.gain*255];
    
}
- (NSString *)getGain2ndFormat{
    int distance = self.gain2nd * 100;
    return [NSString stringWithFormat:@"Distance\n %d",distance];
    
}


@end
