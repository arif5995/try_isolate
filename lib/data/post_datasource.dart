import 'package:dio/dio.dart';
import 'package:try_isolate/isolate/post_response_dto.dart';

abstract class PostDatasource{
  Future<List<dynamic>> responsePost(String page);
}

class PostDatasourceImp implements PostDatasource{
  final Dio dio;
  final PostResponseDTO worker;

  PostDatasourceImp({
    required this.dio,
    required this.worker,
  });

  @override
  Future<List<dynamic>> responsePost(String page) async{
    final dio = Dio();
    try {
      Response response = await dio.get("https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=10");
      print(response.data.toString());
      return response.data;
    } catch (e) {
      print('Error parsing JSON: $e');
      rethrow;
    }
  }

}