import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/dashboard_model.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:leaf_cloud/providers/iot_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final configProvider = context.read<ConfigProvider>();
    await configProvider.fetchConfigs();
    
    final activeConfig = configProvider.activeConfig;
    if (activeConfig != null && mounted) {
      context.read<IotProvider>().fetchDashboard(activeConfig.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer2<ConfigProvider, IotProvider>(
          builder: (context, configProvider, iotProvider, child) {
            if (configProvider.isLoading || iotProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final activeConfig = configProvider.activeConfig;
            if (activeConfig == null) {
              return const Center(
                child: Text('No active reservoir configuration found.\nPlease set up a reservoir first.'),
              );
            }

            final data = iotProvider.dashboardData;
            if (data == null) {
              return const Center(
                child: Text('No monitoring data available for this reservoir.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.tankName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Last updated: ${data.lastUpdated.hour}:${data.lastUpdated.minute}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      _buildStatusBadge(data.healthStatus),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lettuce Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Image.network(
                        data.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Advisory Section
                  if (data.advisory != null) _buildAdvisoryCard(data.advisory!),
                  const SizedBox(height: 24),

                  // Telemetry Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildTelemetryCard('pH', data.telemetry.ph.toStringAsFixed(1), Icons.water_drop, Colors.blue),
                      _buildTelemetryCard('EC', data.telemetry.ec.toStringAsFixed(2), Icons.bolt, Colors.orange),
                      _buildTelemetryCard('Temp', '${data.telemetry.waterTemp}°C', Icons.thermostat, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Alert Section (Top-up)
                  if (data.alert != null) _buildAlertCard(data.alert!),
                  const SizedBox(height: 24),

                  // Estimated Nutrients
                  _buildSectionTitle('Estimated Nutrients (AI)'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildNutrientRow('Total Estimated Mass', data.estimatedNutrients.totalEstimatedGrams, isTotal: true),
                        const Divider(height: 24),
                        _buildNutrientRow('Nitrogen (N)', data.estimatedNutrients.nGrams),
                        _buildNutrientRow('Phosphorus (P)', data.estimatedNutrients.pGrams),
                        _buildNutrientRow('Potassium (K)', data.estimatedNutrients.kGrams),
                        const SizedBox(height: 12),
                        Text(
                          'Profile: ${data.profileDetected}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdvisoryCard(AdvisoryInsight advisory) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4E7A43),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                advisory.summary,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            advisory.explanation,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advisory.farmerAction,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status.toLowerCase() == 'healthy' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTelemetryCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(ActionableAlert alert) {
    final isWarning = alert.level.toLowerCase() == 'warning';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.amber[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isWarning ? Colors.amber : Colors.blue),
      ),
      child: Row(
        children: [
          Icon(isWarning ? Icons.warning_amber_rounded : Icons.info_outline, color: isWarning ? Colors.amber[900] : Colors.blue[900]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top-up Required',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(alert.message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E7A43)),
    );
  }

  Widget _buildNutrientRow(String label, double grams, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${grams.toStringAsFixed(2)} g',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF4E7A43) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
