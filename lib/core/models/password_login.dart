class PasswordDto {
  String Password;
  String DateTime;

  PasswordDto(this.Password, this.DateTime);

  factory PasswordDto.fromJson(Map<String, dynamic> json) =>
      PasswordDto(json['Password'] ?? '', json['DateTime'] ?? '');

  Map<String, dynamic> toJson() => <String, dynamic>{
        'Password': Password,
        'DateTime': DateTime,
      };
}
