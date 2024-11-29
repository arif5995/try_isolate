import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:try_isolate/entities/post.dart';
import 'package:try_isolate/usecase/get_post_usecase.dart';
// import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';

part 'post_state.dart';

// const throttleDuration = Duration(milliseconds: 100);
//
// EventTransformer<E> throttleDroppable<E>(Duration duration) {
//   return (events, mapper) {
//     return droppable<E>().call(events.throttle(duration), mapper);
//   };
// }
class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostUsecase getPostUsecase;

  PostBloc({required this.getPostUsecase}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched, transformer: sequential());
  }

  Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) {
        return;
    }else{
      try {
        final posts = await getPostUsecase.call((state.page + 1).toString());
        posts.fold((l) => emit(state.copyWith(status: PostStatus.failure)),
                (data) {
              if (data.isEmpty) {
                return emit(state.copyWith(hasReachedMax: true));
              } else {
                return emit(
                  state.copyWith(
                    status: PostStatus.success,
                    posts: [...state.posts, ...data],
                    page: state.page + 1
                  ),
                );
              }
            });
      } catch (e) {
        emit(state.copyWith(status: PostStatus.failure));
      }
    }

  }
}
