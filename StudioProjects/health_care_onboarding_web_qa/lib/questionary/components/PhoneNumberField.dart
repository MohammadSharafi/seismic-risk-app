import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber_platform_interface/flutter_libphonenumber_platform_interface.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

class PhoneNumberInputWidget extends StatefulWidget {
  final ValueChanged<String>? onPhoneNumberChanged;
  final String? initialCountry;
  final String? initialPhoneNumber;

  const PhoneNumberInputWidget({
    Key? key,
    this.onPhoneNumberChanged,
    this.initialCountry,
    this.initialPhoneNumber,
  }) : super(key: key);

  @override
  _PhoneNumberInputWidgetState createState() => _PhoneNumberInputWidgetState();
}

class _PhoneNumberInputWidgetState extends State<PhoneNumberInputWidget> {
  late final _future = FlutterLibphonenumberPlatform.instance.init();
  final phoneController = TextEditingController();
  CountryWithPhoneCode _currentCountry = const CountryWithPhoneCode.us();

  @override
  void initState() {
    super.initState();
    if (widget.initialCountry != null) {
      _setInitialCountry(widget.initialCountry!);
    }
    if (widget.initialPhoneNumber != null) {
      phoneController.text = widget.initialPhoneNumber!;
    }
    phoneController.addListener(_onPhoneNumberChangedInternal);
  }

  @override
  void dispose() {
    phoneController.removeListener(_onPhoneNumberChangedInternal);
    phoneController.dispose();
    super.dispose();
  }

  void _onPhoneNumberChangedInternal() {
    final phoneNumberWithCountryCode = '+${_currentCountry.phoneCode}${phoneController.text}';
  bool isValid  =isValidPhoneNumber(phoneNumberWithCountryCode);
    if (isValid) {
      widget.onPhoneNumberChanged?.call(phoneNumberWithCountryCode.replaceAll(' ', '').replaceAll('-', ''));
    } else {
      widget.onPhoneNumberChanged?.call('');
    }
  }

  // Function to validate phone number
  bool isValidPhoneNumber(String phoneNumber)  {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s-]+'), '');

    // Regex pattern: starts with +, followed by 1-3 digit country code, then 6-14 digits
    final RegExp phoneRegex = RegExp(r'^\+\d{1,3}\d{6,14}$');

    return phoneRegex.hasMatch(cleanedNumber);
  }
  Future<void> _setInitialCountry(String countryName) async {
    await _future;
    final country = CountryManager().countries.firstWhere(
          (c) => c.countryName == countryName,
      orElse: () => const CountryWithPhoneCode.us(),
    );
    setState(() {
      _currentCountry = country;
    });
  }

  Future<void> _selectCountry(BuildContext context) async {
    final sortedCountries = CountryManager().countries
      ..sort((a, b) => (a.countryName ?? '').compareTo(b.countryName ?? ''));

    final selectedCountry = await showModalBottomSheet<CountryWithPhoneCode>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Country Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedCountries.length,
                itemBuilder: (context, index) {
                  final country = sortedCountries[index];
                  return ListTile(
                    leading: Text('+${country.phoneCode}'),
                    title: Text(country.countryName ?? ''),
                    onTap: () => Navigator.pop(context, country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedCountry != null && selectedCountry != _currentCountry) {
      setState(() {
        _currentCountry = selectedCountry;
        phoneController.clear(); // Clear input when country changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error initializing phone number library'));
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Row(
            children: [
              GestureDetector(
                onTap: () => _selectCountry(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('+${_currentCountry.phoneCode}',
                          style: const TextStyle(fontSize: 16)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  inputFormatters: [
                    LibPhonenumberTextFormatter(
                      country: _currentCountry,
                      phoneNumberType: PhoneNumberType.mobile,
                      phoneNumberFormat: PhoneNumberFormat.international,
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}