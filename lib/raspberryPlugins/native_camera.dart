import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart'; // For calloc, free

// Opaque pointer for the native camera context
typedef CameraContextPtr = Pointer<Void>;

// FFI definitions for your C functions
typedef InitCameraNativeC = CameraContextPtr Function(Int32 width, Int32 height);
typedef InitCameraNativeDart = CameraContextPtr Function(int width, int height);

typedef CaptureFrameNativeC = Int32 Function(CameraContextPtr context, Pointer<Uint8> buffer, Int32 buffer_size);
typedef CaptureFrameNativeDart = int Function(CameraContextPtr context, Pointer<Uint8> buffer, int buffer_size);

typedef GetCameraWidthNativeC = Int32 Function(CameraContextPtr context);
typedef GetCameraWidthNativeDart = int Function(CameraContextPtr context);

typedef GetCameraHeightNativeC = Int32 Function(CameraContextPtr context);
typedef GetCameraHeightNativeDart = int Function(CameraContextPtr context);

typedef GetFrameBufferSizeNativeC = Int32 Function(CameraContextPtr context);
typedef GetFrameBufferSizeNativeDart = int Function(CameraContextPtr context);

typedef DeinitCameraNativeC = Void Function(CameraContextPtr context);
typedef DeinitCameraNativeDart = void Function(CameraContextPtr context);

class NativeCamera {
  late DynamicLibrary _dylib;
  late InitCameraNativeDart _initCamera;
  late CaptureFrameNativeDart _captureFrame;
  late GetCameraWidthNativeDart _getCameraWidth;
  late GetCameraHeightNativeDart _getCameraHeight;
  late GetFrameBufferSizeNativeDart _getFrameBufferSize;
  late DeinitCameraNativeDart _deinitCamera;

  CameraContextPtr? _cameraContext;
  int _width = 0;
  int _height = 0;
  int _frameBufferSize = 0;

  // Make the constructor private to enforce async initialization
  NativeCamera._();

  static Future<NativeCamera> create(int width, int height) async {
    final camera = NativeCamera._();
    await camera._initialize(width, height);
    return camera;
  }

  Future<void> _initialize(int width, int height) async {
    if (Platform.isLinux) {
      // Adjust the path to where your .so file will be deployed
      // For flutter-pi, it's often in the same directory as the app binary
      _dylib = DynamicLibrary.open('libraspberry_camera.so');
      _initCamera = _dylib
          .lookupFunction<InitCameraNativeC, InitCameraNativeDart>('init_camera_native');
      _captureFrame = _dylib
          .lookupFunction<CaptureFrameNativeC, CaptureFrameNativeDart>('capture_frame_native');
      _getCameraWidth = _dylib
          .lookupFunction<GetCameraWidthNativeC, GetCameraWidthNativeDart>('get_camera_width_native');
      _getCameraHeight = _dylib
          .lookupFunction<GetCameraHeightNativeC, GetCameraHeightNativeDart>('get_camera_height_native');
      _getFrameBufferSize = _dylib
          .lookupFunction<GetFrameBufferSizeNativeC, GetFrameBufferSizeNativeDart>('get_frame_buffer_size_native');
      _deinitCamera = _dylib
          .lookupFunction<DeinitCameraNativeC, DeinitCameraNativeDart>('deinit_camera_native');

      _cameraContext = _initCamera(width, height);
      if (_cameraContext == null || _cameraContext!.address == 0) {
        throw Exception("Failed to initialize native camera.");
      }
      _width = _getCameraWidth(_cameraContext!);
      _height = _getCameraHeight(_cameraContext!);
      _frameBufferSize = _getFrameBufferSize(_cameraContext!);

      if (_width == 0 || _height == 0 || _frameBufferSize == 0) {
        // Something went wrong in native init even if context is non-null
        dispose();
        throw Exception("Native camera returned invalid dimensions or buffer size.");
      }

    } else {
      throw UnsupportedError("Native camera not supported on this platform.");
    }
  }

  int get width => _width;
  int get height => _height;

  // Captures a single frame. Returns Uint8List of YUV bytes or null on failure.
  Uint8List? captureFrame() {
    if (_cameraContext == null || _frameBufferSize == 0) {
      return null;
    }
    final buffer = calloc<Uint8>(_frameBufferSize);
    try {
      int bytesRead = _captureFrame(_cameraContext!, buffer, _frameBufferSize);
      if (bytesRead > 0) {
        return buffer.asTypedList(bytesRead);
      }
      return null;
    } finally {
      calloc.free(buffer);
    }
  }

  void dispose() {
    if (_cameraContext != null) {
      _deinitCamera(_cameraContext!);
      _cameraContext = null; // Clear context after disposal
    }
  }
}