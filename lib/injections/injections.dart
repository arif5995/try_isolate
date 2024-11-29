import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:try_isolate/data/post_datasource.dart';
import 'package:try_isolate/isolate/post_response_dto.dart';
import 'package:try_isolate/repository/post_repository.dart';
import 'package:try_isolate/usecase/get_post_usecase.dart';

final sl = GetIt.instance;

class Injections{
  Future<void> initialize() async {
    sl.registerSingletonAsync<PostResponseDTO>(() => PostResponseDTO.spawn());
    sl.registerLazySingleton<Dio>(() => Dio());
    _registerData();
  }
}

void _registerData(){
  sl.registerLazySingleton<PostDatasource>(() => PostDatasourceImp(dio: sl(), worker: sl()));
  sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(postDatasource: sl()));
  sl.registerLazySingleton<GetPostUsecase>(() => GetPostUsecase(postRepository: sl()));

}