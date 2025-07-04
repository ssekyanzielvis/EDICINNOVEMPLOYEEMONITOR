import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../provider/auth_provider.dart';
import '../provider/attendance_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  bool _hasLocationPermission = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String? _lastScannedCode;
  static const _scanCooldown = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;
    setState(() {
      _hasCameraPermission = cameraStatus.isGranted;
      _hasLocationPermission = locationStatus.isGranted;
    });
    if (!_hasCameraPermission || !_hasLocationPermission) {
      await _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final cameraResult = await Permission.camera.request();
    final locationResult = await Permission.location.request();
    setState(() {
      _hasCameraPermission = cameraResult.isGranted;
      _hasLocationPermission = locationResult.isGranted;
    });
    if (!_hasCameraPermission) {
      _showPermissionDialog('Camera permission is required to scan QR codes.');
    }
    if (!_hasLocationPermission) {
      _showPermissionDialog(
        'Location permission is required for attendance tracking.',
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!_isProcessing &&
          scanData.code != null &&
          scanData.code != _lastScannedCode) {
        _lastScannedCode = scanData.code;
        await Future.delayed(_scanCooldown); // Cooldown to prevent rapid scans
        if (!_isProcessing && mounted) {
          _processQRCode(scanData.code!);
        }
      }
    });
    _updateCameraState();
  }

  Future<void> _updateCameraState() async {
    if (controller != null) {
      _isFlashOn = (await controller!.getFlashStatus())!;
      _isFrontCamera = await controller!.getCameraInfo() == CameraFacing.front;
      if (mounted) setState(() {});
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    if (!_hasCameraPermission || !_hasLocationPermission) {
      _showErrorDialog(
        'Permissions not granted. Please enable camera and location.',
      );
      setState(() => _isProcessing = false);
      return;
    }

    try {
      // Get current location with higher accuracy and timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Unable to retrieve location in time.');
        },
      );

      final authProvider = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();

      if (authProvider.currentEmployee == null) {
        throw Exception('Employee not found. Please log in again.');
      }

      final success = await attendanceProvider.scanQRCode(
        employeeId: authProvider.currentEmployee!.id,
        qrCodeData: qrCode,
        position: position,
      );

      if (mounted) {
        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(
            attendanceProvider.errorMessage ?? 'Failed to record attendance.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(_getErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _getErrorMessage(dynamic e) {
    if (e is PermissionDeniedException) {
      return 'Location permission denied. Please enable it in settings.';
    } else if (e.toString().contains('timeout')) {
      return 'Location retrieval timed out. Check your connection or GPS.';
    } else if (e.toString().contains('Employee not found')) {
      return 'Employee data unavailable. Please log in again.';
    }
    return 'Error: ${e.toString()}';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Attendance recorded successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _showContinueDialog();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showContinueDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Continue Scanning?'),
            content: const Text('Would you like to scan another QR code?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Stay on scanner
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close continue dialog
                  Navigator.of(context).pop(); // Go back to dashboard
                },
                child: const Text('No'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              if (message.contains('permission'))
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Open Settings'),
                ),
            ],
          ),
    );
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _requestPermissions();
                },
                child: const Text('Grant'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body:
          _hasCameraPermission && _hasLocationPermission
              ? Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Colors.blue,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 300,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isProcessing)
                            const CircularProgressIndicator()
                          else
                            const Text(
                              'Position the QR code within the frame to scan',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  await _updateCameraState();
                                },
                                icon: Icon(
                                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                ),
                                tooltip: 'Toggle Flash',
                              ),
                              IconButton(
                                onPressed: () async {
                                  await controller?.flipCamera();
                                  await _updateCameraState();
                                },
                                icon: Icon(
                                  _isFrontCamera
                                      ? Icons.camera_front
                                      : Icons.camera_rear,
                                ),
                                tooltip: 'Flip Camera',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 60, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      'Permissions required to scan QR code.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _requestPermissions,
                      child: const Text('Request Permissions'),
                    ),
                  ],
                ),
              ),
    );
  }
}
