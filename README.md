# glDelegateBenchmark
quick and dirty inference time benchmark for TFLite gles delegate on iOS

The TensorFlow team announced TFLite GPU delegate and published related docs [2][3] in Jan 2019. But except Mobilenet V1 classifier, there is no publicly available app to evaluate it, so I wrote a quick and dirty app to evaluate other models.

For the 4 public models mentioned in [1], I got the following numbers on iPhone 7.

| model name |CPU 1 thread (ms) |	CPU 2 threads (ms)	| GPU (ms)|
|------------|-----------------:|--------------------:|--------:|
| Mobilenet V1 1.0 224	| 43.9	| 31.9	| 18.8 |
| PoseNet	| 52.2	| 37.5	| 22.5 |
| DeepLab V3 (257x257) |	65.0	| 49.2	|29.8|
| Mobilnet V2 SSD COCO |72.5 | 61.0	| 35.3|

As far as I can tell, CPU numbers are larger than I expect, because we cannot control clock frequncies of CPUs.

Check https://github.com/freedomtan/glDelegateBench/ for Android code

[1] https://medium.com/tensorflow/tensorflow-lite-now-faster-with-mobile-gpus-developer-preview-e15797e6dee7

[2] https://www.tensorflow.org/lite/performance/gpu

[3] https://www.tensorflow.org/lite/performance/gpu_advanced
