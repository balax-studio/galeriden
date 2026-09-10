import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/branch_model.dart';

void main() {
  group('Branch Deed State Persistence Tests', () {
    test('1. ownedBranchDeeds serializes to JSON and deserializes cleanly', () {
      final initial = DealershipModel.initial();
      expect(initial.ownedBranchDeeds, isEmpty);

      // Add branch_1 and branch_2 deeds
      final updated = initial.copyWith(
        ownedBranchDeeds: {'branch_1', 'branch_2'},
      );

      final jsonMap = updated.toJson();
      expect(jsonMap['ownedBranchDeeds'], isNotNull);
      expect(jsonMap['ownedBranchDeeds'], containsAll(['branch_1', 'branch_2']));

      final restored = DealershipModel.fromJson(jsonMap);
      expect(restored.ownedBranchDeeds, containsAll(['branch_1', 'branch_2']));
      expect(restored.ownedBranchDeeds.length, equals(2));

      // Verify branch model acknowledges ownership
      final branches = BranchModel.getAllBranches(ownedDeeds: restored.ownedBranchDeeds);
      final branch1 = branches.firstWhere((b) => b.id == 'branch_1');
      final branch2 = branches.firstWhere((b) => b.id == 'branch_2');
      final branch3 = branches.firstWhere((b) => b.id == 'branch_3');

      expect(branch1.isDeedOwned, isTrue);
      expect(branch2.isDeedOwned, isTrue);
      expect(branch3.isDeedOwned, isFalse);
    });

    test('2. Backward compatibility: missing ownedBranchDeeds in JSON defaults to empty set', () {
      final jsonMap = DealershipModel.initial().toJson();
      jsonMap.remove('ownedBranchDeeds');

      final restored = DealershipModel.fromJson(jsonMap);
      expect(restored.ownedBranchDeeds, isEmpty);
    });
  });
}
