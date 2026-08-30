import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/models/tuning_model.dart';

enum OperationSuspenseType {
  washFoam,
  washInterior,
  washPolish,
  washCeramic,
  tuningPowertrain,
  tuningAero,
  tuningStance,
  tuningExhaust,
  tuningPreset,
  generalWork;

  static OperationSuspenseType fromWashServiceId(String serviceId) {
    switch (serviceId) {
      case 'pkg1':
        return OperationSuspenseType.washFoam;
      case 'pkg2':
        return OperationSuspenseType.washInterior;
      case 'pkg3':
        return OperationSuspenseType.washPolish;
      case 'pkg4':
        return OperationSuspenseType.washCeramic;
      default:
        return OperationSuspenseType.washFoam;
    }
  }

  static OperationSuspenseType fromTuningCategory(TuningCategory category) {
    switch (category) {
      case TuningCategory.powertrain:
        return OperationSuspenseType.tuningPowertrain;
      case TuningCategory.aero:
        return OperationSuspenseType.tuningAero;
      case TuningCategory.stance:
        return OperationSuspenseType.tuningStance;
      case TuningCategory.exhaust:
        return OperationSuspenseType.tuningExhaust;
    }
  }

  String get titleKey {
    switch (this) {
      case OperationSuspenseType.washFoam:
        return 'op_wash_foam_title';
      case OperationSuspenseType.washInterior:
        return 'op_wash_interior_title';
      case OperationSuspenseType.washPolish:
        return 'op_wash_polish_title';
      case OperationSuspenseType.washCeramic:
        return 'op_wash_ceramic_title';
      case OperationSuspenseType.tuningPowertrain:
        return 'op_tuning_powertrain_title';
      case OperationSuspenseType.tuningAero:
        return 'op_tuning_aero_title';
      case OperationSuspenseType.tuningStance:
        return 'op_tuning_stance_title';
      case OperationSuspenseType.tuningExhaust:
        return 'op_tuning_exhaust_title';
      case OperationSuspenseType.tuningPreset:
        return 'op_tuning_preset_title';
      case OperationSuspenseType.generalWork:
        return 'op_general_work_title';
    }
  }

  IconData get icon {
    switch (this) {
      case OperationSuspenseType.washFoam:
        return Icons.water_drop_rounded;
      case OperationSuspenseType.washInterior:
        return Icons.dry_cleaning_rounded;
      case OperationSuspenseType.washPolish:
        return Icons.blur_circular_rounded;
      case OperationSuspenseType.washCeramic:
        return Icons.auto_awesome_rounded;
      case OperationSuspenseType.tuningPowertrain:
        return Icons.speed_rounded;
      case OperationSuspenseType.tuningAero:
        return Icons.shield_rounded;
      case OperationSuspenseType.tuningStance:
        return Icons.tune_rounded;
      case OperationSuspenseType.tuningExhaust:
        return Icons.volume_up_rounded;
      case OperationSuspenseType.tuningPreset:
        return Icons.all_inclusive_rounded;
      case OperationSuspenseType.generalWork:
        return Icons.build_circle_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case OperationSuspenseType.washFoam:
        return const Color(0xFF00E575);
      case OperationSuspenseType.washInterior:
        return const Color(0xFF38BDF8);
      case OperationSuspenseType.washPolish:
        return const Color(0xFFFFDE59);
      case OperationSuspenseType.washCeramic:
        return const Color(0xFFA855F7);
      case OperationSuspenseType.tuningPowertrain:
        return AppColors.brutalRed;
      case OperationSuspenseType.tuningAero:
        return const Color(0xFFA855F7);
      case OperationSuspenseType.tuningStance:
        return const Color(0xFF38BDF8);
      case OperationSuspenseType.tuningExhaust:
        return AppColors.brutalOrange;
      case OperationSuspenseType.tuningPreset:
        return AppColors.brutalYellow;
      case OperationSuspenseType.generalWork:
        return AppColors.brutalYellow;
    }
  }

  List<String> get stageKeys {
    switch (this) {
      case OperationSuspenseType.washFoam:
        return [
          'op_wash_foam_stage1',
          'op_wash_foam_stage2',
          'op_wash_foam_stage3',
        ];
      case OperationSuspenseType.washInterior:
        return [
          'op_wash_interior_stage1',
          'op_wash_interior_stage2',
          'op_wash_interior_stage3',
        ];
      case OperationSuspenseType.washPolish:
        return [
          'op_wash_polish_stage1',
          'op_wash_polish_stage2',
          'op_wash_polish_stage3',
        ];
      case OperationSuspenseType.washCeramic:
        return [
          'op_wash_ceramic_stage1',
          'op_wash_ceramic_stage2',
          'op_wash_ceramic_stage3',
        ];
      case OperationSuspenseType.tuningPowertrain:
        return [
          'op_tuning_powertrain_stage1',
          'op_tuning_powertrain_stage2',
          'op_tuning_powertrain_stage3',
        ];
      case OperationSuspenseType.tuningAero:
        return [
          'op_tuning_aero_stage1',
          'op_tuning_aero_stage2',
          'op_tuning_aero_stage3',
        ];
      case OperationSuspenseType.tuningStance:
        return [
          'op_tuning_stance_stage1',
          'op_tuning_stance_stage2',
          'op_tuning_stance_stage3',
        ];
      case OperationSuspenseType.tuningExhaust:
        return [
          'op_tuning_exhaust_stage1',
          'op_tuning_exhaust_stage2',
          'op_tuning_exhaust_stage3',
        ];
      case OperationSuspenseType.tuningPreset:
        return [
          'op_tuning_preset_stage1',
          'op_tuning_preset_stage2',
          'op_tuning_preset_stage3',
        ];
      case OperationSuspenseType.generalWork:
        return [
          'op_general_work_stage1',
          'op_general_work_stage2',
          'op_general_work_stage3',
        ];
    }
  }

  List<int> generateStageDurations({Random? rng}) {
    final r = rng ?? Random();
    // Stage 1: 850ms - 1300ms
    final s1 = 850 + r.nextInt(451);
    // Stage 2: 1000ms - 1550ms
    final s2 = 1000 + r.nextInt(551);
    // Stage 3: 850ms - 1350ms
    final s3 = 850 + r.nextInt(501);
    return [s1, s2, s3];
  }
}
