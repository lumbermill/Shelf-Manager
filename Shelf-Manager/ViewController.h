//
//  ViewController.h
//  Shelf-Manager_Demo
//
//  Created by 國武　正督 on 2013/08/30.
//  Copyright (c) 2013年 Rz.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <opencv2/opencv.hpp>
#import "Converter.h"

@interface ViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property Converter *converter;
@property (nonatomic) UIImage *effBufImage;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UIImageView *photoView;


- (IBAction)photoSelectBtn:(id)sender;
- (IBAction)refreshBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtnOutlet;
- (IBAction)sliceSaveBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sliceSaveBtnOutlet;

@property (weak, nonatomic) IBOutlet UISlider *levelSlider;
- (IBAction)levelSlider:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UISlider *levelSlider2nd;
- (IBAction)levelSlider2nd:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UILabel *label01;
@property (weak, nonatomic) IBOutlet UILabel *label02;

@end
