class Vector3D {
  final double x;
  final double y;
  final double z;

  const Vector3D(this.x, this.y, this.z);

  factory Vector3D.fromJson(List<dynamic> json) {
    return Vector3D(
      (json[0] as num).toDouble(),
      (json[1] as num).toDouble(),
      (json[2] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};
}

class MotionFrame {
  final List<Vector3D>? leftHand;
  final List<Vector3D>? rightHand;
  final List<Vector3D>? pose;

  const MotionFrame({
    this.leftHand,
    this.rightHand,
    this.pose,
  });

  factory MotionFrame.fromJson(Map<String, dynamic> json) {
    List<Vector3D>? parsePoints(dynamic raw) {
      if (raw == null || raw is! List) return null;
      return raw.map((pt) => Vector3D.fromJson(pt as List<dynamic>)).toList();
    }

    return MotionFrame(
      leftHand: parsePoints(json['left_hand']),
      rightHand: parsePoints(json['right_hand']),
      pose: parsePoints(json['pose']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left_hand': leftHand?.map((v) => [v.x, v.y, v.z]).toList(),
      'right_hand': rightHand?.map((v) => [v.x, v.y, v.z]).toList(),
      'pose': pose?.map((v) => [v.x, v.y, v.z]).toList(),
    };
  }
}
