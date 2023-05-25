import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/ui/report_type/qr_report_type_view_model.dart';
import 'package:stacked/stacked.dart';

class QrReportTypeView extends StatelessWidget {
  const QrReportTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QrReportTypeViewModel>.reactive(
      viewModelBuilder: () => QrReportTypeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(title: const Text('QRCode Report Type')),
        body: Stack(
          children: [
            MobileScanner(
              controller: MobileScannerController(
                  facing: CameraFacing.back, torchEnabled: false),
              onDetect: (barcodeCapture) async {
                ReportType? reportType;
                if (barcodeCapture.barcodes.isNotEmpty) {
                  final String? code = barcodeCapture.barcodes.first.rawValue;
                  if (code != null) {
                    reportType = await viewModel.getReportType(code);
                  }
                }
                Navigator.pop(context, reportType);
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
            CircularProgressIndicator(),
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
