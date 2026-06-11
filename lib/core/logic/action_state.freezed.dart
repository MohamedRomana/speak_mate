// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActionState()';
}


}

/// @nodoc
class $ActionStateCopyWith<$Res>  {
$ActionStateCopyWith(ActionState _, $Res Function(ActionState) __);
}


/// Adds pattern-matching-related methods to [ActionState].
extension ActionStatePatterns on ActionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ActionIdle value)?  idle,TResult Function( ActionLoading value)?  loading,TResult Function( ActionSuccess value)?  success,TResult Function( ActionError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ActionIdle() when idle != null:
return idle(_that);case ActionLoading() when loading != null:
return loading(_that);case ActionSuccess() when success != null:
return success(_that);case ActionError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ActionIdle value)  idle,required TResult Function( ActionLoading value)  loading,required TResult Function( ActionSuccess value)  success,required TResult Function( ActionError value)  error,}){
final _that = this;
switch (_that) {
case ActionIdle():
return idle(_that);case ActionLoading():
return loading(_that);case ActionSuccess():
return success(_that);case ActionError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ActionIdle value)?  idle,TResult? Function( ActionLoading value)?  loading,TResult? Function( ActionSuccess value)?  success,TResult? Function( ActionError value)?  error,}){
final _that = this;
switch (_that) {
case ActionIdle() when idle != null:
return idle(_that);case ActionLoading() when loading != null:
return loading(_that);case ActionSuccess() when success != null:
return success(_that);case ActionError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( String? message)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ActionIdle() when idle != null:
return idle();case ActionLoading() when loading != null:
return loading();case ActionSuccess() when success != null:
return success(_that.message);case ActionError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( String? message)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ActionIdle():
return idle();case ActionLoading():
return loading();case ActionSuccess():
return success(_that.message);case ActionError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( String? message)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ActionIdle() when idle != null:
return idle();case ActionLoading() when loading != null:
return loading();case ActionSuccess() when success != null:
return success(_that.message);case ActionError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ActionIdle implements ActionState {
  const ActionIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActionState.idle()';
}


}




/// @nodoc


class ActionLoading implements ActionState {
  const ActionLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActionState.loading()';
}


}




/// @nodoc


class ActionSuccess implements ActionState {
  const ActionSuccess([this.message]);
  

 final  String? message;

/// Create a copy of ActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionSuccessCopyWith<ActionSuccess> get copyWith => _$ActionSuccessCopyWithImpl<ActionSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionSuccess&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ActionState.success(message: $message)';
}


}

/// @nodoc
abstract mixin class $ActionSuccessCopyWith<$Res> implements $ActionStateCopyWith<$Res> {
  factory $ActionSuccessCopyWith(ActionSuccess value, $Res Function(ActionSuccess) _then) = _$ActionSuccessCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$ActionSuccessCopyWithImpl<$Res>
    implements $ActionSuccessCopyWith<$Res> {
  _$ActionSuccessCopyWithImpl(this._self, this._then);

  final ActionSuccess _self;
  final $Res Function(ActionSuccess) _then;

/// Create a copy of ActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(ActionSuccess(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ActionError implements ActionState {
  const ActionError(this.message);
  

 final  String message;

/// Create a copy of ActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionErrorCopyWith<ActionError> get copyWith => _$ActionErrorCopyWithImpl<ActionError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ActionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ActionErrorCopyWith<$Res> implements $ActionStateCopyWith<$Res> {
  factory $ActionErrorCopyWith(ActionError value, $Res Function(ActionError) _then) = _$ActionErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ActionErrorCopyWithImpl<$Res>
    implements $ActionErrorCopyWith<$Res> {
  _$ActionErrorCopyWithImpl(this._self, this._then);

  final ActionError _self;
  final $Res Function(ActionError) _then;

/// Create a copy of ActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ActionError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
