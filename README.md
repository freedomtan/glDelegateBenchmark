# glDelegateBenchmark
quick and dirty inference time benchmark for TFLite gles delegate on iOS

The TensorFlow team announced TFLite GPU delegate and published related docs [2][3] in Jan 2019. But except Mobilenet V1 classifier, there is no publicly available app to evaluate it, so I wrote a quick and dirty app to evaluate other models.

For the 4 public models mentioned in [1], I got the following numbers on iPhone 7.

| model name |CPU 1 thread (ms) |CPU 2 threads (ms)   | GPU (ms)|
|------------|-----------------:|--------------------:|--------:|
| Mobilenet V1 1.0 224  | 40.62 | 29.67 | 15.97 |
| PoseNet               | 51.68 | 35.38 | 19.44 |
| DeepLab V3 (257x257)  | 62.02 | 46.08 | 25.63 |
| Mobilnet V2 SSD COCO  | 69.97 | 56.61 | 29.78 |

As far as I can tell, CPU numbers are larger than I expect, because we cannot control clock frequncies of CPUs.

On iPhone 11 Pro, I got

| model name |CPU 1 thread (ms) |CPU 2 threads (ms)   | GPU (ms)|
|------------|-----------------:|--------------------:|--------:|
| Mobilenet V1 1.0 224  | 26.54 | 18.21 | 10.91 |
| PoseNet               | 34.14 | 23.62 | 16.75 |
| DeepLab V3 (257x257)  | 39.65 | 29.87 | 20.43 |
| Mobilnet V2 SSD COCO  | 44.94 | 34.05 | 19.73 |


Check https://github.com/freedomtan/glDelegateBench/ for Android code

[1] https://medium.com/tensorflow/tensorflow-lite-now-faster-with-mobile-gpus-developer-preview-e15797e6dee7

[2] https://www.tensorflow.org/lite/performance/gpu

[3] https://www.tensorflow.org/lite/performance/gpu_advanced
