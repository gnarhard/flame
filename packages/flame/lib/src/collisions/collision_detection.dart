import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/src/geometry/ray2.dart';

/// [CollisionDetection] is the foundation of the collision detection system in
/// Flame.
///
/// If the [HasCollisionDetection] mixin is added to the game, [run] is
/// called every tick to check for collisions
abstract class CollisionDetection<T extends Hitbox<T>> {
  final Broadphase<T> broadphase;
  List<T> get items => broadphase.items;
  final Set<CollisionProspect<T>> _lastPotentials = {};

  CollisionDetection({required this.broadphase});

  void add(T item) => items.add(item);
  void addAll(Iterable<T> items) => items.forEach(add);

  /// Removes the [item] from the collision detection, if you just want
  /// to temporarily inactivate it you can set
  /// `collisionType = CollisionType.inactive;` instead.
  void remove(T item) => items.remove(item);

  /// Removes all [items] from the collision detection, see [remove].
  void removeAll(Iterable<T> items) => items.forEach(remove);

  /// Run collision detection for the current state of [items].
  void run() {
    final potentials = broadphase.query();
    potentials.forEach((tuple) {
      final itemA = tuple.a;
      final itemB = tuple.b;

      if (itemA.possiblyIntersects(itemB)) {
        final intersectionPoints = intersections(itemA, itemB);
        if (intersectionPoints.isNotEmpty) {
          if (!itemA.collidingWith(itemB)) {
            handleCollisionStart(intersectionPoints, itemA, itemB);
          }
          handleCollision(intersectionPoints, itemA, itemB);
        } else if (itemA.collidingWith(itemB)) {
          handleCollisionEnd(itemA, itemB);
        }
      } else if (itemA.collidingWith(itemB)) {
        handleCollisionEnd(itemA, itemB);
      }
    });

    // Handles callbacks for an ended collision that the broadphase didn't
    // reports as a potential collision anymore.
    _lastPotentials.difference(potentials).forEach((tuple) {
      if (tuple.a.collidingWith(tuple.b)) {
        handleCollisionEnd(tuple.a, tuple.b);
      }
    });
    _lastPotentials
      ..clear()
      ..addAll(potentials);
  }

  /// Check what the intersection points of two items are,
  /// returns an empty list if there are no intersections.
  Set<Vector2> intersections(T itemA, T itemB);
  void handleCollisionStart(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollision(Set<Vector2> intersectionPoints, T itemA, T itemB);
  void handleCollisionEnd(T itemA, T itemB);

  /// [raycast] gives back the first hitbox and intersection point which the
  /// ray hits. If there is no intersection null is returned.
  ///
  /// If [out] is provided that object will be modified and returned with the
  /// result.
  RaycastResult<T>? raycast(Ray2 ray, {RaycastResult<T>? out});

  /// [raycastAll] gives back the all hitboxes and the intersection points which
  /// the ray hits.
  ///
  /// If [out] is provided the [RaycastResult]s in that list be modified and
  /// returned with the result. If there are less objects in [out] than the
  /// result requires, the missing [RaycastResult] objects will be created.
  Set<RaycastResult<T>> raycastAll(Ray2 ray, {Iterable<RaycastResult<T>>? out});
}

class RaycastResult<T extends Hitbox<T>> {
  RaycastResult({required this.hitbox, this.point});

  Vector2? point;
  T hitbox;
}

/// The default implementation of [CollisionDetection].
/// Checks whether any [ShapeHitbox]s in [items] collide with each other and
/// calls their callback methods accordingly.
///
/// By default the [Sweep] broadphase is used, this can be configured by
/// passing in another [Broadphase] to the constructor.
class StandardCollisionDetection extends CollisionDetection<ShapeHitbox> {
  StandardCollisionDetection({Broadphase<ShapeHitbox>? broadphase})
      : super(broadphase: broadphase ?? Sweep<ShapeHitbox>());

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  Set<Vector2> intersections(
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    return hitboxA.intersections(hitboxB);
  }

  /// Calls the two colliding hitboxes when they first starts to collide.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [ShapeHitbox.hitboxParent] that they have collided with.
  @override
  void handleCollisionStart(
    Set<Vector2> intersectionPoints,
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    hitboxA.onCollisionStart(intersectionPoints, hitboxB);
    hitboxB.onCollisionStart(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes every tick when they are colliding.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [ShapeHitbox.hitboxParent] that they have collided with.
  @override
  void handleCollision(
    Set<Vector2> intersectionPoints,
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    hitboxA.onCollision(intersectionPoints, hitboxB);
    hitboxB.onCollision(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes once when two hitboxes have stopped
  /// colliding.
  /// They are called with instances of each other, so that they can determine
  /// what hitbox (and what [ShapeHitbox.hitboxParent] that they have stopped
  /// colliding with.
  @override
  void handleCollisionEnd(ShapeHitbox hitboxA, ShapeHitbox hitboxB) {
    hitboxA.onCollisionEnd(hitboxB);
    hitboxB.onCollisionEnd(hitboxA);
  }

  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    RaycastResult<Hitbox<ShapeHitbox>>? out,
  }) {
    // TODO: implement raycast
    throw UnimplementedError();
  }

  @override
  Set<RaycastResult<ShapeHitbox>> raycastAll(
    Ray2 ray, {
    Iterable<RaycastResult<Hitbox<ShapeHitbox>>>? out,
  }) {
    // TODO: implement raycastAll
    throw UnimplementedError();
  }
}
