class FirstTimeActionKeys {
  static const String firstCarBuy = 'first_car_buy';
  static const String firstCarSell = 'first_car_sell';
  static const String firstExpertise = 'first_expertise';
  static const String firstCarWash = 'first_car_wash';
  static const String firstPartRepair = 'first_part_repair';
  static const String firstNegotiationWin = 'first_negotiation_win';
  static const String firstStaffHire = 'first_staff_hire';
  static const String firstSmsInquiry = 'first_sms_inquiry';
  static const String firstTuning = 'first_tuning';
  static const String firstBankDeposit = 'first_bank_deposit';

  static String getDisplayName(String key) {
    switch (key) {
      case firstCarBuy:
        return 'İlk Araç Satın Alma';
      case firstCarSell:
        return 'İlk Araç Satışı';
      case firstExpertise:
        return 'İlk Ekspertiz Raporu';
      case firstCarWash:
        return 'İlk Oto Yıkama & Detailing';
      case firstPartRepair:
        return 'İlk Parça Onarımı';
      case firstNegotiationWin:
        return 'İlk Başarılı Pazarlık';
      case firstStaffHire:
        return 'İlk Personel İstihdamı';
      case firstSmsInquiry:
        return 'İlk 5664 Tramer Sorgusu';
      case firstTuning:
        return 'İlk Tuning & Modifiye';
      case firstBankDeposit:
        return 'İlk Banka Yatırımı';
      default:
        return 'İlk Başarı';
    }
  }
}
