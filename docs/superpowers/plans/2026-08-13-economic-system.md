# Economy and Passive Income System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement installment sales (vadeli/çek), Rent a Car mechanics, and their associated risks/rewards to add economic depth to the Tycoon game.

**Architecture:** We will introduce new data models for financial instruments (`InstallmentContract`, `Cheque`) and rentals (`RentalAgreement`). These will be integrated into the central `DealershipModel` state. The game engine's day-transition logic (`GameNotifier.advanceGameDay()`) will process periodic income, payments, and risk events (defaults, damages). New UI tabs will surface these mechanics.

**Tech Stack:** Flutter, Dart, Riverpod (Notifier/StateNotifier).

## Global Constraints

- Do not use loose types. Standardize monetary values as `double` or `int`.
- Do not break existing car sales logic; vadeli (installment) sale is just an additional "offer type".
- `flutter analyze` must pass with 0 issues.
- `flutter test` must pass.

---

### Task 1: Core Models for Finance & Rental

**Files:**
- Create: `lib/data/models/cheque_model.dart`
- Create: `lib/data/models/installment_contract_model.dart`
- Create: `lib/data/models/rental_agreement_model.dart`
- Modify: `lib/data/models/offer_model.dart`

**Interfaces:**
- Produces: `Cheque`, `InstallmentContract`, `RentalAgreement` classes. `OfferType` enum (`cash`, `installment`, `cheque`).

- [ ] **Step 1: Modify `OfferModel`**
Add `OfferType` enum and field to `OfferModel`.

```dart
// In lib/data/models/offer_model.dart
enum OfferType { cash, installment, cheque }

// Add to OfferModel:
// final OfferType offerType;
// update constructor, toJson, fromJson. default to OfferType.cash for backward compatibility.
```

- [ ] **Step 2: Create `Cheque` model**

```dart
// lib/data/models/cheque_model.dart
class Cheque {
  final String id;
  final String customerName;
  final double amount;
  final int daysUntilDue;
  final bool isDefaulted;

  Cheque({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.daysUntilDue,
    this.isDefaulted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'amount': amount,
    'daysUntilDue': daysUntilDue,
    'isDefaulted': isDefaulted,
  };

  factory Cheque.fromJson(Map<String, dynamic> json) => Cheque(
    id: json['id'],
    customerName: json['customerName'],
    amount: (json['amount'] as num).toDouble(),
    daysUntilDue: json['daysUntilDue'] ?? 0,
    isDefaulted: json['isDefaulted'] ?? false,
  );
  
  Cheque copyWith({int? daysUntilDue, bool? isDefaulted}) {
      return Cheque(
          id: id,
          customerName: customerName,
          amount: amount,
          daysUntilDue: daysUntilDue ?? this.daysUntilDue,
          isDefaulted: isDefaulted ?? this.isDefaulted,
      );
  }
}
```

- [ ] **Step 3: Create `InstallmentContract` model**

```dart
// lib/data/models/installment_contract_model.dart
class InstallmentContract {
  final String id;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double installmentAmount;
  final int totalInstallments;
  final int paidInstallments;
  final int daysUntilNextPayment;
  final bool isDefaulted;

  InstallmentContract({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.installmentAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.daysUntilNextPayment,
    this.isDefaulted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'customerName': customerName, 'totalAmount': totalAmount,
    'paidAmount': paidAmount, 'installmentAmount': installmentAmount,
    'totalInstallments': totalInstallments, 'paidInstallments': paidInstallments,
    'daysUntilNextPayment': daysUntilNextPayment, 'isDefaulted': isDefaulted
  };

  factory InstallmentContract.fromJson(Map<String, dynamic> json) => InstallmentContract(
    id: json['id'], customerName: json['customerName'],
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paidAmount: (json['paidAmount'] as num).toDouble(),
    installmentAmount: (json['installmentAmount'] as num).toDouble(),
    totalInstallments: json['totalInstallments'],
    paidInstallments: json['paidInstallments'],
    daysUntilNextPayment: json['daysUntilNextPayment'],
    isDefaulted: json['isDefaulted'] ?? false,
  );
  
  InstallmentContract copyWith({double? paidAmount, int? paidInstallments, int? daysUntilNextPayment, bool? isDefaulted}) {
      return InstallmentContract(
          id: id, customerName: customerName, totalAmount: totalAmount,
          paidAmount: paidAmount ?? this.paidAmount,
          installmentAmount: installmentAmount,
          totalInstallments: totalInstallments,
          paidInstallments: paidInstallments ?? this.paidInstallments,
          daysUntilNextPayment: daysUntilNextPayment ?? this.daysUntilNextPayment,
          isDefaulted: isDefaulted ?? this.isDefaulted,
      );
  }
}
```

- [ ] **Step 4: Create `RentalAgreement` model**

```dart
// lib/data/models/rental_agreement_model.dart
class RentalAgreement {
  final String id;
  final String carId;
  final double dailyRate;
  final int rentedDays;
  final double totalEarned;

  RentalAgreement({
    required this.id,
    required this.carId,
    required this.dailyRate,
    this.rentedDays = 0,
    this.totalEarned = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'carId': carId, 'dailyRate': dailyRate,
    'rentedDays': rentedDays, 'totalEarned': totalEarned,
  };

  factory RentalAgreement.fromJson(Map<String, dynamic> json) => RentalAgreement(
    id: json['id'], carId: json['carId'],
    dailyRate: (json['dailyRate'] as num).toDouble(),
    rentedDays: json['rentedDays'] ?? 0,
    totalEarned: (json['totalEarned'] as num).toDouble(),
  );
  
  RentalAgreement copyWith({int? rentedDays, double? totalEarned}) {
      return RentalAgreement(
          id: id, carId: carId, dailyRate: dailyRate,
          rentedDays: rentedDays ?? this.rentedDays,
          totalEarned: totalEarned ?? this.totalEarned,
      );
  }
}
```

---

### Task 2: State Integration (DealershipModel & CarModel)

**Files:**
- Modify: `lib/data/models/car_model.dart`
- Modify: `lib/data/models/dealership_model.dart`

**Interfaces:**
- Consumes: `Cheque`, `InstallmentContract`, `RentalAgreement`

- [ ] **Step 1: Modify `CarModel`**
Add `isRented` boolean flag.

```dart
// Add to CarModel properties, constructor, copyWith, toJson, fromJson
// final bool isRented; // default false
```

- [ ] **Step 2: Modify `DealershipModel`**
Add the new lists to manage financial state.

```dart
// Add to DealershipModel properties, constructor, copyWith, toJson, fromJson
// final List<Cheque> cheques; // default []
// final List<InstallmentContract> installmentContracts; // default []
// final List<RentalAgreement> rentalAgreements; // default []
```

---

### Task 3: Economy Engine Integration (GameNotifier)

**Files:**
- Modify: `lib/presentation/providers/game_provider.dart`

**Interfaces:**
- Consumes: Modified `DealershipModel`, Financial models.

- [ ] **Step 1: Handle Rent-a-Car mechanics in `advanceGameDay()`**
In the day transition logic, iterate over `rentalAgreements`:
- Calculate income (`dailyRate`), add to dealership balance.
- Process 3% chance for minor damage, 1% chance for total loss (pert).
- Update `rentedDays` and `totalEarned`.
- If car is damaged, update the respective `CarModel` inside `ownedCars`.

- [ ] **Step 2: Handle Installments & Cheques in `advanceGameDay()`**
- Decrement `daysUntilDue` for cheques. If 0, process payment (add to balance) with 5% risk of default (`isDefaulted = true`).
- Decrement `daysUntilNextPayment` for installments. If 0, process payment, increment `paidInstallments`, reset `daysUntilNextPayment` to 30. 5% risk of default.

- [ ] **Step 3: Expose methods to accept offers and rent cars**
```dart
// In GameNotifier:
// void acceptOffer(OfferModel offer) -> Handle cash, installment (create InstallmentContract), cheque (create Cheque).
// void rentCar(String carId) -> Sets isRented = true, creates RentalAgreement.
// void returnRentedCar(String agreementId) -> Removes RentalAgreement, sets isRented = false, increases mileage/decreases value.
// void collectDefaultedPayment(String id, String type) -> 50% recovery via lawyer, removes from list.
```

---

### Task 4: UI - Rent a Car & Finance Pages

**Files:**
- Create: `lib/presentation/pages/finance_page.dart`
- Create: `lib/presentation/pages/rent_a_car_page.dart`
- Modify: `lib/presentation/pages/home_page.dart` (or wherever navigation is handled)

- [ ] **Step 1: Create `finance_page.dart`**
A simple list view showing `cheques` and `installmentContracts` from the provider. Show status (due in X days, or Defaulted). Include a button to "Hire Lawyer" for defaulted payments (calls `collectDefaultedPayment`).

- [ ] **Step 2: Create `rent_a_car_page.dart`**
Two tabs or sections: 
1. "Available Cars": Lists `ownedCars` where `isRented == false`. Button to "Rent Out" (calculates daily rate as ~0.5% of market value).
2. "Rented Cars": Lists `rentalAgreements`. Shows daily income, total earned. Button to "Recall/Return".

- [ ] **Step 3: Link pages in Navigation**
Add buttons/links in the main menu or home screen to access "Finance" and "Rent a Car".

---

### Task 5: Testing & Validation

**Files:**
- Create: `test/economy_system_test.dart`

- [ ] **Step 1: Write integration tests**
```dart
// Verify that advancing a day correctly updates rental income and cheque days.
// Verify defaulting mechanics trigger correctly given a mocked random seed.
```

- [ ] **Step 2: Run tests and analyze**
Run `flutter test` and `flutter analyze` to ensure zero issues.
