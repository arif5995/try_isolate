import 'package:dartz/dartz.dart';
import 'package:try_isolate/entities/post.dart';
import 'package:try_isolate/repository/post_repository.dart';

class GetPostUsecase{
  final PostRepository postRepository;

  GetPostUsecase({required this.postRepository});

  Future<Either<String, List<Post>>> call(String page)async=>
      await postRepository.getDataPost(page);
}