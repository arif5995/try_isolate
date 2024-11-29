import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:try_isolate/data/post_datasource.dart';
import 'package:try_isolate/entities/post.dart';
import 'package:try_isolate/injections/injections.dart';
import 'package:try_isolate/isolate/post_response_dto.dart';

abstract class PostRepository{
  Future<Either<String, List<Post>>> getDataPost(String page);
}

class PostRepositoryImpl implements PostRepository{
  final PostDatasource postDatasource;
  final PostResponseDTO postResponseDTO = sl();

  PostRepositoryImpl({required this.postDatasource});

  @override
  Future<Either<String, List<Post>>> getDataPost(String page) async {
    try{
      var response = await postDatasource.responsePost(page);
      var data = await postResponseDTO.toListPost(response);
      // postResponseDTO.close();
      return Right(data);

    } on DioException catch (error){
      return Left(error.response.toString());
    }
  }

}