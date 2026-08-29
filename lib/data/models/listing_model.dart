import 'package:flutter/widgets.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import 'car_model.dart';

class ListingModel {
  final String id;
  final CarModel car;
  final String sellerName;
  final String sellerTrait;
  final String sellerCity;
  final String title;
  final String description;
  final double askingPrice;
  final bool isExpertiseCompleted;
  final DateTime createdAt;

  // Cultural Localization Keys
  final String? sellerProfileKey;
  final String? sellerNameKey;
  final String? sellerCityKey;
  final String? titlePrefixKey;
  final String? descriptionKey;

  ListingModel({
    required this.id,
    required this.car,
    required this.sellerName,
    required this.sellerTrait,
    required this.sellerCity,
    required this.title,
    required this.description,
    required this.askingPrice,
    this.isExpertiseCompleted = false,
    required this.createdAt,
    this.sellerProfileKey,
    this.sellerNameKey,
    this.sellerCityKey,
    this.titlePrefixKey,
    this.descriptionKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car': car.toJson(),
      'sellerName': sellerName,
      'sellerTrait': sellerTrait,
      'sellerCity': sellerCity,
      'title': title,
      'description': description,
      'askingPrice': askingPrice,
      'isExpertiseCompleted': isExpertiseCompleted,
      'createdAt': createdAt.toIso8601String(),
      if (sellerProfileKey != null) 'sellerProfileKey': sellerProfileKey,
      if (sellerNameKey != null) 'sellerNameKey': sellerNameKey,
      if (sellerCityKey != null) 'sellerCityKey': sellerCityKey,
      if (titlePrefixKey != null) 'titlePrefixKey': titlePrefixKey,
      if (descriptionKey != null) 'descriptionKey': descriptionKey,
    };
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String? ?? 'list_${DateTime.now().millisecondsSinceEpoch}',
      car: json['car'] != null ? CarModel.fromJson(json['car'] as Map<String, dynamic>) : CarModel.fromJson(const {}),
      sellerName: json['sellerName'] as String? ?? 'Satıcı',
      sellerTrait: json['sellerTrait'] as String? ?? 'Sahibinden',
      sellerCity: json['sellerCity'] as String? ?? 'İstanbul',
      title: json['title'] as String? ?? 'İlan',
      description: json['description'] as String? ?? '',
      askingPrice: (json['askingPrice'] as num?)?.toDouble() ?? 0.0,
      isExpertiseCompleted: json['isExpertiseCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      sellerProfileKey: json['sellerProfileKey'] as String?,
      sellerNameKey: json['sellerNameKey'] as String?,
      sellerCityKey: json['sellerCityKey'] as String?,
      titlePrefixKey: json['titlePrefixKey'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
    );
  }

  ListingModel copyWith({
    bool? isExpertiseCompleted,
    String? sellerProfileKey,
    String? sellerNameKey,
    String? sellerCityKey,
    String? titlePrefixKey,
    String? descriptionKey,
  }) {
    return ListingModel(
      id: id,
      car: car,
      sellerName: sellerName,
      sellerTrait: sellerTrait,
      sellerCity: sellerCity,
      title: title,
      description: description,
      askingPrice: askingPrice,
      isExpertiseCompleted: isExpertiseCompleted ?? this.isExpertiseCompleted,
      createdAt: createdAt,
      sellerProfileKey: sellerProfileKey ?? this.sellerProfileKey,
      sellerNameKey: sellerNameKey ?? this.sellerNameKey,
      sellerCityKey: sellerCityKey ?? this.sellerCityKey,
      titlePrefixKey: titlePrefixKey ?? this.titlePrefixKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
    );
  }

  /// Returns fully localized authentic seller title & name (e.g. "Doctor Owned • Meticulous • James W.")
  String getLocalizedSellerName(BuildContext context) {
    final effectiveProfileKey = sellerProfileKey ?? _inferProfileKey(sellerName);
    final effectiveNameKey = sellerNameKey ?? _inferNameKey(sellerName);

    if (effectiveProfileKey != null && effectiveNameKey != null) {
      final profile = context.tr('seller_profile_$effectiveProfileKey');
      final name = context.tr('seller_name_$effectiveNameKey');
      if (profile.isNotEmpty && profile != 'seller_profile_$effectiveProfileKey' &&
          name.isNotEmpty && name != 'seller_name_$effectiveNameKey') {
        return '$profile • $name';
      }
    } else if (effectiveProfileKey != null) {
      final profile = context.tr('seller_profile_$effectiveProfileKey');
      if (profile.isNotEmpty && profile != 'seller_profile_$effectiveProfileKey') {
        return profile;
      }
    }

    return sellerName;
  }

  /// Returns localized seller personality trait / trade stance
  String getLocalizedSellerTrait(BuildContext context) {
    final effectiveProfileKey = sellerProfileKey ?? _inferProfileKey(sellerName);
    if (effectiveProfileKey != null) {
      final trait = context.tr('seller_trait_$effectiveProfileKey');
      if (trait.isNotEmpty && trait != 'seller_trait_$effectiveProfileKey') {
        return trait;
      }
    }
    return sellerTrait;
  }

  /// Returns localized authentic regional city / hub (e.g. "London", "Berlin", "São Paulo", "Madrid")
  String getLocalizedSellerCity(BuildContext context) {
    final effectiveCityKey = sellerCityKey ?? _inferCityKey(sellerCity);
    if (effectiveCityKey != null) {
      final city = context.tr('city_$effectiveCityKey');
      if (city.isNotEmpty && city != 'city_$effectiveCityKey') {
        return city;
      }
    }
    return sellerCity;
  }

  /// Returns localized authentic listing title hook (e.g. "PRISTINE FLAWLESS ORIGINAL • 2021 Tofaşk Şahin-S")
  String getLocalizedTitle(BuildContext context) {
    final baseTitle = '${car.modelYear} ${car.brand} ${car.modelName}';
    final effectivePrefixKey = titlePrefixKey ?? _inferTitlePrefixKey(title);
    if (effectivePrefixKey != null) {
      final prefix = context.tr('title_prefix_$effectivePrefixKey');
      if (prefix.isNotEmpty && prefix != 'title_prefix_$effectivePrefixKey') {
        return '$prefix • $baseTitle';
      }
    }
    return title.isNotEmpty ? title : baseTitle;
  }

  /// Returns localized authentic car selling narrative / excuse across cultures
  String getLocalizedDescription(BuildContext context) {
    final effectiveDescKey = descriptionKey ?? _inferDescriptionKey();
    if (effectiveDescKey != null) {
      final desc = context.tr(effectiveDescKey, {
        'amount': CurrencyFormatter.formatShort(car.expertise.tramerAmount.toDouble()),
      });
      if (desc.isNotEmpty && desc != effectiveDescKey) {
        return desc;
      }
    }
    return description;
  }

  // --- Invariant Fallback Inferences ---

  static String? _inferProfileKey(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('doktor') || lower.contains('hekim')) return 'doctor';
    if (lower.contains('borç')) return 'debt';
    if (lower.contains('acil') || lower.contains('kelepir')) return 'urgent_cash';
    if (lower.contains('takas') || lower.contains('galeri')) return 'trade_in';
    if (lower.contains('koleksiyon')) return 'collector';
    if (lower.contains('memur')) return 'officer';
    if (lower.contains('yurt dış') || lower.contains('gurbet')) return 'abroad';
    if (lower.contains('keyfe')) return 'whim';
    if (lower.contains('öğretmen')) return 'teacher';
    if (lower.contains('asker')) return 'military';
    if (lower.contains('müteahhit')) return 'contractor';
    if (lower.contains('ev al')) return 'house_downpayment';
    if (lower.contains('titiz') || lower.contains('hatasız')) return 'pristine';
    if (lower.contains('samanlık') || lower.contains('terk')) return 'barn_find';
    if (lower.contains('nadir') || lower.contains('kupon')) return 'rare';
    return null;
  }

  static String? _inferNameKey(String text) {
    if (text.contains('Ahmet')) return '1';
    if (text.contains('Mehmet')) return '2';
    if (text.contains('Caner')) return '3';
    if (text.contains('Mustafa')) return '4';
    if (text.contains('Emre')) return '5';
    if (text.contains('Burak')) return '6';
    return '1';
  }

  static String? _inferCityKey(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('istanbul') || lower.contains('ıstanbul')) return 'istanbul';
    if (lower.contains('ankara')) return 'ankara';
    if (lower.contains('izmir') || lower.contains('ızmir')) return 'izmir';
    if (lower.contains('bursa')) return 'bursa';
    if (lower.contains('antalya')) return 'antalya';
    if (lower.contains('adana')) return 'adana';
    if (lower.contains('konya')) return 'konya';
    if (lower.contains('gaziantep') || lower.contains('antep')) return 'gaziantep';
    if (lower.contains('trabzon')) return 'trabzon';
    return null;
  }

  static String? _inferTitlePrefixKey(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('samanlık') || lower.contains('garaj buluntusu')) return 'barn';
    if (lower.contains('hatasız') || lower.contains('sıfır kokusu')) return 'pristine';
    if (lower.contains('koleksiyon') || lower.contains('nadir')) return 'rare';
    if (lower.contains('ilk sahibi')) return 'normal_1';
    if (lower.contains('masrafsız') || lower.contains('dosta')) return 'normal_2';
    if (lower.contains('memur')) return 'normal_3';
    if (lower.contains('bakımları')) return 'normal_4';
    if (lower.contains('aile')) return 'normal_5';
    return null;
  }

  String? _inferDescriptionKey() {
    if (car.isBarnFind) return 'desc_barn_find_1';
    if (car.expertise.isCleanPristine) return 'desc_pristine_1';
    if (car.isRare) return 'desc_rare_collector_1';
    if (car.declarationType == ListingDeclarationType.flawlessClaim) return 'desc_flawless_claim_1';
    if (car.expertise.tramerAmount > 0) return 'desc_honest_with_tramer';
    return 'desc_honest_clean_no_tramer';
  }
}
