import 'package:flutter/material.dart';

// HMS Color Palette
const Color kPrimaryColor = Color(0xFF0A6EBD);
const Color kPrimaryDark = Color(0xFF064E8A);
const Color kPrimaryLight = Color(0xFF4DA8E0);
const Color kAccentColor = Color(0xFF00C9A7);
const Color kAccentLight = Color(0xFF5EEAD4);
const Color kDangerColor = Color(0xFFE53E3E);
const Color kWarningColor = Color(0xFFED8936);
const Color kSuccessColor = Color(0xFF38A169);
const Color kInfoColor = Color(0xFF3182CE);

// Background Colors
const Color kBgLight = Color(0xFFF0F4F8);
const Color kBgWhite = Color(0xFFFFFFFF);
const Color kBgDark = Color(0xFF1A202C);
const Color kBgCard = Color(0xFFFFFFFF);

// Text Colors
const Color kTextDark = Color(0xFF1A202C);
const Color kTextMedium = Color(0xFF4A5568);
const Color kTextLight = Color(0xFF718096);
const Color kTextWhite = Color(0xFFFFFFFF);

// Border Colors
const Color kBorderColor = Color(0xFFE2E8F0);

// Gradient Colors
const LinearGradient kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0A6EBD), Color(0xFF064E8A)],
);

const LinearGradient kAccentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF00C9A7), Color(0xFF0A6EBD)],
);

const LinearGradient kEmergencyGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
);

// Shadows
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

const List<BoxShadow> kSoftShadow = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

// Border Radius
const double kBorderRadius = 16.0;
const double kBorderRadiusLarge = 24.0;
const double kBorderRadiusSmall = 8.0;

// Spacing
const double kSpacingXS = 4.0;
const double kSpacingS = 8.0;
const double kSpacingM = 16.0;
const double kSpacingL = 24.0;
const double kSpacingXL = 32.0;

// Input Border
const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(
    color: kBorderColor,
    width: 1,
  ),
);

const focusedInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(
    color: kPrimaryColor,
    width: 1.5,
  ),
);

// User Roles
enum UserRole {
  admin,
  doctor,
  nurse,
  labTech,
  pharmacist,
  cashier,
  patient,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse';
      case UserRole.labTech:
        return 'Lab Technician';
      case UserRole.pharmacist:
        return 'Pharmacist';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.patient:
        return 'Patient';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.admin:
        return const Color(0xFF6B46C1);
      case UserRole.doctor:
        return const Color(0xFF0A6EBD);
      case UserRole.nurse:
        return const Color(0xFF00C9A7);
      case UserRole.labTech:
        return const Color(0xFFED8936);
      case UserRole.pharmacist:
        return const Color(0xFF38A169);
      case UserRole.cashier:
        return const Color(0xFFE53E3E);
      case UserRole.patient:
        return const Color(0xFF3182CE);
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.nurse:
        return Icons.local_hospital;
      case UserRole.labTech:
        return Icons.science;
      case UserRole.pharmacist:
        return Icons.medication;
      case UserRole.cashier:
        return Icons.point_of_sale;
      case UserRole.patient:
        return Icons.person;
    }
  }
}