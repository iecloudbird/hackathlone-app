import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/qr_scan_provider.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedEventId;
  String selectedScanType = 'checkin';
  bool isScanning = false;

  final Map<String, String> scanTypeOptions = {
    'checkin': 'Event Check-in',
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
            appBar: AppBar(
              title: const Text('QR Scanner'),
              backgroundColor: AppColors.deepBlue,
            ),
            body: const Center(
              child: Text(
                'Access denied. Admin privileges required.',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('QR Code Scanner'),
            backgroundColor: AppColors.deepBlue,
            actions: [
              if (qrProvider.lastScanResult != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => qrProvider.clearLastScanResult(),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                // Scan Configuration Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.pineTree,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scan Type Selection
                      Text(
                        'Scan Type',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedScanType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.maastrichtBlue,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: AppColors.maastrichtBlue,
                        style: const TextStyle(color: Colors.white),
                        items: scanTypeOptions.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedScanType = value!;
                            // Reset event selection when scan type changes
                            if ([
                              'breakfast',
                              'lunch',
                              'dinner',
                            ].contains(value)) {
                              selectedEventId = null;
                            }
                          });
                        },
                      ),

                      // Event Selection (for meal types)
                      if ([
                        'breakfast',
                        'lunch',
                        'dinner',
                      ].contains(selectedScanType)) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Event',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (qrProvider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          DropdownButtonFormField<String>(
                            value: selectedEventId,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.maastrichtBlue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Select event',
                              hintStyle: const TextStyle(color: Colors.white54),
                            ),
                            dropdownColor: AppColors.maastrichtBlue,
                            style: const TextStyle(color: Colors.white),
                            items: qrProvider.activeEvents
                                .where(
                                  (event) => event.type == selectedScanType,
                                )
                                .map(
                                  (event) => DropdownMenuItem(
                                    value: event.id,
                                    child: Text(event.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedEventId = value;
                              });
                            },
                          ),
                      ],

                      // Error Display
                      if (qrProvider.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            qrProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],

                      // Last Scan Result
                      if (qrProvider.lastScanResult != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: qrProvider.lastScanResult!.success
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: qrProvider.lastScanResult!.success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                qrProvider.lastScanResult!.success
                                    ? 'Success!'
                                    : 'Scan Failed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: qrProvider.lastScanResult!.success
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                qrProvider.lastScanResult!.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (qrProvider.lastScanResult!.fullName !=
                                  null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'User: ${qrProvider.lastScanResult!.fullName}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                              if (qrProvider
                                      .lastScanResult!
                                      .remainingAllowance !=
                                  null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Remaining Allowances: ${qrProvider.lastScanResult!.remainingAllowance}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                              if (qrProvider.lastScanResult!.isCheckedIn !=
                                  null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Check-in Status: ${qrProvider.lastScanResult!.isCheckedIn! ? "Checked In" : "Not Checked In"}',
                                  style: TextStyle(
                                    color:
                                        qrProvider.lastScanResult!.isCheckedIn!
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // QR Scanner
                Expanded(
                  child: _canStartScanning()
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: MobileScanner(onDetect: _onQrCodeDetected),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getInstructionText(),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canStartScanning() {
    if (['breakfast', 'lunch', 'dinner'].contains(selectedScanType)) {
      return selectedEventId != null;
    }
    return true; // For check-in, no event selection needed
  }

  String _getInstructionText() {
    if (['breakfast', 'lunch', 'dinner'].contains(selectedScanType)) {
      if (selectedEventId == null) {
        return 'Please select an event before scanning QR codes for ${scanTypeOptions[selectedScanType]}.';
      }
    }
    return 'Position the QR code within the camera frame to scan.';
  }

  void _onQrCodeDetected(BarcodeCapture capture) async {
    if (isScanning) return; // Prevent multiple scans

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null || qrCode.isEmpty) return;

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

      // Show feedback
      if (qrProvider.lastScanResult?.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(qrProvider.lastScanResult!.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // Add delay before allowing next scan
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }
}
