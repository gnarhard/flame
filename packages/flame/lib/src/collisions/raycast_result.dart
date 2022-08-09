import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/ray2.dart';

/// The result of a raycasting operation.
///
/// Note that the members of this class is heavily re-used. If you want to
/// keep the result in an object, clone the parts you want, or the whole
/// [RaycastResult] with [clone].
class RaycastResult<T extends Hitbox<T>> {
  RaycastResult({
    T? hitbox,
    Ray2? reflectionRay,
    Vector2? normal,
    double? distance,
    bool isInsideHitbox = false,
    bool isActive = true,
  })  : _isInsideHitbox = isInsideHitbox,
        _isActive = isActive,
        _hitbox = hitbox,
        _reflectionRay = reflectionRay ?? Ray2.zero(),
        _normal = normal ?? Vector2.zero(),
        _distance = distance ?? double.maxFinite;

  /// Whether this result has active results in it.
  ///
  /// This is used so that the objects in there can continue to live even when
  /// there is no result from a ray cast.
  bool get isActive => _isActive;
  bool _isActive;

  /// Whether the origin of the ray was inside the hitbox.
  bool get isInsideHitbox => _isInsideHitbox;
  bool _isInsideHitbox;

  T? _hitbox;
  T? get hitbox => isActive ? _hitbox : null;

  final Ray2 _reflectionRay;
  Ray2? get reflectionRay => isActive ? _reflectionRay : null;

  Vector2? get intersectionPoint => reflectionRay?.origin;

  double _distance;
  double? get distance => isActive ? _distance : null;

  final Vector2 _normal;
  Vector2? get normal => isActive ? _normal : null;

  void reset() => _isActive = false;

  /// Sets this [RaycastResult]'s objects to the values stored in [other].
  ///
  /// Always sets [isActive] to true, unless explicitly passed false.
  void setFrom(RaycastResult<T> other, {bool isActive = true}) {
    setWith(
      hitbox: other.hitbox,
      reflectionRay: other.reflectionRay,
      normal: other.normal,
      distance: other.distance,
      isActive: isActive,
      isInsideHitbox: other.isInsideHitbox,
    );
  }

  void setWith({
    T? hitbox,
    Ray2? reflectionRay,
    Vector2? normal,
    double? distance,
    bool isActive = true,
    bool isInsideHitbox = false,
  }) {
    _hitbox = hitbox;
    if (reflectionRay != null) {
      _reflectionRay.setFrom(reflectionRay);
    }
    if (normal != null) {
      _normal.setFrom(normal);
    }
    _distance = distance ?? double.maxFinite;
    _isActive = isActive;
    _isInsideHitbox = isInsideHitbox;
  }

  RaycastResult<T> clone() {
    return RaycastResult(
      hitbox: hitbox,
      reflectionRay: _reflectionRay.clone(),
      normal: _normal.clone(),
      distance: distance,
      isActive: isActive,
      isInsideHitbox: isInsideHitbox,
    );
  }
}