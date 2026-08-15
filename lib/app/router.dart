import 'package:flutter/cupertino.dart';
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
import '../presentation/screens/finance/daily_cashflow_screen.dart';
import '../presentation/screens/rent_a_car/rent_a_car_screen.dart';
import '../presentation/screens/side_business/side_business_screen.dart';
import '../presentation/screens/stock_market/stock_market_screen.dart';
import '../presentation/screens/workshop/tuning_studio_screen.dart';
import '../presentation/screens/finance/bank_investments_screen.dart';
import '../presentation/screens/staff/staff_academy_screen.dart';
import '../presentation/screens/branch/showroom_decor_screen.dart';
import '../presentation/screens/scrapyard/scrapyard_screen.dart';
import '../presentation/screens/black_market/black_market_screen.dart';

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
      path: '/dashboard',
      pageBuilder: (context, state) => _buildCupertinoPage(const DashboardScreen(), state),
    ),
    GoRoute(
      path: '/scrapyard',
      pageBuilder: (context, state) => _buildCupertinoPage(const ScrapyardScreen(), state),
    ),
    GoRoute(
      path: '/black-market',
      pageBuilder: (context, state) => _buildCupertinoPage(const BlackMarketScreen(), state),
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
  ],
);
