import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../data/models/car_model.dart';
import '../data/models/listing_model.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/expertise/expertise_screen.dart';
import '../presentation/screens/marketplace/listing_detail_screen.dart';
import '../presentation/screens/marketplace/marketplace_screen.dart';
import '../presentation/screens/marketplace/negotiation_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/showroom/create_listing_screen.dart';
import '../presentation/screens/showroom/offer_evaluation_screen.dart';
import '../presentation/screens/showroom/showroom_screen.dart';
import '../presentation/screens/workshop/workshop_screen.dart';

import '../presentation/screens/auction/auction_screen.dart';
import '../presentation/screens/branch/branch_screen.dart';
import '../presentation/screens/character/character_growth_screen.dart';

import '../presentation/screens/city_map/district_market_screen.dart';
import '../presentation/screens/settings/dealership_identity_screen.dart';
import '../presentation/screens/settings/theme_store_screen.dart';
import '../presentation/screens/staff/staff_screen.dart';
import '../presentation/screens/car_wash/car_wash_screen.dart';
import '../presentation/screens/reviews/customer_reviews_screen.dart';
import '../presentation/screens/history/sales_history_screen.dart';
import '../presentation/screens/finance/finance_screen.dart';
import '../presentation/screens/finance/daily_cashflow_screen.dart';
import '../presentation/screens/rent_a_car/rent_a_car_screen.dart';
import '../presentation/screens/side_business/side_business_screen.dart';
import '../presentation/screens/side_business/side_business_detail_screen.dart';
import '../presentation/screens/stock_market/stock_market_screen.dart';
import '../presentation/screens/workshop/tuning_studio_screen.dart';
import '../presentation/screens/finance/bank_investments_screen.dart';
import '../presentation/screens/staff/staff_academy_screen.dart';
import '../presentation/screens/branch/showroom_decor_screen.dart';
import '../presentation/screens/scrapyard/scrapyard_screen.dart';
import '../presentation/screens/black_market/black_market_screen.dart';
import '../presentation/screens/gossip/industry_gossip_screen.dart';
import '../presentation/screens/consignment/consignment_screen.dart';
import '../presentation/screens/night_market/night_market_screen.dart';
import '../presentation/screens/office/special_plate_screen.dart';
import '../presentation/screens/office/media_agency_screen.dart';
import '../presentation/screens/office/lifestyle_screen.dart';
import '../presentation/screens/album/collection_album_screen.dart';
import '../presentation/screens/vasita/vasita_market_screen.dart';
import '../presentation/screens/vasita/vasita_expertise_screen.dart';
import '../presentation/screens/vasita/vasita_negotiation_screen.dart';
import '../presentation/screens/real_estate/real_estate_market_screen.dart';
import '../presentation/screens/real_estate/real_estate_renovation_screen.dart';
import '../presentation/screens/real_estate/real_estate_construction_screen.dart';
import '../presentation/screens/casino/casino_hub_screen.dart';

Page<dynamic> _buildCupertinoPage(Widget child, GoRouterState state) {
  return CupertinoPage(
    key: state.pageKey,
    name: state.uri.toString(),
    child: child,
  );
}

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  errorBuilder: (context, state) => const DashboardScreen(),
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/dashboard',
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _buildCupertinoPage(const DashboardScreen(), state),
    ),
    GoRoute(
      path: '/scrapyard',
      pageBuilder: (context, state) => _buildCupertinoPage(const ScrapyardScreen(), state),
    ),
    GoRoute(
      path: '/districts',
      pageBuilder: (context, state) => _buildCupertinoPage(const DistrictMarketScreen(), state),
    ),
    GoRoute(
      path: '/black-market',
      pageBuilder: (context, state) => _buildCupertinoPage(const BlackMarketScreen(), state),
    ),
    GoRoute(
      path: '/gossip',
      pageBuilder: (context, state) => _buildCupertinoPage(const IndustryGossipScreen(), state),
    ),
    GoRoute(
      path: '/consignment',
      pageBuilder: (context, state) => _buildCupertinoPage(const ConsignmentScreen(), state),
    ),
    GoRoute(
      path: '/night-market',
      pageBuilder: (context, state) => _buildCupertinoPage(const NightMarketScreen(), state),
    ),
    GoRoute(
      path: '/tuning-studio',
      pageBuilder: (context, state) => _buildCupertinoPage(const TuningStudioScreen(), state),
    ),
    GoRoute(
      path: '/bank-investments',
      pageBuilder: (context, state) => _buildCupertinoPage(const BankInvestmentsScreen(), state),
    ),
    GoRoute(
      path: '/staff-academy',
      pageBuilder: (context, state) => _buildCupertinoPage(const StaffAcademyScreen(), state),
    ),
    GoRoute(
      path: '/showroom-decor',
      pageBuilder: (context, state) => _buildCupertinoPage(const ShowroomDecorScreen(), state),
    ),
    GoRoute(
      path: '/side-businesses',
      pageBuilder: (context, state) => _buildCupertinoPage(const SideBusinessScreen(), state),
    ),
    GoRoute(
      path: '/side-business-detail/:businessId',
      pageBuilder: (context, state) {
        final businessId = state.pathParameters['businessId'] ?? '';
        return _buildCupertinoPage(SideBusinessDetailScreen(businessId: businessId), state);
      },
    ),
    GoRoute(
      path: '/stock-market',
      pageBuilder: (context, state) => _buildCupertinoPage(const StockMarketScreen(), state),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => _buildCupertinoPage(const SalesHistoryScreen(), state),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _buildCupertinoPage(const OnboardingScreen(), state),
    ),
    GoRoute(
      path: '/staff',
      pageBuilder: (context, state) => _buildCupertinoPage(const StaffScreen(), state),
    ),
    GoRoute(
      path: '/car-wash',
      pageBuilder: (context, state) => _buildCupertinoPage(const CarWashScreen(), state),
    ),
    GoRoute(
      path: '/vasita',
      pageBuilder: (context, state) => _buildCupertinoPage(const VasitaMarketScreen(), state),
    ),
    GoRoute(
      path: '/vasita-market',
      pageBuilder: (context, state) => _buildCupertinoPage(const VasitaMarketScreen(), state),
    ),
    GoRoute(
      path: '/vasita-ekspertiz/:listingId',
      pageBuilder: (context, state) {
        final listingId = state.pathParameters['listingId'];
        final extraListing = state.extra as ListingModel?;
        return _buildCupertinoPage(
          VasitaExpertiseScreen(
            listingId: listingId,
            initialListing: extraListing,
          ),
          state,
        );
      },
    ),
    GoRoute(
      path: '/vasita-pazarlik/:listingId',
      pageBuilder: (context, state) {
        final extraListing = state.extra as ListingModel?;
        if (extraListing != null) {
          return _buildCupertinoPage(VasitaNegotiationScreen(listing: extraListing), state);
        }
        return _buildCupertinoPage(const VasitaMarketScreen(), state);
      },
    ),
    GoRoute(
      path: '/emlak',
      pageBuilder: (context, state) => _buildCupertinoPage(const RealEstateMarketScreen(), state),
    ),
    GoRoute(
      path: '/emlak-market',
      pageBuilder: (context, state) => _buildCupertinoPage(const RealEstateMarketScreen(), state),
    ),
    GoRoute(
      path: '/emlak-tadilat/:propertyId',
      pageBuilder: (context, state) {
        final propertyId = state.pathParameters['propertyId'] ?? '';
        return _buildCupertinoPage(RealEstateRenovationScreen(propertyId: propertyId), state);
      },
    ),
    GoRoute(
      path: '/emlak-insaat/:landId',
      pageBuilder: (context, state) {
        final landId = state.pathParameters['landId'] ?? '';
        return _buildCupertinoPage(RealEstateConstructionScreen(landId: landId), state);
      },
    ),
    GoRoute(
      path: '/reviews',
      pageBuilder: (context, state) => _buildCupertinoPage(const CustomerReviewsScreen(), state),
    ),
    GoRoute(
      path: '/finance',
      pageBuilder: (context, state) => _buildCupertinoPage(const FinanceScreen(), state),
    ),
    GoRoute(
      path: '/finance/daily-cashflow',
      pageBuilder: (context, state) => _buildCupertinoPage(const DailyCashflowScreen(), state),
    ),
    GoRoute(
      path: '/rent-a-car',
      pageBuilder: (context, state) => _buildCupertinoPage(const RentACarScreen(), state),
    ),
    GoRoute(
      path: '/dealership-identity',
      pageBuilder: (context, state) => _buildCupertinoPage(const DealershipIdentityScreen(), state),
    ),
    GoRoute(
      path: '/theme-store',
      pageBuilder: (context, state) => _buildCupertinoPage(const ThemeStoreScreen(), state),
    ),
    GoRoute(
      path: '/character-growth',
      pageBuilder: (context, state) => _buildCupertinoPage(const CharacterGrowthScreen(), state),
    ),
    GoRoute(
      path: '/casino',
      pageBuilder: (context, state) => _buildCupertinoPage(const CasinoHubScreen(), state),
    ),
    GoRoute(
      path: '/auction',
      pageBuilder: (context, state) => _buildCupertinoPage(const AuctionScreen(), state),
    ),
    GoRoute(
      path: '/branches',
      pageBuilder: (context, state) => _buildCupertinoPage(const BranchScreen(), state),
    ),
    GoRoute(
      path: '/marketplace',
      pageBuilder: (context, state) => _buildCupertinoPage(const MarketplaceScreen(), state),
    ),
    GoRoute(
      path: '/expertise',
      pageBuilder: (context, state) {
        final listing = state.extra as ListingModel?;
        if (listing == null) {
          return _buildCupertinoPage(const MarketplaceScreen(), state);
        }
        return _buildCupertinoPage(ExpertiseScreen(listing: listing), state);
      },
    ),
    GoRoute(
      path: '/workshop',
      pageBuilder: (context, state) => _buildCupertinoPage(const WorkshopScreen(), state),
    ),
    GoRoute(
      path: '/showroom',
      pageBuilder: (context, state) => _buildCupertinoPage(const ShowroomScreen(), state),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildCupertinoPage(const SettingsScreen(), state),
    ),
    GoRoute(
      path: '/listing-detail',
      pageBuilder: (context, state) {
        final listing = state.extra as ListingModel?;
        if (listing == null) {
          return _buildCupertinoPage(const MarketplaceScreen(), state);
        }
        return _buildCupertinoPage(ListingDetailScreen(listing: listing), state);
      },
    ),
    GoRoute(
      path: '/negotiation',
      pageBuilder: (context, state) {
        final listing = state.extra as ListingModel?;
        if (listing == null) {
          return _buildCupertinoPage(const MarketplaceScreen(), state);
        }
        return _buildCupertinoPage(NegotiationScreen(listing: listing), state);
      },
    ),
    GoRoute(
      path: '/special-plates',
      pageBuilder: (context, state) => _buildCupertinoPage(const SpecialPlateScreen(), state),
    ),
    GoRoute(
      path: '/media-agency',
      pageBuilder: (context, state) => _buildCupertinoPage(const MediaAgencyScreen(), state),
    ),
    GoRoute(
      path: '/lifestyle',
      pageBuilder: (context, state) => _buildCupertinoPage(const LifestyleScreen(), state),
    ),
    GoRoute(
      path: '/album',
      pageBuilder: (context, state) => _buildCupertinoPage(const CollectionAlbumScreen(), state),
    ),
    GoRoute(
      path: '/create-listing',
      pageBuilder: (context, state) {
        final car = state.extra as CarModel?;
        if (car == null) {
          return _buildCupertinoPage(const ShowroomScreen(), state);
        }
        return _buildCupertinoPage(CreateListingScreen(car: car), state);
      },
    ),
    GoRoute(
      path: '/offer-evaluation',
      pageBuilder: (context, state) {
        final args = state.extra as OfferEvaluationArgs?;
        if (args == null) {
          return _buildCupertinoPage(const ShowroomScreen(), state);
        }
        return _buildCupertinoPage(OfferEvaluationScreen(args: args), state);
      },
    ),
  ],
);
