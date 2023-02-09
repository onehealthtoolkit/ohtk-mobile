import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/ui/login/qr_login_view_model.dart';
import 'package:stacked/stacked.dart';

class QrLoginView extends StatelessWidget {
  const QrLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QrLoginViewModel>.reactive(
      viewModelBuilder: () => QrLoginViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(title: const Text('QR Code Login')),
        body: Stack(
          children: [
            MobileScanner(
              allowDuplicates: false,
              controller: MobileScannerController(
                  facing: CameraFacing.back, torchEnabled: false),
              onDetect: (barcode, args) async {
                if (barcode.rawValue == null) {
                  Navigator.pop(context, 'Failed to scan QRCode');
                } else {
                  final String code = barcode.rawValue!;
                  final error = await viewModel.authenticate(code);
                  Navigator.pop(context, error);
                }
              },
            ),
            _framer(context),
            if (viewModel.isBusy) _waitingProgress(context),
          ],
        ),
      ),
    );
  }

  Center _waitingProgress(BuildContext context) {
    return Center(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black45,
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            OhtkProgressIndicator(size: 80),
            SizedBox(height: 16),
            Text(
              "Please wait...",
              textScaleFactor: 1.3,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Center _framer(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 250,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.shade300,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
