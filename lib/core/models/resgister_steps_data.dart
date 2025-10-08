import 'package:lipa_quick/core/models/IdentityResponse.dart';
import 'package:lipa_quick/core/models/address.dart';
import 'package:lipa_quick/ui/views/register/register.dart';

class RegisterStep {
  String? firstName, secondName, IdNumber, dob, email, phone, password;
  IdentityDetails? details;
  Gender gender;
  String? street, city, state, country;
  AddressDetails? selectedCountry;

  RegisterStep(
      {this.firstName,
      this.secondName,
      this.IdNumber,
      required this.gender,
      this.dob,
      this.email,
      this.phone,
      this.password,
      this.details,
      this.street,
      this.city,
      this.state,
      this.country, this.selectedCountry});

  @override
  String toString() {
    return 'RegisterStep{firstName: $firstName, secondName: $secondName, IdNumber: $IdNumber, dob: $dob, email: $email, phone: $phone, password: $password, details: $details, gender: $gender, street: $street, city: $city, state: $state, country: $country}';
  }
}
