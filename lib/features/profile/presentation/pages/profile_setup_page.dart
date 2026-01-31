import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lan_chat_app/core/network/network_manager.dart';
import 'package:lan_chat_app/features/profile/presentation/controllers/profile_controller.dart';

import '../../../../routes/app_routes.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _deviceNameController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).primaryColor),
                      const Gap(16),
                      Text(
                        'Welcome to LAN Chat',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),
                      Text(
                        'Set up your profile to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const Gap(32),
                      TextFormField(
                        controller: _userNameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: _deviceNameController,
                        decoration: const InputDecoration(
                          labelText: 'Device Name',
                          hintText: 'e.g., My Laptop',
                          prefixIcon: Icon(Icons.computer),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a device name';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        initialValue: '192.168.20.12',
                        decoration: const InputDecoration(
                          labelText: 'Your IP Address (for LAN chat)',
                          hintText: 'e.g., 192.168.20.12',
                          prefixIcon: Icon(Icons.wifi),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your IP address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (value != null) {
                            final NetworkManager networkManager = Get.find();
                            networkManager.setIpFromServer(value.trim());
                          }
                        },
                      ),
                      const Gap(24),
                      Obx(() {
                        if (controller.error.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              controller.error,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save(); // Save IP

                                    final success = await controller.createProfile(
                                      userName: _userNameController.text.trim(),
                                      deviceName: _deviceNameController.text.trim(),
                                    );

                                    if (success) {
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      Get.offAllNamed(AppRoutes.discovery);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: controller.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
