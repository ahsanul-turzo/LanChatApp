import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/discovery_controller.dart';
import '../widgets/peer_list_item.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DiscoveryController controller = Get.find();
    final ProfileController profileController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Devices'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.refresh, tooltip: 'Refresh'),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Get.toNamed(AppRoutes.conversations),
            tooltip: 'Conversations',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                Obx(
                  () => Text(
                    'Logged in as: ${profileController.profile?.userName ?? "Unknown"}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Gap(4),
                Obx(
                  () => Text(
                    'Device: ${profileController.profile?.deviceName ?? "Unknown"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.isScanning && controller.peers.isEmpty) {
              return const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator(), Gap(16), Text('Scanning for devices...')],
                  ),
                ),
              );
            }

            if (controller.error.isNotEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                      const Gap(16),
                      Text(
                        controller.error,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      ElevatedButton.icon(
                        onPressed: controller.refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.peers.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.devices_other, size: 64, color: Theme.of(context).disabledColor),
                      const Gap(16),
                      Text('No devices found', style: Theme.of(context).textTheme.titleMedium),
                      const Gap(8),
                      Text(
                        'Make sure other devices are on the same network',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      ElevatedButton.icon(
                        onPressed: controller.refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.peers.length,
                  separatorBuilder: (context, index) => const Gap(8),
                  itemBuilder: (context, index) {
                    final peer = controller.peers[index];
                    return PeerListItem(peer: peer, onTap: () => controller.selectPeer(peer));
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
