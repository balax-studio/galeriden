import 'package:flutter/material.dart';
import '../side_business_detail_screen.dart';

/// Lightweight wrapper delegating directly to [SideBusinessDetailScreen]
/// eliminating duplicated business logic, calculations, and UI components.
class SideBusinessDetailSheet extends StatelessWidget {
  final String businessId;

  const SideBusinessDetailSheet({super.key, required this.businessId});

  static Future<void> show(BuildContext context, String businessId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SideBusinessDetailSheet(businessId: businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.92,
        child: SideBusinessDetailScreen(businessId: businessId),
      ),
    );
  }
}
