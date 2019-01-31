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
    int numberOfThreads;
    NSArray *_cpuGPUData;
    NSArray *_numberOfThreadsData;
    NSArray *_modelNames;
    
    NSString *modelName;
    std::unique_ptr<tflite::FlatBufferModel> model;
    tflite::ops::builtin::BuiltinOpResolver resolver;
    std::unique_ptr<tflite::Interpreter> interpreter;
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
    numberOfThreads = 1;
    
    _cpuGPUData = @[@"CPU", @"GPU"];
    _numberOfThreadsData = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    _modelNames = @[@"mobilenet_v1_1.0_224", @"multi_person_mobilenet_v1_075_float",
                    @"deeplabv3_257_mv_gpu", @"mobile_ssd_v2_float_coco",
                    @"contours"];
    modelName = @"mobilenet_v1_1.0_224";
}

- (IBAction)runIt:(id)sender {
    // Load model
    NSLog(@"model: %@", modelName);
    model = tflite::FlatBufferModel::BuildFromFile([FilePathForResourceName(modelName, @"tflite") cStringUsingEncoding: NSASCIIStringEncoding]);
    
    // Build the interpreter
    tflite::InterpreterBuilder builder(*model, resolver);
    builder(&interpreter);
    auto* delegate = NewGpuDelegate(nullptr);  // default config
    if (enableGPU) interpreter->ModifyGraphWithDelegate(delegate);
    
    // Allocate tensor buffers.
    interpreter->AllocateTensors();
    // printf("=== Pre-invoke Interpreter State ===\n");
    // tflite::PrintInterpreterState(interpreter.get());
    NSLog(@"number of threads: %d", numberOfThreads);
    interpreter->SetNumThreads(numberOfThreads);
    // Run inference
    int total_count = 0;
    double total_latency = 0;
    double start, end;
    
    for (int i=0; i < 5; i++) {
        if (interpreter->Invoke() != kTfLiteOk) {
            std::cerr << "Failed to invoke!";
        }
    }
    
    for (int i=0; i < 50; i++) {
        start = [[NSDate new] timeIntervalSince1970];
        if (interpreter->Invoke() != kTfLiteOk) {
            std::cerr << "Failed to invoke!";
        }
        end = [[NSDate new] timeIntervalSince1970];
        total_latency += (end - start);
        total_count++;
    }
    NSLog(@"avg: %.4lf, count: %d", total_latency / total_count,
          total_count);
    [self.textView setText: [NSString stringWithFormat: @"%@:\n\tavg: %.4lf (ms), count: %d\n\t%@, number of threads = %d", modelName, total_latency / total_count, total_count, enableGPU?@"GPU":@"CPU", numberOfThreads]];
    interpreter = nullptr;
    DeleteGpuDelegate(delegate);
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
        return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView tag] == 0)
        return 2;
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

@end
