import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ScanningIndicator extends StatelessWidget {
  final String message;

  const ScanningIndicator({super.key, this.message = 'Scanning for devices...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
          const Gap(24),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          Text(
            'This may take a few moments',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
