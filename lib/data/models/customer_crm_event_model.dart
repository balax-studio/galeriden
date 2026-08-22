import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum CustomerCrmEventType {
  happyVipReferral,
  hiddenDefectDispute,
  collectorAppreciation,
  modEnthusiastFeedback,
  movieProducerRentalDeal,
  cargoFleetDeal,
  diplomaticEmbassyEscort,
  gurbetciExportThankYou,
  mechanicApprenticePraise,
  socialMediaInfluencerReview,
}

enum CrmResolutionChoice {
  generousRepair,
  firmContract,
  discountedTradeIn,
}

class CustomerCrmEventModel {
  final String id;
  final String customerName;
  final String carModelName;
  final CustomerCrmEventType type;
  final String title;
  final String description;
  final double financialImpact;
  final int reputationImpact;
  final int triggerDay;

  const CustomerCrmEventModel({
    required this.id,
    required this.customerName,
    required this.carModelName,
    required this.type,
    required this.title,
    required this.description,
    required this.financialImpact,
    required this.reputationImpact,
    required this.triggerDay,
  });

  IconData get icon {
    switch (type) {
      case CustomerCrmEventType.happyVipReferral:
        return Icons.person_add_alt_1_rounded;
      case CustomerCrmEventType.hiddenDefectDispute:
        return Icons.report_problem_rounded;
      case CustomerCrmEventType.collectorAppreciation:
        return Icons.military_tech_rounded;
      case CustomerCrmEventType.modEnthusiastFeedback:
        return Icons.speed_rounded;
      case CustomerCrmEventType.movieProducerRentalDeal:
        return Icons.movie_filter_rounded;
      case CustomerCrmEventType.cargoFleetDeal:
        return Icons.local_shipping_rounded;
      case CustomerCrmEventType.diplomaticEmbassyEscort:
        return Icons.account_balance_rounded;
      case CustomerCrmEventType.gurbetciExportThankYou:
        return Icons.flight_takeoff_rounded;
      case CustomerCrmEventType.mechanicApprenticePraise:
        return Icons.handshake_rounded;
      case CustomerCrmEventType.socialMediaInfluencerReview:
        return Icons.campaign_rounded;
    }
  }

  Color get accentColor {
    switch (type) {
      case CustomerCrmEventType.happyVipReferral:
      case CustomerCrmEventType.gurbetciExportThankYou:
        return AppColors.successGreen;
      case CustomerCrmEventType.hiddenDefectDispute:
        return AppColors.errorRed;
      case CustomerCrmEventType.collectorAppreciation:
      case CustomerCrmEventType.diplomaticEmbassyEscort:
        return AppColors.brutalYellow;
      case CustomerCrmEventType.modEnthusiastFeedback:
      case CustomerCrmEventType.movieProducerRentalDeal:
        return const Color(0xFFA855F7);
      case CustomerCrmEventType.cargoFleetDeal:
      case CustomerCrmEventType.mechanicApprenticePraise:
        return AppColors.brutalBlue;
      case CustomerCrmEventType.socialMediaInfluencerReview:
        return AppColors.brutalCyan;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'carModelName': carModelName,
        'type': type.name,
        'title': title,
        'description': description,
        'financialImpact': financialImpact,
        'reputationImpact': reputationImpact,
        'triggerDay': triggerDay,
      };

  factory CustomerCrmEventModel.fromJson(Map<String, dynamic> json) => CustomerCrmEventModel(
        id: json['id'] as String? ?? 'crm_1',
        customerName: json['customerName'] as String? ?? 'Müşteri',
        carModelName: json['carModelName'] as String? ?? 'Araç',
        type: CustomerCrmEventType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CustomerCrmEventType.happyVipReferral,
        ),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        financialImpact: (json['financialImpact'] as num?)?.toDouble() ?? 0.0,
        reputationImpact: (json['reputationImpact'] as num?)?.toInt() ?? 0,
        triggerDay: (json['triggerDay'] as num?)?.toInt() ?? 1,
      );

  static CustomerCrmEventModel generateRandom({
    required String carName,
    required int currentDay,
    String bodyType = 'Sedan',
    bool isRare = false,
    bool isOverTuned = false,
    Random? random,
  }) {
    final rand = random ?? Random();
    
    // Segment / attribute biased selection
    final List<CustomerCrmEventType> candidateTypes = [
      CustomerCrmEventType.happyVipReferral,
      CustomerCrmEventType.hiddenDefectDispute,
      CustomerCrmEventType.gurbetciExportThankYou,
      CustomerCrmEventType.mechanicApprenticePraise,
    ];

    if (isRare || carName.contains('Klasik') || carName.contains('Murat') || carName.contains('Mercedes')) {
      candidateTypes.add(CustomerCrmEventType.collectorAppreciation);
      candidateTypes.add(CustomerCrmEventType.movieProducerRentalDeal);
    }
    if (isOverTuned || bodyType == 'Coupe' || bodyType == 'Cabrio') {
      candidateTypes.add(CustomerCrmEventType.modEnthusiastFeedback);
      candidateTypes.add(CustomerCrmEventType.socialMediaInfluencerReview);
    }
    if (bodyType == 'Van' || bodyType == 'Station' || bodyType == 'Hatchback') {
      candidateTypes.add(CustomerCrmEventType.cargoFleetDeal);
    }
    if (bodyType == 'Sedan' || bodyType == 'SUV') {
      candidateTypes.add(CustomerCrmEventType.diplomaticEmbassyEscort);
    }

    final type = candidateTypes[rand.nextInt(candidateTypes.length)];

    switch (type) {
      case CustomerCrmEventType.happyVipReferral:
        return CustomerCrmEventModel(
          id: 'crm_vip_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Müteahhit Haldun Bey',
          carModelName: carName,
          type: type,
          title: 'ZENGİN ALICI YÖNLENDİRMESİ',
          description: 'Sattığın $carName ile çok mutlu olan Haldun Bey, iş ortağını da senin galerine getirdi. Galerine özel VIP teklifler tanımlandı!',
          financialImpact: 150000.0,
          reputationImpact: 20,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.hiddenDefectDispute:
        return CustomerCrmEventModel(
          id: 'crm_defect_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Memur Serkan Bey',
          carModelName: carName,
          type: type,
          title: 'GİZLİ KUSUR VE ŞANZIMAN İTİRAZI',
          description: 'Serkan Bey aracın şanzımanında vuruntu olduğunu söyleyerek noter ihtarı çekmek üzere kapına geldi. Esnaf duruşun nedir?',
          financialImpact: -15000.0,
          reputationImpact: -15,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.collectorAppreciation:
        return CustomerCrmEventModel(
          id: 'crm_collector_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Koleksiyoner Ferit',
          carModelName: carName,
          type: type,
          title: 'KOLEKSİYONER TEŞEKKÜR HEDİYESİ',
          description: 'Restorasyonunu yaptığın $carName sergide birincilik ödülü aldı. Ferit Bey galeriye özel bir altın plaket ve bahşiş gönderdi.',
          financialImpact: 75000.0,
          reputationImpact: 35,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.modEnthusiastFeedback:
        return CustomerCrmEventModel(
          id: 'crm_mod_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Genç Sürücü Arda',
          carModelName: carName,
          type: type,
          title: 'PİST GÜNÜ VİRAL PAYLAŞIMI',
          description: 'Sattığın $carName sosyal medyada viral oldu! Galerinin adı modifiye çevrelerinde övgüyle anılıyor.',
          financialImpact: 50000.0,
          reputationImpact: 25,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.movieProducerRentalDeal:
        return CustomerCrmEventModel(
          id: 'crm_movie_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Yapımcı Metin Bey',
          carModelName: carName,
          type: type,
          title: 'DİZİ VE FİLM SETİ KİRALAMA KOMİSYONU',
          description: 'Sattığın $carName döneme uygunluğuyla ulusal bir dizide başrol aracına dönüştü. Yapım şirketi sana aracılık komisyonu ödedi.',
          financialImpact: 120000.0,
          reputationImpact: 30,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.cargoFleetDeal:
        return CustomerCrmEventModel(
          id: 'crm_cargo_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Lojistik Müdürü Selçuk',
          carModelName: carName,
          type: type,
          title: 'KARGO VE DAĞITIM FİLOSU SÖZLEŞMESİ',
          description: 'Teslim ettiğin $carName şirket tarafından çok beğenildi. Lojistik filosu için toplu araç danışmanlık primini hesabına yatırdılar.',
          financialImpact: 90000.0,
          reputationImpact: 20,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.diplomaticEmbassyEscort:
        return CustomerCrmEventModel(
          id: 'crm_diplo_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Ataşe Temsilcisi Kerem',
          carModelName: carName,
          type: type,
          title: 'KONSOLOSLUK VE MAKAM REFERANSI',
          description: 'Sattığın $carName yabancı delegasyon heyetine eşlik etti. Protokol çevrelerinden galeriye teşekkür mektubu ve hibe ulaştı.',
          financialImpact: 140000.0,
          reputationImpact: 40,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.gurbetciExportThankYou:
        return CustomerCrmEventModel(
          id: 'crm_gurbet_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Gurbetçi Yılmaz Dayı',
          carModelName: carName,
          type: type,
          title: 'GURBETÇİ MEMLEKET TEŞEKKÜRÜ',
          description: 'Yılmaz Dayı Köln yolculuğunu sorunsuz tamamladı. Galerinin dürüst ustalığına teşekkür olarak Euro bazlı bahşiş gönderdi.',
          financialImpact: 65000.0,
          reputationImpact: 25,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.mechanicApprenticePraise:
        return CustomerCrmEventModel(
          id: 'crm_mech_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Sanayi Dernek Başkanı',
          carModelName: carName,
          type: type,
          title: 'SANAYİ ESNAFI DÜRÜSTLÜK BERATI',
          description: 'Ekspertiz raporu tam tutan $carName sanayi sitesinde günün konusu oldu. Esnaf dayanışma fonundan sana destek aktarıldı.',
          financialImpact: 45000.0,
          reputationImpact: 20,
          triggerDay: currentDay,
        );
      case CustomerCrmEventType.socialMediaInfluencerReview:
        return CustomerCrmEventModel(
          id: 'crm_vlog_${currentDay}_${rand.nextInt(9999)}',
          customerName: 'Otomobil Editörü Kaan',
          carModelName: carName,
          type: type,
          title: 'OTOMOBİL DERGİSİ ÖVGÜ DOLU İNCELEME',
          description: 'Sattığın $carName popüler YouTube kanalında incelendi. Galeri tabelan videoda yer aldı ve organik müşteri trafiği patladı!',
          financialImpact: 80000.0,
          reputationImpact: 35,
          triggerDay: currentDay,
        );
    }
  }
}
