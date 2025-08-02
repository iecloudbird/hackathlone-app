import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hackathlone_app/services/auth_service.dart';
import 'package:hackathlone_app/core/notice.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userProfile?.role != 'admin') {
      return Scaffold(
        body: Center(
          child: Text(
            'Access Denied. Only admins can scan QR codes.',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      body: MobileScanner(
        // onDetect: (barcode, args) async {
        //   if (barcode.rawValue == null) {
        //     showSnackBar(context, 'Failed to scan QR code.');
        //     return;
        //   }
        //   final qrCode = await AuthService().fetchQrCode(barcode.rawValue!);
        //   if (qrCode != null && !qrCode.used) {
        //     await AuthService().markQrCodeAsUsed(qrCode.id);
        //     showSuccessSnackBar(
        //       context,
        //       'QR code scanned successfully for ${qrCode.type}!',
        //     );
        //   } else if (qrCode?.used ?? true) {
        //     showSnackBar(context, 'This QR code has already been used.');
        //   } else {
        //     showSnackBar(context, 'Invalid QR code.');
        //   }
        // },
      ),
    );
  }
}
