import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';

/// Utility class for displaying QR codes in modals and other contexts
class QrUtils {
  /// Shows a QR code in a modal dialog
  ///
  /// [context] - The build context
  /// [qrData] - The data to encode in the QR code
  /// [title] - The title to display above the QR code (defaults to 'Your QR Code')
  /// [size] - The size of the QR code (defaults to 200.0)
  static void showQrCodeModal({
    required BuildContext context,
    required String qrData,
    String title = 'Your QR Code',
    double size = 200.0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: AppColors.deepBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: AppDimensions.paddingAll24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
              ),
              AppDimensions.verticalSpaceL,
              Container(
                padding: AppDimensions.paddingAll16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: size,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              AppDimensions.verticalSpaceL,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.brightYellow,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a QR code modal with error handling for null or empty data
  ///
  /// [context] - The build context
  /// [qrData] - The data to encode (can be null)
  /// [title] - The title to display above the QR code
  /// [errorMessage] - Message to show if QR data is invalid
  /// [size] - The size of the QR code
  static void showQrCodeModalSafe({
    required BuildContext context,
    String? qrData,
    String title = 'Your QR Code',
    String errorMessage = 'QR Code not available',
    double size = 200.0,
  }) {
    if (qrData == null || qrData.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return;
    }

    showQrCodeModal(context: context, qrData: qrData, title: title, size: size);
  }

  /// Creates a QR code widget for inline display
  ///
  /// [qrData] - The data to encode in the QR code
  /// [size] - The size of the QR code
  /// [backgroundColor] - Background color of the QR code
  /// [foregroundColor] - Foreground color of the QR code
  static Widget buildQrCodeWidget({
    required String qrData,
    double size = 200.0,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ),
    );
  }
}
