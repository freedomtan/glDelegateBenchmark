//
//  ViewController.m
//  glDelegateBenchmark
//
//  Created by Koan-Sin Tan on 2019/1/31.
//  Copyright © 2019 Koan-Sin Tan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    bool enableGPU;
    bool enableCoreML;
    int numberOfThreads;
    NSArray *_cpuGPUData;
    NSArray *_numberOfThreadsData;
    NSArray *_modelNames;
    
    NSString *modelName;
    TfLiteModel *model;
    TfLiteInterpreter *interpreter;
}
@end

@implementation ViewController

NSString* FilePathForResourceName(NSString* name, NSString* extension) {
    NSString* file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (file_path == NULL) {
        std::cerr << "Couldn't find '" << [name UTF8String] << "." << [extension UTF8String]
        << "' in bundle.";
    }
    return file_path;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    enableGPU = false;
    enableCoreML = false;
    numberOfThreads = 1;
    
    _cpuGPUData = @[@"CPU", @"GPU", @"CoreML"];
    _numberOfThreadsData = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    _modelNames = @[@"mobilenet_v1_1.0_224", @"multi_person_mobilenet_v1_075_float",
                    @"deeplabv3_257_mv_gpu", @"mobile_ssd_v2_float_coco",
                    @"contours", @"mobilenet_edgetpu_224_1.0_float", @"mobiledet", @"deeplabv3_mnv2_ade20k_float", @"mobilebert_float_384_gpu"];
    modelName = @"mobilenet_v1_1.0_224";
    [self setupCamera];
}

- (IBAction)runIt:(id)sender {
    // Load model
    NSLog(@"model: %@", modelName);
    model = TfLiteModelCreateFromFile([FilePathForResourceName(modelName, @"tflite") cStringUsingEncoding: NSASCIIStringEncoding]);
        
    TfLiteInterpreterOptions* options = TfLiteInterpreterOptionsCreate();
    NSLog(@"number of threads: %d", numberOfThreads);
    TfLiteInterpreterOptionsSetNumThreads(options, numberOfThreads);
   
    // auto* delegate = TFLGpuDelegateCreate(nullptr);
    if (enableGPU) {
        auto* delegate = TFLGpuDelegateCreate(nullptr);
        TfLiteInterpreterOptionsAddDelegate(options, delegate);
    } else if (enableCoreML) {
        TfLiteCoreMlDelegateOptions coremlOptions;
        coremlOptions.enabled_devices = TfLiteCoreMlDelegateAllDevices;
        auto* delegate = TfLiteCoreMlDelegateCreate(&coremlOptions);
        TfLiteInterpreterOptionsAddDelegate(options, delegate);
    }
    
    interpreter = TfLiteInterpreterCreate(model, options);
       
    // Allocate tensor buffers.
    TfLiteInterpreterAllocateTensors(interpreter);
    
    // Run inference
    int total_count = 0;
    double total_latency = 0;
    double start, end;
    
    for (int i=0; i < 5; i++) {
        if (TfLiteInterpreterInvoke(interpreter) != kTfLiteOk) {
            std::cerr << "Failed to invoke!";
        }
    }
    
    for (int i=0; i < 50; i++) {
        start = [[NSDate new] timeIntervalSince1970];
        if (TfLiteInterpreterInvoke(interpreter) != kTfLiteOk) {
            std::cerr << "Failed to invoke!";
        }
        end = [[NSDate new] timeIntervalSince1970];
        total_latency += (end - start);
        total_count++;
    }
    NSLog(@"avg: %.4lf, count: %d", total_latency / total_count,
          total_count);
    [self.textView setText: [NSString stringWithFormat: @"%@:\n\tavg: %.4lf (ms), count: %d\n\t%@, number of threads = %d", modelName, total_latency * 1000 / total_count, total_count, enableGPU?@"GPU":(enableCoreML?@"CoreML":@"CPU"), numberOfThreads]];
    
    TfLiteInterpreterDelete(interpreter);
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
        return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView tag] == 0)
        return 3;
    else
        return [_numberOfThreadsData count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView tag] == 0)
        return _cpuGPUData[row];
    else
        return _numberOfThreadsData[row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    // NSLog(@"tag, row, c: %ld, %ld, %ld ", [pickerView tag], (long)row, (long)component);
    if ([pickerView tag] == 0) {
        if (row == 0)
            enableGPU = false;
        else
            enableGPU = true;
        
        switch (row) {
        case 0:
            enableGPU = false;
            enableCoreML = false;
            break;
        case 1:
            enableGPU = true;
            enableCoreML = false;
            break;
        case 2:
            enableGPU = false;
            enableCoreML = true;
            break;
        }
    } else {
        numberOfThreads = (int) row + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    
    // Set up the cell
    id item = _modelNames[[indexPath row]];
    
    cell.textLabel.text = [item description];
    return cell;
}

- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_modelNames count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld, %@", (long)indexPath.row, _modelNames[indexPath.row]); // you can see selected row number in your console;
    modelName = _modelNames[indexPath.row];
}


- (void) setupCamera {
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];

    inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];

    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }

    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];

    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];

    NSDictionary *rgbOutputSettings = [NSDictionary
                                       dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                       forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];

    if ([session canAddOutput:videoDataOutput])
        [session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}
@end
