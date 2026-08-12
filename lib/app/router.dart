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

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
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
