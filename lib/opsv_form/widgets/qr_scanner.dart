part of 'widgets.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool detected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
                facing: CameraFacing.back, torchEnabled: false),
            onDetect: (barcodeCapture) {
              if (detected) return;

              String? result;
              if (barcodeCapture.barcodes.isNotEmpty) {
                result = barcodeCapture.barcodes.first.rawValue;
                Navigator.pop(context, result);

                setState(() {
                  detected = true;
                });
              }
            },
          ),
          const ScannerMaskOverlay(),
        ],
      ),
    );
  }
}
