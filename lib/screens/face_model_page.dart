import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:rafiqi/constants/colors.dart';
import 'package:rafiqi/screens/welcome.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Tensor reshaping extension
extension ReshapeTensor on Float32List {
  List<List<List<List<double>>>> reshape4D(
      int batch, int height, int width, int channels) {
    return List.generate(
        batch,
        (_) => List.generate(
            height,
            (_) => List.generate(
                width, (_) => List.generate(channels, (i) => this[i]))));
  }
}

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  Interpreter? _interpreter;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  @override
  void initState() {
    super.initState();
    initModel();
    initCamera();
  }

  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      if (kDebugMode) {
        print(
            "Model loaded! Input shape: ${_interpreter?.getInputTensor(0).shape}");
      }
      if (kDebugMode) {
        print("Output shape: ${_interpreter?.getOutputTensor(0).shape}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load model: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load AI model: $e")),
        );
      }
    }
  }

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      _controller!.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          runInference(image);

        }
      });
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Camera initialization failed: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initialize camera: $e')));
      }
    }
  }

  img.Image convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;
    final yRowStride = image.planes[0].bytesPerRow;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = (y * yRowStride) + x;
        final uvIndex = ((y ~/ 2) * uvRowStride) + ((x ~/ 2) * uvPixelStride);

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }
    return rgbImage;
  }

  Float32List prepareImageInput(img.Image image, int inputSize) {
    final inputBuffer = Float32List(1 * inputSize * inputSize * 3);
    var pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        inputBuffer[pixelIndex++] = pixel.r / 255.0;
        inputBuffer[pixelIndex++] = pixel.g / 255.0;
        inputBuffer[pixelIndex++] = pixel.b / 255.0;
      }
    }
    return inputBuffer;
  }

  Future<void> runInference(CameraImage image) async {
    if (_interpreter == null) {
      if (kDebugMode) {
        print("Interpreter not loaded, skipping inference.");
      }
      return;
    }

    try {
      // 1. Convert camera image to RGB with better resizing
      img.Image rgbImage = convertYUV420ToImage(image);
      img.Image resized = img.copyResize(rgbImage,
          width: 120,
          height: 120,
          interpolation: img.Interpolation.cubic // Higher quality interpolation
          );

      // 2. Prepare input tensor
      var input = prepareImageInput(resized, 120);

      // 3. Dynamic output tensor handling
      final outputTensors = [
        _interpreter!.getOutputTensor(0),
        _interpreter!.getOutputTensor(1)
      ];

      // Debug print tensor info
      if (kDebugMode) {
        print("""
    Output 0: Shape ${outputTensors[0].shape} | Type ${outputTensors[0].type}
    Output 1: Shape ${outputTensors[1].shape} | Type ${outputTensors[1].type}
    """);
      }

      // Determine which output is confidence
      final isFirstOutputConfidence = outputTensors[0].shape[1] == 1;
      final confidenceIndex = isFirstOutputConfidence ? 0 : 1;
      final coordsIndex = isFirstOutputConfidence ? 1 : 0;

      // 4. Prepare output buffers
      var output0 = List.filled(outputTensors[coordsIndex].shape[1], 0.0)
          .reshape([1, outputTensors[coordsIndex].shape[1]]);
      var output1 = List.filled(outputTensors[confidenceIndex].shape[1], 0.0)
          .reshape([1, outputTensors[confidenceIndex].shape[1]]);

      // 5. Run inference with properly shaped input
      _interpreter!.runForMultipleInputs([input.reshape4D(1, 120, 120, 3)],
          {coordsIndex: output0, confidenceIndex: output1});

      // 6. Get confidence score
      final confidence = output1[0][0] * 10;
      if (kDebugMode) {
        for (int i = 0; i < 5; i++) {
          print("Confidence: $confidence");
        }
      }

      if (confidence > 0.4 && mounted) {
        await _controller!.stopImageStream();
        await Future.delayed(const Duration(seconds: 2)); // Optional delay
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => WelcomePage()),
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("Inference error: $e\n$stack");
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return  Scaffold(
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height:MediaQuery.of(context).size.width * 0.2 ,
            child: CircularProgressIndicator(
              color: MyColor.brownOne,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Transform.rotate(
              angle: -300,
              child: CameraPreview(_controller!),
            ),
          ),
          // FloatingActionButton(
          //   onPressed: () => Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (_) => WelcomePage()),
          //   ),
          //   child: const Icon(Icons.navigate_next),
          // )
        ],
      ),
    );
  }
}
