import 'package:flutter/material.dart';
import '../../../data/models/listing_model.dart';
import 'negotiation_screen.dart';

/// Legacy Compatibility Sheet Wrapper
/// Forwards directly to [NegotiationScreen] for zero frame drops and unified architecture.
class InteractiveNegotiationSheet extends StatelessWidget {
  final ListingModel listing;

  const InteractiveNegotiationSheet({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return NegotiationScreen(listing: listing);
  }
}
