// import 'dart:convert';
// /// name : {"common":"South Georgia","official":"South Georgia and the South Sandwich Islands","nativeName":{"eng":{"official":"South Georgia and the South Sandwich Islands","common":"South Georgia"}}}

// GetAllCountryModel getAllCountryModelFromJson(String str) => GetAllCountryModel.fromJson(json.decode(str));
// String getAllCountryModelToJson(GetAllCountryModel data) => json.encode(data.toJson());
// class GetAllCountryModel {
//   GetAllCountryModel({
//       Name? name,}){
//     _name = name;
// }

//   GetAllCountryModel.fromJson(dynamic json) {
//     _name = json['name'] != null ? Name.fromJson(json['name']) : null;
//   }
//   Name? _name;
// GetAllCountryModel copyWith({  Name? name,
// }) => GetAllCountryModel(  name: name ?? _name,
// );
//   Name? get name => _name;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_name != null) {
//       map['name'] = _name?.toJson();
//     }
//     return map;
//   }

// }

// /// common : "South Georgia"
// /// official : "South Georgia and the South Sandwich Islands"
// /// nativeName : {"eng":{"official":"South Georgia and the South Sandwich Islands","common":"South Georgia"}}

// Name nameFromJson(String str) => Name.fromJson(json.decode(str));
// String nameToJson(Name data) => json.encode(data.toJson());
// class Name {
//   Name({
//       String? common, 
//       String? official, 
//       NativeName? nativeName,}){
//     _common = common;
//     _official = official;
//     _nativeName = nativeName;
// }

//   Name.fromJson(dynamic json) {
//     _common = json['common'];
//     _official = json['official'];
//     _nativeName = json['nativeName'] != null ? NativeName.fromJson(json['nativeName']) : null;
//   }
//   String? _common;
//   String? _official;
//   NativeName? _nativeName;
// Name copyWith({  String? common,
//   String? official,
//   NativeName? nativeName,
// }) => Name(  common: common ?? _common,
//   official: official ?? _official,
//   nativeName: nativeName ?? _nativeName,
// );
//   String? get common => _common;
//   String? get official => _official;
//   NativeName? get nativeName => _nativeName;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['common'] = _common;
//     map['official'] = _official;
//     if (_nativeName != null) {
//       map['nativeName'] = _nativeName?.toJson();
//     }
//     return map;
//   }

// }

// /// eng : {"official":"South Georgia and the South Sandwich Islands","common":"South Georgia"}

// NativeName nativeNameFromJson(String str) => NativeName.fromJson(json.decode(str));
// String nativeNameToJson(NativeName data) => json.encode(data.toJson());
// class NativeName {
//   NativeName({
//       Eng? eng,}){
//     _eng = eng;
// }

//   NativeName.fromJson(dynamic json) {
//     _eng = json['eng'] != null ? Eng.fromJson(json['eng']) : null;
//   }
//   Eng? _eng;
// NativeName copyWith({  Eng? eng,
// }) => NativeName(  eng: eng ?? _eng,
// );
//   Eng? get eng => _eng;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_eng != null) {
//       map['eng'] = _eng?.toJson();
//     }
//     return map;
//   }

// }

// /// official : "South Georgia and the South Sandwich Islands"
// /// common : "South Georgia"

// Eng engFromJson(String str) => Eng.fromJson(json.decode(str));
// String engToJson(Eng data) => json.encode(data.toJson());
// class Eng {
//   Eng({
//       String? official, 
//       String? common,}){
//     _official = official;
//     _common = common;
// }

//   Eng.fromJson(dynamic json) {
//     _official = json['official'];
//     _common = json['common'];
//   }
//   String? _official;
//   String? _common;
// Eng copyWith({  String? official,
//   String? common,
// }) => Eng(  official: official ?? _official,
//   common: common ?? _common,
// );
//   String? get official => _official;
//   String? get common => _common;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['official'] = _official;
//     map['common'] = _common;
//     return map;
//   }

// }