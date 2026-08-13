import 'package:go_router/go_router.dart';
import '../data/models/listing_model.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/expertise/expertise_screen.dart';
import '../presentation/screens/marketplace/listing_detail_screen.dart';
import '../presentation/screens/marketplace/marketplace_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/showroom/showroom_screen.dart';
import '../presentation/screens/workshop/workshop_screen.dart';

import '../presentation/screens/auction/auction_screen.dart';
import '../presentation/screens/branch/branch_screen.dart';
import '../presentation/screens/character/character_growth_screen.dart';

import '../presentation/screens/settings/dealership_identity_screen.dart';
import '../presentation/screens/settings/theme_store_screen.dart';
import '../presentation/screens/staff/staff_screen.dart';
import '../presentation/screens/car_wash/car_wash_screen.dart';
import '../presentation/screens/reviews/customer_reviews_screen.dart';
import '../presentation/screens/history/sales_history_screen.dart';
import '../presentation/screens/finance/finance_screen.dart';
import '../presentation/screens/rent_a_car/rent_a_car_screen.dart';
import '../presentation/screens/side_business/side_business_screen.dart';
import '../presentation/screens/stock_market/stock_market_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  errorBuilder: (context, state) => const DashboardScreen(),
  routes: [
    GoRoute(
      path: '/market',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/side-businesses',
      builder: (context, state) => const SideBusinessScreen(),
    ),
    GoRoute(
      path: '/stock-market',
      builder: (context, state) => const StockMarketScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const SalesHistoryScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/staff',
      builder: (context, state) => const StaffScreen(),
    ),
    GoRoute(
      path: '/car-wash',
      builder: (context, state) => const CarWashScreen(),
    ),
    GoRoute(
      path: '/reviews',
      builder: (context, state) => const CustomerReviewsScreen(),
    ),
    GoRoute(
      path: '/finance',
      builder: (context, state) => const FinanceScreen(),
    ),
    GoRoute(
      path: '/rent-a-car',
      builder: (context, state) => const RentACarScreen(),
    ),
    GoRoute(
      path: '/dealership-identity',
      builder: (context, state) => const DealershipIdentityScreen(),
    ),
    GoRoute(
      path: '/theme-store',
      builder: (context, state) => const ThemeStoreScreen(),
    ),
    GoRoute(
      path: '/character-growth',
      builder: (context, state) => const CharacterGrowthScreen(),
    ),
    GoRoute(
      path: '/auction',
      builder: (context, state) => const AuctionScreen(),
    ),
    GoRoute(
      path: '/branches',
      builder: (context, state) => const BranchScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/expertise',
      builder: (context, state) {
        final listing = state.extra as ListingModel;
        return ExpertiseScreen(listing: listing);
      },
    ),
    GoRoute(
      path: '/workshop',
      builder: (context, state) => const WorkshopScreen(),
    ),
    GoRoute(
      path: '/showroom',
      builder: (context, state) => const ShowroomScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/listing-detail',
      builder: (context, state) {
        final listing = state.extra as ListingModel;
        return ListingDetailScreen(listing: listing);
      },
    ),
  ],
);
