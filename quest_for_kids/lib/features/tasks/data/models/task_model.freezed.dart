// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskModel {

 String get id; String get title; String get description; int get points;@JsonKey(name: 'is_recurring') bool get isRecurring; TaskStatus get status;@JsonKey(name: 'assigned_to_id') String get assignedToId;@JsonKey(name: 'start_time') DateTime? get startTime;@JsonKey(name: 'end_time') DateTime? get endTime;
/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskModelCopyWith<TaskModel> get copyWith => _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskModel&&super == other&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,super.hashCode,id,title,description,points,isRecurring,status,assignedToId,startTime,endTime);



}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res>  {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) = _$TaskModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, int points,@JsonKey(name: 'is_recurring') bool isRecurring, TaskStatus status,@JsonKey(name: 'assigned_to_id') String assignedToId,@JsonKey(name: 'start_time') DateTime? startTime,@JsonKey(name: 'end_time') DateTime? endTime
});




}
/// @nodoc
class _$TaskModelCopyWithImpl<$Res>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? points = null,Object? isRecurring = null,Object? status = null,Object? assignedToId = null,Object? startTime = freezed,Object? endTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,assignedToId: null == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int points, @JsonKey(name: 'is_recurring')  bool isRecurring,  TaskStatus status, @JsonKey(name: 'assigned_to_id')  String assignedToId, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.points,_that.isRecurring,_that.status,_that.assignedToId,_that.startTime,_that.endTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int points, @JsonKey(name: 'is_recurring')  bool isRecurring,  TaskStatus status, @JsonKey(name: 'assigned_to_id')  String assignedToId, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime)  $default,) {final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that.id,_that.title,_that.description,_that.points,_that.isRecurring,_that.status,_that.assignedToId,_that.startTime,_that.endTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  int points, @JsonKey(name: 'is_recurring')  bool isRecurring,  TaskStatus status, @JsonKey(name: 'assigned_to_id')  String assignedToId, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime)?  $default,) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.points,_that.isRecurring,_that.status,_that.assignedToId,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskModel extends TaskModel {
  const _TaskModel({required this.id, required this.title, required this.description, required this.points, @JsonKey(name: 'is_recurring') required this.isRecurring, required this.status, @JsonKey(name: 'assigned_to_id') required this.assignedToId, @JsonKey(name: 'start_time') this.startTime, @JsonKey(name: 'end_time') this.endTime}): super._();
  factory _TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  int points;
@override@JsonKey(name: 'is_recurring') final  bool isRecurring;
@override final  TaskStatus status;
@override@JsonKey(name: 'assigned_to_id') final  String assignedToId;
@override@JsonKey(name: 'start_time') final  DateTime? startTime;
@override@JsonKey(name: 'end_time') final  DateTime? endTime;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskModelCopyWith<_TaskModel> get copyWith => __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskModel&&super == other&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,super.hashCode,id,title,description,points,isRecurring,status,assignedToId,startTime,endTime);



}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res> implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(_TaskModel value, $Res Function(_TaskModel) _then) = __$TaskModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, int points,@JsonKey(name: 'is_recurring') bool isRecurring, TaskStatus status,@JsonKey(name: 'assigned_to_id') String assignedToId,@JsonKey(name: 'start_time') DateTime? startTime,@JsonKey(name: 'end_time') DateTime? endTime
});




}
/// @nodoc
class __$TaskModelCopyWithImpl<$Res>
    implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? points = null,Object? isRecurring = null,Object? status = null,Object? assignedToId = null,Object? startTime = freezed,Object? endTime = freezed,}) {
  return _then(_TaskModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,assignedToId: null == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
