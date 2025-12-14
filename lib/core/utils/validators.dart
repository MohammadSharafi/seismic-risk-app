class Validators {
  static String? validateYear(int? year) {
    if (year == null) {
      return 'Please enter a year';
    }
    if (year < 1800 || year > DateTime.now().year) {
      return 'Please enter a valid year';
    }
    return null;
  }

  static String? validateFloors(int? floors) {
    if (floors == null) {
      return 'Please enter number of floors';
    }
    if (floors < 1 || floors > 50) {
      return 'Number of floors must be between 1 and 50';
    }
    return null;
  }

  static String? validateLocation(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return 'Please select a location';
    }
    // Turkey bounds validation
    if (lat < 35.8 || lat > 42.1 || lng < 25.7 || lng > 44.8) {
      return 'Location must be within Turkey';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

