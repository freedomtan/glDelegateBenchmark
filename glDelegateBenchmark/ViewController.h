//
//  ViewController.h
//  glDelegateBenchmark
//
//  Created by Koan-Sin Tan on 2019/1/31.
//  Copyright © 2019 Koan-Sin Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#include <cstdio>
#include <iostream>
#include <vector>

#include "TensorFlowLiteC/TensorFlowLiteC.h"
#include "TensorFlowLiteCCoreML/TensorFlowLiteCCoreML.h"
#include "TensorFlowLiteCMetal/TensorFlowLiteCMetal.h"

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *session;
    AVCaptureDevice *inputDevice;
    AVCaptureDeviceInput *deviceInput;
    AVCaptureVideoPreviewLayer *previewLayer;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIPickerView *gpuDelegatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *numberOfThreadsPicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *start;

- (IBAction)runIt:(id)sender;
@end
