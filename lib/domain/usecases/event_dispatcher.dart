import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/staff_model.dart';
import '../../data/models/game_event_model.dart';

class EventDispatcher {
  /// Processes daily car wash decay and triggers the Muddy Rain random event.
  /// Returns the updated car list and any new game events generated.
  static (List<CarModel>, List<GameEventModel>) processCarWashDecayAndMuddyRain({
    required List<CarModel> cars,
    required List<GameEventModel> events,
    required Random random,
  }) {
    // 5% chance every day for muddy rain
    final bool isMuddyRain = random.nextDouble() < 0.05;
    final List<CarModel> updatedCars = [];
    bool muddyRainApplied = false;

    for (final car in cars) {
      if (isMuddyRain && car.isListed && !car.isRented && !car.isLockedInShowcase) {
        // Cars out in the open get muddy
        updatedCars.add(car.copyWith(
          isWashed: false,
          isPolished: false,
          isDetailedCleaned: false,
          hasMuddyPenalty: true,
          washDurationRemaining: 0,
        ));
        muddyRainApplied = true;
      } else {
        // Normal wash duration decay
        int newWashDuration = car.washDurationRemaining;
        bool newlyDirtied = false;
        
        if (car.isWashed || car.isPolished || car.isDetailedCleaned || car.hasMuddyPenalty) {
          if (newWashDuration > 0) {
            newWashDuration -= 1;
            if (newWashDuration <= 0) {
              newWashDuration = 0;
              newlyDirtied = true;
            }
          } else {
            // If it already has 0 duration but is still washed, decay it now
            newlyDirtied = true;
          }
        }
        
        if (newlyDirtied) {
          updatedCars.add(car.copyWith(
            isWashed: false,
            isPolished: false,
            isDetailedCleaned: false, // Let's say all wash effects wear off
            hasMuddyPenalty: false, // muddy penalty also wears off naturally if not washed
            washDurationRemaining: 0,
          ));
        } else {
          updatedCars.add(car.copyWith(washDurationRemaining: newWashDuration));
        }
      }
    }

    if (muddyRainApplied) {
      events.insert(0, GameEventModel(
        id: 'muddy_rain_${DateTime.now().millisecondsSinceEpoch}',
        title: 'event_muddy_rain_title',
        description: 'event_muddy_rain_desc',
        type: GameEventType.expense,
        amount: 0.0,
        date: DateTime.now(),
        choices: [
          GameEventChoice(label: 'event_ok', resultText: ''),
        ],
      ));
    }

    return (updatedCars, events);
  }

  /// Processes natural daily morale decay for staff.
  static List<StaffModel> processStaffMoraleDecay(List<StaffModel> staff, Random random) {
    return staff.map((s) {
      // 20% chance each day for staff to lose 1 morale point from daily stress
      if (random.nextDouble() < 0.20) {
        return s.copyWith(morale: max(0, s.morale - 1));
      }
      return s;
    }).toList();
  }
}
