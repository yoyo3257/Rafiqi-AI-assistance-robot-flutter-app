// ... (imports) ...
import 'dart:async';
import 'dart:typed_data'; // Make sure this is imported if not already
import 'package:image/image.dart' as img; // Make sure this is imported
import 'package:rafiqi/raspberryPlugins/native_camera.dart'; // IMPORT YOUR NATIVE CAMERA BINDINGS
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  NativeCamera? _nativeCamera; // NEW: Your native camera instance
  Interpreter? _interpreter;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  Timer? _captureTimer; // To periodically capture frames from native
  Uint8List? _latestDisplayImageBytes;
  @override
  void initState() {
    super.initState();
    initModel();
    initCamera();
  }

  // ... (initModel - unchanged) ...
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
      // You decide the desired resolution for your camera feed
      _nativeCamera =
          await NativeCamera.create(640, 480); // e.g., 640x480 resolution
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      // Start a timer to periodically capture frames
      _captureTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (!_isProcessing && _nativeCamera != null) {
          _isProcessing = true;
          try {
            Uint8List? imageData = _nativeCamera!.captureFrame();
            if (imageData != null) {
              runInference(
                  imageData, _nativeCamera!.width, _nativeCamera!.height);
            } else {
              if (kDebugMode) {
                print("No frame captured from native camera.");
              }
              _isProcessing = false; // Allow next capture attempt
            }
          } catch (e, stack) {
            if (kDebugMode) {
              print(
                  "Error during native frame capture or inference setup: $e\n$stack");
            }
            _isProcessing = false; // Allow next capture attempt
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Camera initialization failed: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initialize camera: $e')));
      }
      setState(() {
        _isCameraInitialized = false; // Ensure state reflects failure
      });
    }
  }

  // ... (convertYUV420ToImage and prepareImageInput - use the adapted versions from previous response) ...
  /// Converts raw YUV420 bytes from a native camera capture to an RGB Image.
  ///
  /// [yuvBytes]: The raw byte data containing Y, U, and V planes.
  ///   The exact layout (e.g., planar, semi-planar) and strides will depend
  ///   on your native camera implementation (`raspberry_camera.cpp`).
  ///   This function assumes a basic planar YUV420 layout where Y, U, and V
  ///   planes are concatenated.
  /// [width]: The width of the captured image.
  /// [height]: The height of the captured image.
  img.Image convertYUV420ToImage(Uint8List yuvBytes, int width, int height) {
    // IMPORTANT: This conversion assumes the `yuvBytes` are packed Y, U, and V planes
    // directly from a YUV420_888 like structure.
    // You'll need to know the exact byte layout from your native capture.
    // The original `CameraImage` has planes with `bytesPerRow` and `bytesPerPixel`.
    // Your native code needs to provide this or pack it into a consistent format.

    // For demonstration, let's assume yuvBytes is YYYYYY...UUUU...VVVV
    // This is a simplified example, actual byte strides will vary depending on
    // the native camera's output format and padding.
    final ySize = width * height;
    final uvSize = (width ~/ 2) * (height ~/ 2); // For YUV420

    // Ensure the buffer is large enough for Y, U, and V planes
    if (yuvBytes.length < ySize + uvSize * 2) {
      throw Exception(
          "YUV byte array is too small for YUV420 at $width x $height resolution.");
    }

    final yPlane = yuvBytes.sublist(0, ySize);
    final uPlane = yuvBytes.sublist(ySize, ySize + uvSize);
    final vPlane = yuvBytes.sublist(ySize + uvSize, ySize + uvSize * 2);

    final rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Simplified index calculation. If your native code has row strides/pixel strides,
        // you'd need to account for them here.
        final yIndex = (y * width) + x;
        final uvIndex = ((y ~/ 2) * (width ~/ 2)) + (x ~/ 2);

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        // YUV to RGB conversion formulas
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

  /// Prepares an [img.Image] for TensorFlow Lite inference by resizing and normalizing pixel values.
  ///
  /// [image]: The input image (e.g., from `convertYUV420ToImage`).
  /// [inputSize]: The target size (width and height) for the input tensor.
  ///              (e.g., 120 for a 120x120 input).
  Float32List prepareImageInput(img.Image image, int inputSize) {
    // Ensure the image is resized to the expected inputSize before processing
    final resizedImage = img.copyResize(image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.cubic);

    final inputBuffer = Float32List(1 *
        inputSize *
        inputSize *
        3); // For a 1xinputSize xinputSize x3 tensor
    var pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel =
            resizedImage.getPixel(x, y); // Get pixel from the resized image
        inputBuffer[pixelIndex++] = pixel.r / 255.0; // Normalize R to 0-1
        inputBuffer[pixelIndex++] = pixel.g / 255.0; // Normalize G to 0-1
        inputBuffer[pixelIndex++] = pixel.b / 255.0; // Normalize B to 0-1
      }
    }
    return inputBuffer;
  }

  // ADAPTED runInference TO ACCEPT YOUR CUSTOM IMAGE DATA
  Future<void> runInference(
      Uint8List imageData, int imageWidth, int imageHeight) async {
    if (_interpreter == null) {
      if (kDebugMode) {
        print("Interpreter not loaded, skipping inference.");
      }
      _isProcessing = false; // Allow new frames
      return;
    }

    try {
      // 1. Convert native camera image data to RGB with better resizing
      img.Image rgbImage =
          convertYUV420ToImage(imageData, imageWidth, imageHeight);
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
        for (int i = 0; i < 4; i++) {
          // Print less frequently for debug
          print("Confidence: $confidence");
        }
      }

      if (confidence > 0.4 && mounted) {
        _captureTimer?.cancel(); // Stop the capture timer
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
      _isProcessing = false; // Release the lock for the next frame
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel(); // Cancel the timer
    _nativeCamera?.dispose(); // Dispose your native camera
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      // Removed _nativeCamera == null check here as initCamera handles failure state
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            child: CircularProgressIndicator(
              color: MyColor.brownOne,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      );
    }
    // IMPORTANT: CameraPreview cannot be used directly.
    // You will need to implement a custom rendering solution if you want to show the live feed.
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: _latestDisplayImageBytes != null
                  ? Image.memory(
                      _latestDisplayImageBytes!,
                      fit: BoxFit.cover, // Adjust fit as needed
                      // You might need to specify width/height if not using BoxFit.cover on a sized box
                    )
                  : const Center(
                      child: Text(
                        "Waiting for camera feed...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
      ),
    );
  }
}
