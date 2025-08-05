import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/qr_scan_provider.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/common/widgets/secondary_appbar.dart';
import 'package:hackathlone_app/common/widgets/animated_expandable_panel.dart';
import 'package:hackathlone_app/router/app_routes.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  String selectedScanType = 'checkin';
  String? selectedEventId;
  bool isScanning = false;
  bool isControlsExpanded = false;

  // Simplified scan type options - events will be loaded from Supabase
  final Map<String, String> scanTypeOptions = {
    'checkin': 'Registration Check-in',
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    print('🚀 QR Scan Page: Loading events...');
    final qrProvider = Provider.of<QrScanProvider>(context, listen: false);
    await qrProvider.loadActiveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, QrScanProvider>(
      builder: (context, authProvider, qrProvider, child) {
        // Check if user is admin
        if (!authProvider.isAdmin) {
          return Scaffold(
            appBar: AppBarWithBack(title: 'QR Scanner'),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000613),
                    Color(0xFF030B21),
                    Color(0xFF040D22),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'Access denied. Admin privileges required.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.pushReplacement(AppRoutes.home);
            }
          },
          child: Scaffold(
            appBar: AppBarWithBack(
              title: 'QR Code Scanner',
              actions: [
                if (qrProvider.lastScanResult != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () => qrProvider.clearLastScanResult(),
                  ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000613),
                    Color(0xFF030B21),
                    Color(0xFF040D22),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // QR Scanner (Full Screen)
                  if (_canStartScanning())
                    Container(
                      margin: AppDimensions.paddingAll16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(onDetect: _onQrCodeDetected),
                      ),
                    )
                  else
                    _buildInstructionScreen(),

                  // Floating Controls Panel at Bottom with safe area
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: SafeArea(
                      child: _buildAnimatedControlsPanel(qrProvider),
                    ),
                  ),

                  // Last Scan Result Overlay (Top)
                  if (qrProvider.lastScanResult != null)
                    Positioned(
                      top: 20,
                      left: 16,
                      right: 16,
                      child: _buildLastScanResultCard(qrProvider),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: AppColors.brightYellow),
          AppDimensions.verticalSpaceL,
          Padding(
            padding: AppDimensions.paddingAll24,
            child: Text(
              _getInstructionText(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedControlsPanel(QrScanProvider qrProvider) {
    final additionalControls = <Widget>[];
    // Only show event selection for non-meal||checkin scan types (basically everything we're using lol, placing this here incase this qr scanning scales in the future)
    if (!['breakfast', 'lunch', 'dinner'].contains(selectedScanType) &&
        selectedScanType != 'checkin') {
      additionalControls.addAll([
        Text(
          'Event',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        AppDimensions.verticalSpaceS,
        if (qrProvider.isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.brightYellow),
          )
        else
          _buildEventSelector(qrProvider),
      ]);
    }

    return QrScannerControlsPanel(
      selectedScanType: selectedScanType,
      scanTypeOptions: scanTypeOptions,
      isExpanded: isControlsExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          isControlsExpanded = expanded;
        });
      },
      onScanTypeChanged: (scanType) {
        setState(() {
          selectedScanType = scanType;
          selectedEventId = null;
        });
      },
      additionalControls: additionalControls,
      errorMessage: qrProvider.error,
    );
  }

  Widget _buildEventSelector(QrScanProvider qrProvider) {
    final availableEvents = qrProvider.activeEvents
        .where((event) => event.eventType == selectedScanType)
        .toList();

    if (availableEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Text(
          'No events available for ${scanTypeOptions[selectedScanType]}',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.brightYellow.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedEventId,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'Select event',
          hintStyle: TextStyle(color: Colors.white54),
        ),
        dropdownColor: AppColors.maastrichtBlue,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        items: availableEvents
            .map(
              (event) =>
                  DropdownMenuItem(value: event.id, child: Text(event.name)),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedEventId = value;
          });
        },
      ),
    );
  }

  Widget _buildLastScanResultCard(QrScanProvider qrProvider) {
    final result = qrProvider.lastScanResult!;
    final isSuccess = result.success;

    print('🐛 QR Code Value: ${result.message}');

    return Container(
      padding: AppDimensions.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.pineTree.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.red.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 20,
              ),
              AppDimensions.horizontalSpaceS,
              Expanded(
                child: Text(
                  isSuccess ? 'Scan Successful!' : 'Scan Failed',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => qrProvider.clearLastScanResult(),
              ),
            ],
          ),
          AppDimensions.verticalSpaceS,
          Text(
            result.message,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          if (result.fullName != null) ...[
            AppDimensions.verticalSpaceXS,
            Text(
              'User: ${result.fullName}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
          if (result.remainingAllowance != null) ...[
            AppDimensions.verticalSpaceXS,
            Text(
              'Remaining: ${result.remainingAllowance}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  bool _canStartScanning() {
    if (selectedScanType == 'checkin' ||
        ['breakfast', 'lunch', 'dinner'].contains(selectedScanType)) {
      return true;
    }
    return selectedEventId != null;
  }

  String _getInstructionText() {
    // Only non-meal, non-checkin scan types need event selection
    if (![
      'checkin',
      'breakfast',
      'lunch',
      'dinner',
    ].contains(selectedScanType)) {
      if (selectedEventId == null) {
        return 'Please select an event for ${scanTypeOptions[selectedScanType]} before scanning.';
      }
    }
    return 'Position the QR code within the camera frame to scan.\n\nExpand the controls below to change scan type.';
  }

  void _onQrCodeDetected(BarcodeCapture capture) async {
    if (isScanning) return; // Prevent multiple scans

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null || qrCode.isEmpty) return;

    print('🔍 QR Detected: $qrCode');
    print('📋 Scan Type: $selectedScanType');
    print('🎯 Event ID: $selectedEventId');

    setState(() {
      isScanning = true;
    });

    try {
      final qrProvider = Provider.of<QrScanProvider>(context, listen: false);

      await qrProvider.processQrScan(
        qrCode: qrCode,
        scanType: selectedScanType,
        eventId: selectedEventId,
      );

      // Auto-collapse controls after successful scan
      if (qrProvider.lastScanResult?.success == true) {
        setState(() {
          isControlsExpanded = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(qrProvider.lastScanResult!.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ QR Scan Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }
}
