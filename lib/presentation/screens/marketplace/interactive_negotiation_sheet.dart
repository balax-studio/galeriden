import 'package:flutter/material.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/vehicle_category.dart';
import '../vasita/vasita_negotiation_screen.dart';
import 'negotiation_screen.dart';

/// Legacy Compatibility Sheet Wrapper
/// Forwards directly to [VasitaNegotiationScreen] or [NegotiationScreen] based on vehicle category.
class InteractiveNegotiationSheet extends StatelessWidget {
  final ListingModel listing;

  const InteractiveNegotiationSheet({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    if (listing.car.vehicleCategory != VehicleCategory.car) {
      return VasitaNegotiationScreen(listing: listing);
    }
    return NegotiationScreen(listing: listing);
  }
}
