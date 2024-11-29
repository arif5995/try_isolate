import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:try_isolate/bloc/post_bloc.dart';
import 'package:try_isolate/entities/post.dart';
import 'package:try_isolate/injections/injections.dart';
import 'package:try_isolate/isolate/post_response_dto.dart';
import 'package:try_isolate/ui/post_list_item.dart';

class ScreenOne extends StatefulWidget {
  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom)
      context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    return Scaffold(
      appBar: AppBar(title: Text("TRY ISOLATE"),),
      body: FutureBuilder(
          future: getIt.allReady(),
          builder: (BuildContext ctx, AsyncSnapshot snapshot){
            if (snapshot.hasData){
              return BlocBuilder<PostBloc, PostState>(
                  builder: (context, state){
                    switch(state.status){
                      case PostStatus.failure:
                        return const Center(child: Text('failed to fetch posts'));
                      case PostStatus.success:
                        if (state.posts.isEmpty) {
                          return const Center(child: Text('no posts'));
                        }
                        return ListView.builder(
                            itemBuilder: (BuildContext buildContext, int index){
                            return index >= state.posts.length
                                ? BottomLoader()
                                :PostListItem(post: state.posts[index]);
                        },
                          itemCount: state.hasReachedMax
                              ? state.posts.length
                              : state.posts.length + 1,
                          controller: _scrollController,
                        );
                      case PostStatus.initial:
                        return const Center(child: CircularProgressIndicator());
                    }

              });
            }else{
              return Center(child: CircularProgressIndicator(),);
            }
          }),
    );
  }
}

Widget BottomLoader(){
  return const Center(
    child: SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(strokeWidth: 1.5),
    ),
  );
}


