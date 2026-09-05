import '../real_estate_model.dart';

/// Substate representing real estate holdings and building expansion
class RealEstateSubstate {
  final List<RealEstateModel> ownedRealEstates;
  final int maxRealEstateSlots;
  final Set<String> unlockedBuildings;

  const RealEstateSubstate({
    this.ownedRealEstates = const [],
    this.maxRealEstateSlots = 5,
    this.unlockedBuildings = const {},
  });

  RealEstateSubstate copyWith({
    List<RealEstateModel>? ownedRealEstates,
    int? maxRealEstateSlots,
    Set<String>? unlockedBuildings,
  }) {
    return RealEstateSubstate(
      ownedRealEstates: ownedRealEstates ?? this.ownedRealEstates,
      maxRealEstateSlots: maxRealEstateSlots ?? this.maxRealEstateSlots,
      unlockedBuildings: unlockedBuildings ?? this.unlockedBuildings,
    );
  }
}
