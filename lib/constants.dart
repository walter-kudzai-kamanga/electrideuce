import 'package:flutter/material.dart';

// HMS Premium Color Palette
const Color kPrimaryColor = Color(0xFF0F67FD); // Vibrant Electric Blue
const Color kPrimaryDark = Color(0xFF0038A7);
const Color kPrimaryLight = Color(0xFF5394FF);
const Color kAccentColor = Color(0xFF00F2FE); // Cyan Glow
const Color kNeonGreen = Color(0xFF00FF87);
const Color kRoyalPurple = Color(0xFF7000FF);

const Color kDangerColor = Color(0xFFFF4D4D);
const Color kWarningColor = Color(0xFFFFAB2D);
const Color kSecondaryColor = Color(0xFF6366F1); // Indigo
const Color kSuccessColor = Color(0xFF00D1FF); // Modern blue-ish success
const Color kInfoColor = Color(0xFF3182CE);

// Background Colors
const Color kBgLight = Color(0xFFF8FAFF); // Very light blue tint
const Color kBgWhite = Color(0xFFFFFFFF);
const Color kBgDark = Color(0xFF0A0E21); // Deep space dark
const Color kBgCard = Color(0xFFFFFFFF);

// Text Colors
const Color kTextDark = Color(0xFF0F172A); // Slate 900
const Color kTextMedium = Color(0xFF475569); // Slate 600
const Color kTextLight = Color(0xFF94A3B8); // Slate 400
const Color kTextWhite = Color(0xFFFFFFFF);

// Border Colors
const Color kBorderColor = Color(0xFFE2E8F0);

// Premium Gradients
const LinearGradient kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F67FD), Color(0xFF0038A7)],
);

const LinearGradient kGlassGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white,
    Color(0x33FFFFFF),
  ],
);

const LinearGradient kOceanGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
);

// Glassmorphism Tokens
const double kGlassBlur = 20.0;
const double kGlassOpacity = 0.15;
final Color kGlassBorder = Colors.white.withOpacity(0.2);

// Shadows
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x0D0F172A),
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
];

const List<BoxShadow> kSoftShadow = [
  BoxShadow(
    color: Color(0x080F172A),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

const List<BoxShadow> kGlowShadow = [
  BoxShadow(
    color: Color(0x4D0F67FD),
    blurRadius: 20,
    offset: Offset(0, 4),
  ),
];

// Border Radius
const double kBorderRadius = 20.0;
const double kBorderRadiusLarge = 32.0;
const double kBorderRadiusSmall = 12.0;

// Spacing
const double kSpacingXS = 4.0;
const double kSpacingS = 8.0;
const double kSpacingM = 16.0;
const double kSpacingL = 24.0;
const double kSpacingXL = 32.0;

// Input Border
const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusSmall)),
  borderSide: BorderSide(
    color: kBorderColor,
    width: 1,
  ),
);

const focusedInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusSmall)),
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
        return 'Administrator';
      case UserRole.doctor:
        return 'Specialist Doctor';
      case UserRole.nurse:
        return 'Nursing Staff';
      case UserRole.labTech:
        return 'Lab Technician';
      case UserRole.pharmacist:
        return 'Pharmacist';
      case UserRole.cashier:
        return 'Billing Officer';
      case UserRole.patient:
        return 'Patient';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.admin:
        return kRoyalPurple;
      case UserRole.doctor:
        return kPrimaryColor;
      case UserRole.nurse:
        return kAccentColor;
      case UserRole.labTech:
        return kWarningColor;
      case UserRole.pharmacist:
        return kNeonGreen;
      case UserRole.cashier:
        return kDangerColor;
      case UserRole.patient:
        return kInfoColor;
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.doctor:
        return Icons.medical_services_rounded;
      case UserRole.nurse:
        return Icons.local_hospital_rounded;
      case UserRole.labTech:
        return Icons.science_rounded;
      case UserRole.pharmacist:
        return Icons.medication_rounded;
      case UserRole.cashier:
        return Icons.point_of_sale_rounded;
      case UserRole.patient:
        return Icons.person_rounded;
    }
  }
}
