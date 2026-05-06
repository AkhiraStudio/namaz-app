import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/mosque.dart';
import '../models/prayer_time_model.dart';

abstract class PrayerRemoteDataSource {
  Future<PrayerTimeModel> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 12,
  });

  Future<List<Mosque>> getNearbyMosques({
    required double latitude,
    required double longitude,
  });
}

class PrayerRemoteDataSourceImpl implements PrayerRemoteDataSource {
  final Dio _dio;
  final Dio _overpassDio;

  PrayerRemoteDataSourceImpl({required Dio dio})
      : _dio = dio,
        _overpassDio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 35),
        ));

  @override
  Future<PrayerTimeModel> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 12,
  }) async {
    try {
      final response = await _dio.get(
        '/timings/${date.millisecondsSinceEpoch ~/ 1000}',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['code'] != 200) {
        throw ServerException(
          message: 'Aladhan API error: ${data['status']}',
          statusCode: data['code'] as int?,
        );
      }
      final timings =
          data['data']['timings'] as Map<String, dynamic>;
      return PrayerTimeModel.fromAladhan(timings, date);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Erreur réseau',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Mosque>> getNearbyMosques({
    required double latitude,
    required double longitude,
  }) async {
    // Utilise l'API Overpass (OSM) pour les mosquées proches.
    // node + way + relation pour ne pas rater les bâtiments polygonaux.
    // POST est plus fiable que GET pour les longues requêtes Overpass.
    const r = AppConstants.mosqueSearchRadius;
    final query = '[out:json][timeout:30];'
        '('
        'node["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$r,$latitude,$longitude);'
        'way["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$r,$latitude,$longitude);'
        'relation["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$r,$latitude,$longitude);'
        'node["building"="mosque"](around:$r,$latitude,$longitude);'
        'way["building"="mosque"](around:$r,$latitude,$longitude);'
        ');'
        'out center 20;';

    // Liste de serveurs Overpass à essayer dans l'ordre
    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass.openstreetmap.fr/api/interpreter',
    ];

    Object? lastError;

    for (final endpoint in endpoints) {
      try {
        // POST form-urlencoded : Dio encode automatiquement la Map
        final response = await _overpassDio.post(
          endpoint,
          data: {'data': query},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {
              'User-Agent': 'NamazApp/1.0 (Flutter Islamic prayer app)',
            },
          ),
        );
        final elements = (response.data['elements'] as List)
            .cast<Map<String, dynamic>>();
        // Calcul de la distance + tri par proximité
        final mosques = elements.map(Mosque.fromOverpass).map((m) {
          final dist = Geolocator.distanceBetween(
            latitude, longitude, m.latitude, m.longitude,
          );
          return m.copyWith(distanceMeters: dist);
        }).toList()
          ..sort((a, b) =>
              (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
        return mosques;
      } on DioException catch (e) {
        lastError = e;
        continue;
      }
    }

    // Tous les serveurs ont échoué
    final err = lastError;
    if (err is DioException) {
      throw ServerException(
        message: 'Overpass inaccessible : ${err.message}',
        statusCode: err.response?.statusCode,
      );
    }
    throw const ServerException(message: 'Impossible de contacter Overpass');
  }
}
