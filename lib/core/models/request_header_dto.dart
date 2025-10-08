import 'package:json_annotation/json_annotation.dart';
part 'request_header_dto.g.dart';
@JsonSerializable()
class RequestHeaderDto {
  @JsonKey(name: 'Source')
  String source;
  @JsonKey(name: 'Device')
  String Device;
  @JsonKey(name: 'Version')
  String Version;

  RequestHeaderDto(this.source, this.Device, this.Version);

  factory RequestHeaderDto.fromJson(Map<String, dynamic> json) => _$RequestHeaderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RequestHeaderDtoToJson(this);


}