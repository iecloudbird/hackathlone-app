import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hackathlone_app/services/auth_service.dart';
import 'package:hackathlone_app/services/qr_service.dart';
import 'package:hackathlone_app/core/notice.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/common/widgets/secondary_appbar.dart';
import 'package:hackathlone_app/config/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _selectedEventType;
  final AuthService _authService = AuthService();
  final QrService _qrService = QrService();

  final List<String> _eventTypes = [
    'registration',
    'lunch',
    'dinner',
    'welcome_session',
    'keynote',
    'workshop',
    'networking',
    'closing_ceremony',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is admin
    if (authProvider.userProfile?.role != 'admin') {
      return Scaffold(
        backgroundColor: const Color(0xFF000613),
        appBar: AppBar(
          title: Text(AppStrings.accessDeniedTitle),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            AppStrings.accessDeniedMessage,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000613),
      appBar: SecondaryAppBar(
        title: AppStrings.qrScanTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Type Selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Event Type:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedEventType,
                  dropdownColor: const Color(0xFF040D22),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF040D22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.electricBlue,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ),
                  hint: const Text(
                    'Choose event type',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEventType = newValue;
                    });
                  },
                  items: _eventTypes.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Camera Scanner
          Expanded(
            child: _selectedEventType == null
                ? const Center(
                    child: Text(
                      'Please select an event type to start scanning',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Stack(
                    children: [
                      MobileScanner(
                        controller: cameraController,
                        onDetect: _onQrCodeDetected,
                      ),
                      if (_isScanning)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.electricBlue,
                            ),
                          ),
                        ),
                      // Scanning overlay
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.electricBlue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _selectedEventType == null
                  ? 'Select event type above to enable scanning'
                  : 'Point camera at QR code to scan for $_selectedEventType',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onQrCodeDetected(BarcodeCapture capture) async {
    if (_isScanning || _selectedEventType == null) return;

    final List<Barcode> barcodes = capture.barcodes;
    final barcode = barcodes.first;

    if (barcode.rawValue == null) {
      showSnackBar(context, 'Failed to scan QR code.');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      // First, try to get user profile by QR code (for participant QR codes)
      final userProfile = await _authService.getUserProfileByQrCode(
        barcode.rawValue!,
      );

      if (userProfile != null) {
        // This is a participant's QR code from their profile
        await _handleParticipantQrCode(userProfile, barcode.rawValue!);
      } else {
        // Try to get from qr_codes table (for event-specific QR codes)
        final qrCode = await _authService.fetchQrCode(barcode.rawValue!);

        if (qrCode != null) {
          await _handleEventQrCode(qrCode);
        } else {
          showSnackBar(context, 'Invalid QR code.');
        }
      }
    } catch (e) {
      showSnackBar(context, 'Error processing QR code: $e');
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _handleParticipantQrCode(
    dynamic userProfile,
    String qrCodeValue,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminId = authProvider.user?.id;

      if (adminId == null) {
        showSnackBar(context, 'Admin user not found');
        return;
      }

      // Check if participant has already been scanned for this event
      final alreadyScanned = await _qrService.hasParticipantBeenScanned(
        userProfile.id,
        _selectedEventType!,
      );

      if (alreadyScanned) {
        showSnackBar(
          context,
          '${userProfile.fullName ?? 'Participant'} has already been scanned for $_selectedEventType',
        );
        return;
      }

      // Create scan record
      await _qrService.createQrScanRecord(
        participantId: userProfile.id,
        adminId: adminId,
        eventType: _selectedEventType!,
        qrCodeValue: qrCodeValue,
      );

      showSuccessSnackBar(
        context,
        '✅ ${userProfile.fullName ?? 'Participant'} checked in for $_selectedEventType!',
      );
    } catch (e) {
      showSnackBar(context, 'Error processing participant QR code: $e');
    }
  }

  Future<void> _handleEventQrCode(dynamic qrCode) async {
    if (qrCode.used) {
      showSnackBar(context, 'This QR code has already been used.');
      return;
    }

    try {
      await _authService.markQrCodeAsUsed(qrCode.id, _selectedEventType!);
      showSuccessSnackBar(
        context,
        'QR code scanned successfully for $_selectedEventType!',
      );
    } catch (e) {
      showSnackBar(context, 'Error marking QR code as used: $e');
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
