import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

String generateToken() {
  String appAccessKey = "654688e0ca5848f0e3d471c0";
  String appSecret = "GZzkUzQxb44L6zmoxQnLc06dJKBMDtxqwm_XHj30-nVejehzvfpIIT6ZpK-gCiBjTgISWnf2LnEh25MKuPiAXJmDiqdZLiTVxpKBWR1TVIR3ejmeXbNVvxuZhAReme1On2-pU55MZJ_TMlCnvvLOouL_4-N6NpFfs9QlNFUBOKs=";

  var issuedAt = DateTime.now();
  var expire = issuedAt.add(const Duration(hours: 24));

  final jwt = JWT(
      {
        'access_key': appAccessKey,
        'type': 'management',
        'version': 2,
        'jti': const Uuid().v4(),
        'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
        'nbf': issuedAt.millisecondsSinceEpoch ~/ 1000,
        'exp': expire.millisecondsSinceEpoch ~/ 1000,
      }
  );

  final token = jwt.sign(SecretKey(appSecret), expiresIn: const Duration(hours: 24), algorithm: JWTAlgorithm.HS256);

  return token;
}