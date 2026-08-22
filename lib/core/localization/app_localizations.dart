import 'package:flutter/widgets.dart';

class AppLocalizations {
  final String languageCode;

  const AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    // ==========================================
    // TÜRKÇE (tr)
    // ==========================================
    'tr': {
      // Genel & Arayüz
      'app_name': 'Galeriden',
      'settings_title': 'AYARLAR & PROFİL',
      'language_select': 'Dil Seçeneği',
      'language_desc': 'Arayüz ve oyun dili',
      'theme_store': 'TEMA & GÖRÜNÜM MAĞAZASI',
      'dealership_identity': 'GALERİ & PROFİL KİMLİĞİ',
      'audio_effects': 'Ses Efektleri',
      'audio_desc': 'Motor ve buton sesleri',
      'dashboard': 'GALERİ VİTRİNİ',
      'garage': 'GARAJ & ENVANTER',
      'showroom': 'SHOWROOM & SATIŞ',
      'scrapyard': 'SANAYİ & HURDALIK',
      'stock_market': 'BORSA & YATIRIM',
      'auction': 'GÜMRÜK MÜZAYEDESİ',
      'staff': 'PERSONEL & AKADEMİ',
      'notary': 'NOTER & DEVİR İŞLEMLERİ',
      'bank': 'ESNAF KREDİSİ & MEVDUAT',
      'night_race': 'GECE YARIŞLARI & BAHİS',
      'missions': 'GÖREVLER & BAŞARIMLAR',
      'level': 'Seviye',
      'reputation': 'İtibar',
      'balance': 'Bakiye',
      'day': 'Gün',
      'garage_slots': 'Garaj Kapasitesi',
      'claim': 'ÖDÜLÜ AL',
      'confirm': 'ONAYLA',
      'cancel': 'İPTAL',
      'close': 'KAPAT',
      'save': 'KAYDET',
      'buy': 'SATIN AL',
      'sell': 'SATIŞA ÇIKAR',
      'clean': 'YIKAMA & DETAYLI TEMİZLİK',
      'repair': 'SANAYİ ONARIMI',
      'tuning': 'VIP TUNING STÜDYOSU',
      'inspect': 'EKSPERTİZ RAPORU',
      'locked': 'KİLİTLİ',
      'unlocked': 'KİLİT AÇILDI',
      'free': 'ÜCRETSİZ',
      'cost': 'Maliyet',
      'duration': 'Süre',

      // Araç Detayları & Ekspertiz
      'mileage': 'Kilometre',
      'year': 'Model Yılı',
      'fuel_type': 'Yakıt Türü',
      'transmission': 'Vites',
      'horsepower': 'Motor Gücü',
      'body_paint': 'Kaporta Durumu',
      'paint_original': 'Hatasız / Boyasız',
      'paint_painted': 'Lokal Boyalı',
      'paint_damaged': 'Ağır Hasarlı',
      'engine_condition': 'Motor Kondisyonu',
      'chassis_condition': 'Şasi Durumu',
      'market_value': 'Piyasa Değeri',
      'listing_price': 'İlan Fiyatı',
      'profit_margin': 'Tahmini Kâr',

      // 28 Günlük Esnaf Takvimi
      'streak_title': '28 GÜNLÜK ESNAF TAKVİMİ',
      'streak_ready': 'SİFTAH HAZIR',
      'streak_wait': 'YARIN GEL',
      'streak_claimed': 'ÖDÜL ALINDI',
      'season_spring': 'İLKBAHAR ÇARŞI SEZONU',
      'season_summer': 'YAZ GURBETÇİ SEZONU',
      'season_autumn': 'SONBAHAR SANAYİ SEZONU',
      'season_winter': 'KIŞ GALERİ AĞALIĞI SEZONU',

      // CRM & Müşteri Olayları
      'crm_title': 'MÜŞTERİ GERİ BİLDİRİMİ',
      'crm_resolve': 'ESNAF KARARINI VER',
      'crm_accept': 'TEKLİFİ KABUL ET',
      'crm_reject': 'REDDET & GÖNDER',
      'crm_happy': 'Memnun Müşteri Teşekkürü',
      'crm_defect': 'Gizli Ayıp Şikayeti',
      'crm_fleet': 'Kargo Filosu Anlaşması',
      'crm_movie': 'Dizi/Film Kiralama Talebi',
      'crm_diplomat': 'Diplomatik Referans Talebi',

      // Borsa & BIST Halka Arz
      'bist_glrd': 'BIST: GLRD',
      'company_ipo': 'HALKA ARZ MASASI',
      'share_buyback': 'PİYASADAN HİSSE GERİ AL',
      'quarterly_report': 'ÇEYREKLİK BİLANÇO',
      'dividend_payout': 'Temettü Ödemesi',
      'stock_portfolio': 'Hisse Portföyü',
      'gold_forex': 'Altın & Döviz Masası',

      // Sanayi & Hurdalık
      'sanayi_rumor': 'GÜNÜN SANAYİ TÜYOSU',
      'zone_ostim': 'Ostim Sanayi Sitesi',
      'zone_maslak': 'Maslak Oto Sanayi',
      'zone_sasmaz': 'Şaşmaz Hurdacılar Sitesi',
      'zone_harabe': 'Eski Terk Edilmiş Fabrika',
      'barn_find': 'Samanlık Buluntusu Efsane',
      'salvage_parts': 'Yedek Parça Sök',

      // Müzayede & Blöf
      'bluff_button': 'BLÖF YAP VE ÇEKİL',
      'auction_bid': 'Teklif Ver',
      'auction_rival_selim': 'Baron Selim',
      'auction_rival_ferit': 'Koleksiyoner Ferit',
      'auction_rival_riza': 'Al-Satçı Rıza',
      'auction_hammer': 'Satıldı!',

      // Personel & Akademi
      'staff_morale': 'Personel Morali',
      'tea_treat': 'ÇAY ISMARLA',
      'meal_treat': 'YEMEK ISMARLA',
      'bonus_treat': 'BAYRAM HARÇLIĞI',
      'staff_washer': 'Yıkama Elemanı',
      'staff_mechanic': 'Oto Tamir Ustası',
      'staff_salesman': 'Kıdemli Satış Temsilcisi',
      'staff_painter': 'Fırın Boya Ustası',
      'staff_security': 'Gece Güvenlik Görevlisi',

      // Noter & Banka
      'notary_contract': 'Araç Devir Sözleşmesi',
      'notary_fee': 'Noter Harcı',
      'safe_payment': 'Güvenli Noter Ödemesi',
      'bank_loan': 'Ticari Esnaf Kredisi',
      'bank_interest': 'Faiz Oranı',
      'bank_repay': 'Kredi Borcunu Kapat',
    },

    // ==========================================
    // ENGLISH (en)
    // ==========================================
    'en': {
      // General & UI
      'app_name': 'Dealership Tycoon',
      'settings_title': 'SETTINGS & PROFILE',
      'language_select': 'Language Option',
      'language_desc': 'Interface & game language',
      'theme_store': 'THEME & APPEARANCE STORE',
      'dealership_identity': 'DEALERSHIP & PROFILE IDENTITY',
      'audio_effects': 'Sound Effects',
      'audio_desc': 'Engine & button sounds',
      'dashboard': 'DEALERSHIP DASHBOARD',
      'garage': 'GARAGE & INVENTORY',
      'showroom': 'SHOWROOM & SALES',
      'scrapyard': 'SCRAPYARD & WORKSHOP',
      'stock_market': 'STOCK MARKET & INVESTMENTS',
      'auction': 'CUSTOMS AUCTION',
      'staff': 'STAFF & ACADEMY',
      'notary': 'NOTARY & TITLE TRANSFER',
      'bank': 'BUSINESS LOANS & DEPOSITS',
      'night_race': 'NIGHT RACES & BETTING',
      'missions': 'MISSIONS & ACHIEVEMENTS',
      'level': 'Level',
      'reputation': 'Reputation',
      'balance': 'Balance',
      'day': 'Day',
      'garage_slots': 'Garage Capacity',
      'claim': 'CLAIM REWARD',
      'confirm': 'CONFIRM',
      'cancel': 'CANCEL',
      'close': 'CLOSE',
      'save': 'SAVE',
      'buy': 'PURCHASE',
      'sell': 'LIST FOR SALE',
      'clean': 'CAR WASH & DETAILING',
      'repair': 'WORKSHOP REPAIR',
      'tuning': 'VIP TUNING STUDIO',
      'inspect': 'INSPECTION REPORT',
      'locked': 'LOCKED',
      'unlocked': 'UNLOCKED',
      'free': 'FREE',
      'cost': 'Cost',
      'duration': 'Duration',

      // Car Details & Inspection
      'mileage': 'Mileage',
      'year': 'Model Year',
      'fuel_type': 'Fuel Type',
      'transmission': 'Transmission',
      'horsepower': 'Horsepower',
      'body_paint': 'Body Paint Condition',
      'paint_original': 'Original / Pristine',
      'paint_painted': 'Partially Repainted',
      'paint_damaged': 'Heavy Salvage Damage',
      'engine_condition': 'Engine Condition',
      'chassis_condition': 'Chassis Integrity',
      'market_value': 'Market Valuation',
      'listing_price': 'Asking Price',
      'profit_margin': 'Estimated Margin',

      // 28-Day Calendar
      'streak_title': '28-DAY BUSINESS CALENDAR',
      'streak_ready': 'DAILY REWARD READY',
      'streak_wait': 'COME BACK TOMORROW',
      'streak_claimed': 'CLAIMED',
      'season_spring': 'SPRING MARKET SEASON',
      'season_summer': 'SUMMER TOURISM SEASON',
      'season_autumn': 'AUTUMN FLEET SEASON',
      'season_winter': 'WINTER TYCOON SEASON',

      // CRM & Customer Events
      'crm_title': 'CUSTOMER CRM EVENT',
      'crm_resolve': 'MAKE RESOLUTION',
      'crm_accept': 'ACCEPT OFFER',
      'crm_reject': 'DECLINE & DISMISS',
      'crm_happy': 'Satisfied VIP Feedback',
      'crm_defect': 'Hidden Defect Claim',
      'crm_fleet': 'Cargo Fleet Partnership',
      'crm_movie': 'Movie Production Rental',
      'crm_diplomat': 'Diplomatic Escort Referral',

      // Stock Market & IPO
      'bist_glrd': 'GLRD HOLDING',
      'company_ipo': 'COMPANY IPO DESK',
      'share_buyback': 'BUY BACK SHARES',
      'quarterly_report': 'QUARTERLY EARNINGS',
      'dividend_payout': 'Dividend Payout',
      'stock_portfolio': 'Equities Portfolio',
      'gold_forex': 'Gold & Forex Trading',

      // Scrapyard & Parts
      'sanayi_rumor': 'DAILY WORKSHOP RUMOR',
      'zone_ostim': 'Ostim Industrial District',
      'zone_maslak': 'Maslak Auto Workshop',
      'zone_sasmaz': 'Sasmaz Salvage Yard',
      'zone_harabe': 'Abandoned Steel Factory',
      'barn_find': 'Barn Find Legendary Asset',
      'salvage_parts': 'Harvest Spare Parts',

      // Auction & Bluff
      'bluff_button': 'BLUFF & BAIL OUT',
      'auction_bid': 'Place Bid',
      'auction_rival_selim': 'Baron Selim',
      'auction_rival_ferit': 'Collector Ferit',
      'auction_rival_riza': 'Flipper Riza',
      'auction_hammer': 'Sold!',

      // Staff & Academy
      'staff_morale': 'Staff Morale',
      'tea_treat': 'BUY COFFEE',
      'meal_treat': 'BUY LUNCH',
      'bonus_treat': 'PERFORMANCE BONUS',
      'staff_washer': 'Detailing Apprentice',
      'staff_mechanic': 'Master Technician',
      'staff_salesman': 'Senior Sales Executive',
      'staff_painter': 'Paint Booth Specialist',
      'staff_security': 'Night Guard',

      // Notary & Banking
      'notary_contract': 'Vehicle Sales Contract',
      'notary_fee': 'Registration Tax',
      'safe_payment': 'Escrow Secured Transfer',
      'bank_loan': 'Commercial Credit Line',
      'bank_interest': 'Interest Rate',
      'bank_repay': 'Repay Outstanding Debt',
    },

    // ==========================================
    // GERMAN (de)
    // ==========================================
    'de': {
      // General & UI
      'app_name': 'Autohaus Tycoon',
      'settings_title': 'EINSTELLUNGEN & PROFIL',
      'language_select': 'Sprachauswahl',
      'language_desc': 'Oberflächen- & Spielsprache',
      'theme_store': 'THEMEN & DESIGN-SHOP',
      'dealership_identity': 'AUTOHAUS & PROFILIDENTITÄT',
      'audio_effects': 'Soundeffekte',
      'audio_desc': 'Motor- und Tastengeräusche',
      'dashboard': 'AUTOHAUS SHOWROOM',
      'garage': 'GARAGE & INVENTAR',
      'showroom': 'VERKAUFSRAUM & ANGEBOTE',
      'scrapyard': 'SCHROTTPLATZ & WERKSTATT',
      'stock_market': 'BÖRSE & FINANZEN',
      'auction': 'ZOLL-AUKTION',
      'staff': 'PERSONAL & AKADEMIE',
      'notary': 'ZULASSUNG & VERTRAG',
      'bank': 'GEWERBEKREDIT & EINLAGEN',
      'night_race': 'NACHTRENNEN & WETTEN',
      'missions': 'MISSIONEN & ERFOLGE',
      'level': 'Stufe',
      'reputation': 'Ruf',
      'balance': 'Guthaben',
      'day': 'Tag',
      'garage_slots': 'Garagenkapazität',
      'claim': 'BELOHNUNG ABHOLEN',
      'confirm': 'BESTÄTIGEN',
      'cancel': 'ABBRECHEN',
      'close': 'SCHLIEßEN',
      'save': 'SPEICHERN',
      'buy': 'KAUFEN',
      'sell': 'INSERIEREN',
      'clean': 'AUTOWÄSCHE & AUFBEREITUNG',
      'repair': 'WERKSTATTREPARATUR',
      'tuning': 'VIP-TUNING-STUDIO',
      'inspect': 'TÜV-GUTACHTEN',
      'locked': 'GESPERRT',
      'unlocked': 'FREIGESCHALTET',
      'free': 'KOSTENLOS',
      'cost': 'Kosten',
      'duration': 'Dauer',

      // Car Details & Inspection
      'mileage': 'Kilometerstand',
      'year': 'Baujahr',
      'fuel_type': 'Kraftstoff',
      'transmission': 'Getriebe',
      'horsepower': 'Leistung (PS)',
      'body_paint': 'Lackzustand',
      'paint_original': 'Unfallfrei / Originallack',
      'paint_painted': 'Nachlackiert',
      'paint_damaged': 'Totalschaden',
      'engine_condition': 'Motorzustand',
      'chassis_condition': 'Fahrwerkszustand',
      'market_value': 'Marktwert',
      'listing_price': 'Angebotspreis',
      'profit_margin': 'Gewinnspanne',

      // 28-Day Calendar
      'streak_title': '28-TAGE-GESCHÄFTSKALENDER',
      'streak_ready': 'PRÄMIE BEREIT',
      'streak_wait': 'MORGEN WIEDERKOMMEN',
      'streak_claimed': 'EINGELÖST',
      'season_spring': 'FRÜHLINGS-MARKT-SAISON',
      'season_summer': 'SOMMER-TOURISMUS-SAISON',
      'season_autumn': 'HERBST-FLOTTEN-SAISON',
      'season_winter': 'WINTER-TYCOON-SAISON',

      // CRM & Customer Events
      'crm_title': 'KUNDENBETREUUNG (CRM)',
      'crm_resolve': 'ENTSCHEIDUNG TREFFEN',
      'crm_accept': 'ANGEBOT ANNEHMEN',
      'crm_reject': 'ABLEHNEN',
      'crm_happy': 'Zufriedener VIP-Kunde',
      'crm_defect': 'Sachmängelbeschwerde',
      'crm_fleet': 'Lieferflotten-Vertrag',
      'crm_movie': 'Film- und Setvermietung',
      'crm_diplomat': 'Diplomatische Fuhrpark-Referenz',

      // Stock Market & IPO
      'bist_glrd': 'GLRD HOLDING AG',
      'company_ipo': 'BÖRSENGANG-PULT',
      'share_buyback': 'AKTIENRÜCKKAUF',
      'quarterly_report': 'QUARTALSBERICHT',
      'dividend_payout': 'Dividendenausschüttung',
      'stock_portfolio': 'Aktienportfolio',
      'gold_forex': 'Gold & Devisenhandel',

      // Scrapyard & Parts
      'sanayi_rumor': 'TÄGLICHE WERKSTATT-GERÜCHTE',
      'zone_ostim': 'Industriepark Ostim',
      'zone_maslak': 'Kfz-Werkstatt Maslak',
      'zone_sasmaz': 'Schrottplatz Sasmaz',
      'zone_harabe': 'Verlassene Fabrikhalle',
      'barn_find': 'Scheunenfund-Klassiker',
      'salvage_parts': 'Ersatzteile ausschlachten',

      // Auction & Bluff
      'bluff_button': 'BLUFFEN & AUSSTEIGEN',
      'auction_bid': 'Gebot abgeben',
      'auction_rival_selim': 'Baron Selim',
      'auction_rival_ferit': 'Sammler Ferit',
      'auction_rival_riza': 'Händler Riza',
      'auction_hammer': 'Verkauft!',

      // Staff & Academy
      'staff_morale': 'Mitarbeitermoral',
      'tea_treat': 'KAFFEE SPENDIEREN',
      'meal_treat': 'MITTAGESSEN AUSGEBEN',
      'bonus_treat': 'LEISTUNGSBONUS',
      'staff_washer': 'Fahrzeugaufbereiter',
      'staff_mechanic': 'Kfz-Meister',
      'staff_salesman': 'Senior Verkaufsberater',
      'staff_painter': 'Lackiermeister',
      'staff_security': 'Nachtwächter',

      // Notary & Banking
      'notary_contract': 'Kauf- und Übernahmevertrag',
      'notary_fee': 'Zulassungsgebühren',
      'safe_payment': 'Treuhandzahlung',
      'bank_loan': 'Betriebsmittelkredit',
      'bank_interest': 'Zinssatz',
      'bank_repay': 'Kreditschuld tilgen',
    },

    // ==========================================
    // PORTUGUESE (pt - Brasil)
    // ==========================================
    'pt': {
      // General & UI
      'app_name': 'Concessionária Tycoon',
      'settings_title': 'CONFIGURAÇÕES & PERFIL',
      'language_select': 'Opção de Idioma',
      'language_desc': 'Idioma da interface e do jogo',
      'theme_store': 'LOJA DE TEMAS & VISUAIS',
      'dealership_identity': 'IDENTIDADE DA LOJA & PERFIL',
      'audio_effects': 'Efeitos Sonoros',
      'audio_desc': 'Sons de motor e botões',
      'dashboard': 'PAINEL DA LOJA',
      'garage': 'GARAGEM & ESTOQUE',
      'showroom': 'SHOWROOM & VENDAS',
      'scrapyard': 'DESMANCHE & OFICINA',
      'stock_market': 'BOLSA & INVESTIMENTOS',
      'auction': 'LEILÃO DA ALFÂNDEGA',
      'staff': 'EQUIPE & ACADEMIA',
      'notary': 'CARTÓRIO & TRANSFERÊNCIA',
      'bank': 'EMPRÉSTIMOS & POUPANÇA',
      'night_race': 'RACHAS NOTURNOS & APOSTAS',
      'missions': 'MISSÕES & CONQUISTAS',
      'level': 'Nível',
      'reputation': 'Reputação',
      'balance': 'Saldo',
      'day': 'Dia',
      'garage_slots': 'Vagas na Garagem',
      'claim': 'RESGATAR RECOMPENSA',
      'confirm': 'CONFIRMAR',
      'cancel': 'CANCELAR',
      'close': 'FECHAR',
      'save': 'SALVAR',
      'buy': 'COMPRAR',
      'sell': 'COLOCAR À VENDA',
      'clean': 'LAVA-RÁPIDO & POLIMENTO',
      'repair': 'REPARO NA OFICINA',
      'tuning': 'ESTÚDIO VIP DE TUNING',
      'inspect': 'LAUDO CAUTELAR',
      'locked': 'BLOQUEADO',
      'unlocked': 'DESBLOQUEADO',
      'free': 'GRÁTIS',
      'cost': 'Custo',
      'duration': 'Duração',

      // Car Details & Inspection
      'mileage': 'Quilometragem',
      'year': 'Ano de Fabricação',
      'fuel_type': 'Combustível',
      'transmission': 'Câmbio',
      'horsepower': 'Potência (CV)',
      'body_paint': 'Estado da Lataria',
      'paint_original': 'Original / Sem Detalhes',
      'paint_painted': 'Pintura Retocada',
      'paint_damaged': 'Sinistrado / Sucata',
      'engine_condition': 'Saúde do Motor',
      'chassis_condition': 'Estrutura do Chassi',
      'market_value': 'Tabela FIPE / Mercado',
      'listing_price': 'Preço Anunciado',
      'profit_margin': 'Margem de Lucro',

      // 28-Day Calendar
      'streak_title': 'CALENDÁRIO DE 28 DIAS',
      'streak_ready': 'RECOMPENSA PRONTA',
      'streak_wait': 'VOLTE AMANHÃ',
      'streak_claimed': 'RESGATADO',
      'season_spring': 'TEMPORADA DE PRIMAVERA',
      'season_summer': 'TEMPORADA DE VERÃO',
      'season_autumn': 'TEMPORADA DE OUTONO',
      'season_winter': 'TEMPORADA DE INVERNO',

      // CRM & Customer Events
      'crm_title': 'EVENTO DE PÓS-VENDA (CRM)',
      'crm_resolve': 'TOMAR DECISÃO',
      'crm_accept': 'ACEITAR OFERTA',
      'crm_reject': 'RECUSAR',
      'crm_happy': 'Elogio de Cliente VIP',
      'crm_defect': 'Reclamação de Vício Oculto',
      'crm_fleet': 'Contrato de Frotas de Entrega',
      'crm_movie': 'Locação para Cinema e Séries',
      'crm_diplomat': 'Indicação de Frota Diplomática',

      // Stock Market & IPO
      'bist_glrd': 'GLRD HOLDING',
      'company_ipo': 'MESA DE IPO / BOLSA',
      'share_buyback': 'RECOMPRAR AÇÕES',
      'quarterly_report': 'BALANÇO TRIMESTRAL',
      'dividend_payout': 'Pagamento de Dividendos',
      'stock_portfolio': 'Carteira de Ações',
      'gold_forex': 'Ouro & Câmbio',

      // Scrapyard & Parts
      'sanayi_rumor': 'FOFOCA DO DIA NO DESMANCHE',
      'zone_ostim': 'Distrito Industrial Ostim',
      'zone_maslak': 'Oficina Mecânica Maslak',
      'zone_sasmaz': 'Pátio de Sucatas Sasmaz',
      'zone_harabe': 'Fábrica Abandonada',
      'barn_find': 'Relíquia de Galpão',
      'salvage_parts': 'Desmanchar Peças Usadas',

      // Auction & Bluff
      'bluff_button': 'BLEFAR E SAIR',
      'auction_bid': 'Dar Lance',
      'auction_rival_selim': 'Barão Selim',
      'auction_rival_ferit': 'Colecionador Ferit',
      'auction_rival_riza': 'Gira-Carros Riza',
      'auction_hammer': 'Vendido!',

      // Staff & Academy
      'staff_morale': 'Moral dos Funcionários',
      'tea_treat': 'PAGAR CAFÉ',
      'meal_treat': 'PAGAR ALMOÇO',
      'bonus_treat': 'BÔNUS SALARIAL',
      'staff_washer': 'Lavador e Detalhista',
      'staff_mechanic': 'Mecânico Chefe',
      'staff_salesman': 'Vendedor Sênior',
      'staff_painter': 'Pintor Automotivo',
      'staff_security': 'Segurança Noturno',

      // Notary & Banking
      'notary_contract': 'Contrato de Compra e Venda',
      'notary_fee': 'Taxa de Transferência',
      'safe_payment': 'Pagamento Protegido',
      'bank_loan': 'Crédito Comercial PJ',
      'bank_interest': 'Taxa de Juros',
      'bank_repay': 'Quitar Financiamento',
    },

    // ==========================================
    // SPANISH (es)
    // ==========================================
    'es': {
      // General & UI
      'app_name': 'Concesionario Tycoon',
      'settings_title': 'AJUSTES & PERFIL',
      'language_select': 'Opción de Idioma',
      'language_desc': 'Idioma de interfaz y juego',
      'theme_store': 'TIENDA DE TEMAS & DISEÑO',
      'dealership_identity': 'CONCESIONARIO & PERFIL',
      'audio_effects': 'Efectos de Sonido',
      'audio_desc': 'Sonidos de motor y botones',
      'dashboard': 'PANEL DEL CONCESIONARIO',
      'garage': 'GARAJE & INVENTARIO',
      'showroom': 'SHOWROOM & VENTAS',
      'scrapyard': 'DESGUACE & TALLER',
      'stock_market': 'BOLSA & INVERSIONES',
      'auction': 'SUBASTA DE ADUANAS',
      'staff': 'PERSONAL & ACADEMIA',
      'notary': 'NOTARÍA & TRASPASO',
      'bank': 'CRÉDITOS & DEPÓSITOS',
      'night_race': 'CARRERAS NOCTURNAS & APUESTAS',
      'missions': 'MISIONES & LOGROS',
      'level': 'Nivel',
      'reputation': 'Reputación',
      'balance': 'Saldo',
      'day': 'Día',
      'garage_slots': 'Plazas de Garaje',
      'claim': 'RECLAMAR RECOMPENSA',
      'confirm': 'CONFIRMAR',
      'cancel': 'CANCELAR',
      'close': 'CERRAR',
      'save': 'GUARDAR',
      'buy': 'COMPRAR',
      'sell': 'PONER A LA VENTA',
      'clean': 'LAVADO & PULIDO',
      'repair': 'REPARACIÓN EN TALLER',
      'tuning': 'ESTUDIO VIP DE TUNING',
      'inspect': 'INFORME DE PERITAJE',
      'locked': 'BLOQUEADO',
      'unlocked': 'DESBLOQUEADO',
      'free': 'GRATIS',
      'cost': 'Coste',
      'duration': 'Duración',

      // Car Details & Inspection
      'mileage': 'Kilometraje',
      'year': 'Año del Modelo',
      'fuel_type': 'Combustible',
      'transmission': 'Transmisión',
      'horsepower': 'Potencia (CV)',
      'body_paint': 'Estado de Chapa y Pintura',
      'paint_original': 'Original / Sin Daños',
      'paint_painted': 'Pintura Repasada',
      'paint_damaged': 'Siniestro Total',
      'engine_condition': 'Salud del Motor',
      'chassis_condition': 'Estado del Bastidor',
      'market_value': 'Tasación de Mercado',
      'listing_price': 'Precio de Venta',
      'profit_margin': 'Margen de Beneficio',

      // 28-Day Calendar
      'streak_title': 'CALENDARIO DE 28 DÍAS',
      'streak_ready': 'RECOMPENSA LISTA',
      'streak_wait': 'VUELVE MAÑANA',
      'streak_claimed': 'RECLAMADO',
      'season_spring': 'TEMPORADA DE PRIMAVERA',
      'season_summer': 'TEMPORADA DE VERANO',
      'season_autumn': 'TEMPORADA DE OTOÑO',
      'season_winter': 'TEMPORADA DE INVIERNO',

      // CRM & Customer Events
      'crm_title': 'EVENTO POSVENTA (CRM)',
      'crm_resolve': 'TOMAR DECISIÓN',
      'crm_accept': 'ACEPTAR OFERTA',
      'crm_reject': 'RECHAZAR',
      'crm_happy': 'Agradecimiento de Cliente VIP',
      'crm_defect': 'Reclamación por Vicios Ocultos',
      'crm_fleet': 'Acuerdo de Flota Logística',
      'crm_movie': 'Alquiler para Producción de Cine',
      'crm_diplomat': 'Referencia para Flota Diplomática',

      // Stock Market & IPO
      'bist_glrd': 'GLRD HOLDING',
      'company_ipo': 'SALIDA A BOLSA (IPO)',
      'share_buyback': 'RECOMPRA DE ACCIONES',
      'quarterly_report': 'INFORME TRIMESTRAL',
      'dividend_payout': 'Pago de Dividendos',
      'stock_portfolio': 'Cartera de Valores',
      'gold_forex': 'Oro & Divisas',

      // Scrapyard & Parts
      'sanayi_rumor': 'RUMOR DEL DÍA EN EL TALLER',
      'zone_ostim': 'Polígono Industrial Ostim',
      'zone_maslak': 'Taller Mecánico Maslak',
      'zone_sasmaz': 'Desguace Sasmaz',
      'zone_harabe': 'Fábrica Abandonada',
      'barn_find': 'Joya de Granero Oculta',
      'salvage_parts': 'Extraer Recambios Usados',

      // Auction & Bluff
      'bluff_button': 'FAROLEAR Y RETIRARSE',
      'auction_bid': 'Pujar',
      'auction_rival_selim': 'Barón Selim',
      'auction_rival_ferit': 'Coleccionista Ferit',
      'auction_rival_riza': 'Revendedor Riza',
      'auction_hammer': '¡Adjudicado!',

      // Staff & Academy
      'staff_morale': 'Moral del Personal',
      'tea_treat': 'INVITAR CAFÉ',
      'meal_treat': 'INVITAR ALMUERZO',
      'bonus_treat': 'BONO DE RENDIMIENTO',
      'staff_washer': 'Lavador de Coches',
      'staff_mechanic': 'Jefe de Taller',
      'staff_salesman': 'Comercial Sénior',
      'staff_painter': 'Pintor Especialista',
      'staff_security': 'Vigilante Nocturno',

      // Notary & Banking
      'notary_contract': 'Contrato de Compraventa',
      'notary_fee': 'Tasa de Notaría y Traspaso',
      'safe_payment': 'Pago Seguro Notarial',
      'bank_loan': 'Crédito Comercial',
      'bank_interest': 'Tipo de Interés',
      'bank_repay': 'Amortizar Préstamo',
    },

    // ==========================================
    // RUSSIAN (ru)
    // ==========================================
    'ru': {
      // General & UI
      'app_name': 'Автосалон Тайкун',
      'settings_title': 'НАСТРОЙКИ И ПРОФИЛЬ',
      'language_select': 'Выбор языка',
      'language_desc': 'Язык интерфейса и игры',
      'theme_store': 'МАГАЗИН ТЕМ И ОФОРМЛЕНИЯ',
      'dealership_identity': 'ПРОФИЛЬ АВТОСАЛОНА',
      'audio_effects': 'Звуковые эффекты',
      'audio_desc': 'Звуки двигателя и кнопок',
      'dashboard': 'ВИТРИНА АВТОСАЛОНА',
      'garage': 'ГАРАЖ И ИНВЕНТАРЬ',
      'showroom': 'ШОУРУМ И ПРОДАЖИ',
      'scrapyard': 'АВТОРАЗБОРКА И СЕРВИС',
      'stock_market': 'БИРЖА И ИНВЕСТИЦИИ',
      'auction': 'ТАМОЖЕННЫЙ АУКЦИОН',
      'staff': 'ПЕРСОНАЛ И АКАДЕМИЯ',
      'notary': 'НОТАРИУС И ОФОРМЛЕНИЕ',
      'bank': 'КРЕДИТЫ И ВКЛАДЫ',
      'night_race': 'НОЧНЫЕ ГОНКИ И СТАВКИ',
      'missions': 'ЗАДАНИЯ И ДОСТИЖЕНИЯ',
      'level': 'Уровень',
      'reputation': 'Репутация',
      'balance': 'Баланс',
      'day': 'День',
      'garage_slots': 'Вместимость гаража',
      'claim': 'ЗАБРАТЬ НАГРАДУ',
      'confirm': 'ПОДТВЕРДИТЬ',
      'cancel': 'ОТМЕНА',
      'close': 'ЗАКРЫТЬ',
      'save': 'СОХРАНИТЬ',
      'buy': 'КУПИТЬ',
      'sell': 'ВЫСТАВИТЬ НА ПРОДАЖУ',
      'clean': 'МОЙКА И ДЕТЕЙЛИНГ',
      'repair': 'РЕМОНТ В СЕРВИСЕ',
      'tuning': 'VIP ТЮНИНГ СТУДИЯ',
      'inspect': 'ТЕХНИЧЕСКИЙ ОСМОТР',
      'locked': 'ЗАБЛОКИРОВАНО',
      'unlocked': 'РАЗБЛОКИРОВАНО',
      'free': 'БЕСПЛАТНО',
      'cost': 'Стоимость',
      'duration': 'Длительность',

      // Car Details & Inspection
      'mileage': 'Пробег',
      'year': 'Год выпуска',
      'fuel_type': 'Тип топлива',
      'transmission': 'Коробка передач',
      'horsepower': 'Мощность (л.с.)',
      'body_paint': 'Состояние кузова',
      'paint_original': 'В родной краске',
      'paint_painted': 'Есть окрасы',
      'paint_damaged': 'Тотальный ущерб',
      'engine_condition': 'Состояние двигателя',
      'chassis_condition': 'Геометрия кузова',
      'market_value': 'Рыночная оценка',
      'listing_price': 'Цена на продажу',
      'profit_margin': 'Маржинальная прибыль',

      // 28-Day Calendar
      'streak_title': '28-ДНЕВНЫЙ КАЛЕНДАРЬ',
      'streak_ready': 'НАГРАДА ГОТОВА',
      'streak_wait': 'ПРИХОДИТЕ ЗАВТРА',
      'streak_claimed': 'ПОЛУЧЕНО',
      'season_spring': 'ВЕСЕННИЙ СЕЗОН',
      'season_summer': 'ЛЕТНИЙ ТУРИСТИЧЕСКИЙ СЕЗОН',
      'season_autumn': 'ОСЕННИЙ СЕЗОН АВТОПАРКОВ',
      'season_winter': 'ЗИМНИЙ МАГНАТСКИЙ СЕЗОН',

      // CRM & Customer Events
      'crm_title': 'ОБСЛУЖИВАНИЕ КЛИЕНТОВ (CRM)',
      'crm_resolve': 'ПРИНЯТЬ РЕШЕНИЕ',
      'crm_accept': 'ПРИНЯТЬ СДЕЛКУ',
      'crm_reject': 'ОТКЛОНИТЬ',
      'crm_happy': 'Благодарность VIP-клиента',
      'crm_defect': 'Претензия по скрытым дефектам',
      'crm_fleet': 'Контракт на поставку автопарка',
      'crm_movie': 'Аренда для кино и сериалов',
      'crm_diplomat': 'Дипломатический заказ',

      // Stock Market & IPO
      'bist_glrd': 'GLRD ХОЛДИНГ',
      'company_ipo': 'ВЫХОД НА БИРЖУ (IPO)',
      'share_buyback': 'ОБРАТНЫЙ ВЫКУП АКЦИЙ',
      'quarterly_report': 'КВАРТАЛЬНЫЙ ОТЧЕТ',
      'dividend_payout': 'Выплата дивидендов',
      'stock_portfolio': 'Инвестиционный портфель',
      'gold_forex': 'Золото и валюта',

      // Scrapyard & Parts
      'sanayi_rumor': 'СЛУХ ДНЯ В АВТОСЕРВИСЕ',
      'zone_ostim': 'Промзона Остим',
      'zone_maslak': 'Автосервис Маслак',
      'zone_sasmaz': 'Авторазборка Шашмаз',
      'zone_harabe': 'Заброшенный завод',
      'barn_find': 'Гаражная находка раритета',
      'salvage_parts': 'Снять контрактные запчасти',

      // Auction & Bluff
      'bluff_button': 'БЛЕФОВАТЬ И ВЫЙТИ',
      'auction_bid': 'Сделать ставку',
      'auction_rival_selim': 'Барон Селим',
      'auction_rival_ferit': 'Коллекционер Ферит',
      'auction_rival_riza': 'Перекупщик Рыза',
      'auction_hammer': 'Продано!',

      // Staff & Academy
      'staff_morale': 'Боевой дух персонала',
      'tea_treat': 'УГОСТИТЬ ЧАЕМ',
      'meal_treat': 'УГОСТИТЬ ОБЕДОМ',
      'bonus_treat': 'ПРЕМИЯ ЗА РАБОТУ',
      'staff_washer': 'Мастер детейлинга',
      'staff_mechanic': 'Главный автомеханик',
      'staff_salesman': 'Старший менеджер продаж',
      'staff_painter': 'Маляр в камере',
      'staff_security': 'Ночной охранник',

      // Notary & Banking
      'notary_contract': 'Договор купли-продажи',
      'notary_fee': 'Госпошлина за переоформление',
      'safe_payment': 'Безопасный расчет',
      'bank_loan': 'Коммерческий бизнес-кредит',
      'bank_interest': 'Процентная ставка',
      'bank_repay': 'Погасить задолженность',
    },

    // ==========================================
    // ARABIC (ar)
    // ==========================================
    'ar': {
      // General & UI
      'app_name': 'تاجر السيارات الفاخرة',
      'settings_title': 'الإعدادات والملف الشخصي',
      'language_select': 'اختيار اللغة',
      'language_desc': 'لغة الواجهة واللعبة',
      'theme_store': 'متجر المظاهر والتصميم',
      'dealership_identity': 'هوية المعرض والملف الشخصي',
      'audio_effects': 'المؤثرات الصوتية',
      'audio_desc': 'أصوات المحرك والأزرار',
      'dashboard': 'واجهة المعرض الرئيسية',
      'garage': 'المرآب والمخزون',
      'showroom': 'صالة العرض والمبيعات',
      'scrapyard': 'التشليح والورشة',
      'stock_market': 'البورصة والاستثمار',
      'auction': 'مزاد الجمارك للسيارات',
      'staff': 'الموظفون والأكاديمية',
      'notary': 'التوثيق ونقل الملكية',
      'bank': 'القروض التجارية والودائع',
      'night_race': 'سباقات الشوارع الليلية',
      'missions': 'المهام والإنجازات',
      'level': 'المستوى',
      'reputation': 'السمعة',
      'balance': 'الرصيد',
      'day': 'اليوم',
      'garage_slots': 'سعة المرآب',
      'claim': 'استلام المكافأة',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'close': 'إغلاق',
      'save': 'حفظ',
      'buy': 'شراء',
      'sell': 'عرض للبيع',
      'clean': 'غسيل وتلميع شامل',
      'repair': 'إصلاح في الورشة',
      'tuning': 'استوديو التعديل الاحترافي',
      'inspect': 'تقرير الفحص الفني',
      'locked': 'مقفل',
      'unlocked': 'متاح',
      'free': 'مجاني',
      'cost': 'التكلفة',
      'duration': 'المدة',

      // Car Details & Inspection
      'mileage': 'المسافة المقطوعة',
      'year': 'سنة الصنع',
      'fuel_type': 'نوع الوقود',
      'transmission': 'ناقل الحركة',
      'horsepower': 'قوة المحرك (حصان)',
      'body_paint': 'حالة طلاء الهيكل',
      'paint_original': 'وكالة / بدون رش',
      'paint_painted': 'رش جزئي تجميلي',
      'paint_damaged': 'حادث جسيم / تشليح',
      'engine_condition': 'حالة المحرك',
      'chassis_condition': 'سلامة الشاسيه',
      'market_value': 'القيمة السوقية التقديرية',
      'listing_price': 'سعر العرض المطلوب',
      'profit_margin': 'هامش الربح المتوقع',

      // 28-Day Calendar
      'streak_title': 'تقويم التاجر لمدة 28 يوما',
      'streak_ready': 'المكافأة جاهزة',
      'streak_wait': 'عد غدا',
      'streak_claimed': 'تم الاستلام',
      'season_spring': 'موسم الربيع التجاري',
      'season_summer': 'موسم الصيف السياحي',
      'season_autumn': 'موسم الخريف والشاحنات',
      'season_winter': 'موسم الشتاء للأثرياء',

      // CRM & Customer Events
      'crm_title': 'خدمة العملاء وما بعد البيع',
      'crm_resolve': 'اتخاذ القرار',
      'crm_accept': 'قبول العرض',
      'crm_reject': 'رفض الطلب',
      'crm_happy': 'شكر وتقدير من عميل VIP',
      'crm_defect': 'شكوى عيب مصنعي خفي',
      'crm_fleet': 'عقد توريد أسطول شحن',
      'crm_movie': 'تأجير لإنتاج سينمائي',
      'crm_diplomat': 'تجهيز موكب دبلوماسي',

      // Stock Market & IPO
      'bist_glrd': 'مجموعة GLRD القابضة',
      'company_ipo': 'طرح الشركة في البورصة',
      'share_buyback': 'إعادة شراء الأسهم',
      'quarterly_report': 'التقرير المالي الفصلي',
      'dividend_payout': 'توزيع الأرباح النقدية',
      'stock_portfolio': 'محفظة الأسهم',
      'gold_forex': 'تداول الذهب والعملات',

      // Scrapyard & Parts
      'sanayi_rumor': 'شائعة اليوم في الورشة',
      'zone_ostim': 'المنطقة الصناعية أوستيم',
      'zone_maslak': 'ورش الصيانة مسلك',
      'zone_sasmaz': 'مجمع التشليح شاشماز',
      'zone_harabe': 'المصنع المهجور',
      'barn_find': 'سيارة كلاسيكية نادرة',
      'salvage_parts': 'تفكيك قطع الغيار',

      // Auction & Bluff
      'bluff_button': 'المراوغة والانسحاب',
      'auction_bid': 'تقديم عرض مزايدة',
      'auction_rival_selim': 'البارون سليم',
      'auction_rival_ferit': 'الهاوي فريد',
      'auction_rival_riza': 'التاجر رضا',
      'auction_hammer': 'تمت البيعة!',

      // Staff & Academy
      'staff_morale': 'معنويات الفريق',
      'tea_treat': 'ضيافة الشاي والقهوة',
      'meal_treat': 'ضيافة وجبة الغداء',
      'bonus_treat': 'مكافأة الأداء',
      'staff_washer': 'فني تلميع وغسيل',
      'staff_mechanic': 'كبير الميكانيكيين',
      'staff_salesman': 'مستشار مبيعات أول',
      'staff_painter': 'فني دهان أفران',
      'staff_security': 'حارس أمن ليلي',

      // Notary & Banking
      'notary_contract': 'عقد البيع ونقل الملكية',
      'notary_fee': 'رسوم التوثيق والتسجيل',
      'safe_payment': 'الدفع المضمون',
      'bank_loan': 'تمويل تجاري للمنشآت',
      'bank_interest': 'معدل الفائدة',
      'bank_repay': 'سداد المستحقات والتمويل',
    },
  };

  String get(String key, [Map<String, dynamic>? params]) {
    String? translation = _localizedValues[languageCode]?[key];
    if (translation == null || translation.isEmpty) {
      // Fallback to English, then Turkish
      translation = _localizedValues['en']?[key] ?? _localizedValues['tr']?[key] ?? key;
    }

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, value) {
        translation = translation!.replaceAll('{$paramKey}', value.toString());
      });
    }

    return translation!;
  }

  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    final code = locale?.languageCode ?? 'tr';
    return AppLocalizations(code);
  }

  static String tr(BuildContext context, String key, [Map<String, dynamic>? params]) {
    return of(context).get(key, params);
  }

  static Map<String, String> getAllKeysFor(String code) {
    return _localizedValues[code] ?? _localizedValues['tr']!;
  }

  static List<String> get supportedLanguageCodes => _localizedValues.keys.toList();
}

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key, [Map<String, dynamic>? params]) => AppLocalizations.tr(this, key, params);
}
