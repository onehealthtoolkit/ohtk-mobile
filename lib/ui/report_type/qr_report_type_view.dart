import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/components/qr_scanner_parts.dart';
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
                if (context.mounted) {
                  Navigator.pop(context, reportType);
                }
              },
            ),
            const ScannerMaskOverlay(),
            if (viewModel.isBusy) const ScannerWaitingProgress(),
          ],
        ),
      ),
    );
  }
}
