import 'package:bloc_image_uploader/bloc/app_bloc.dart';
import 'package:bloc_image_uploader/bloc/app_event.dart';
import 'package:bloc_image_uploader/bloc/app_state.dart';
import 'package:bloc_image_uploader/dialogs/show_auth_error.dart';
import 'package:bloc_image_uploader/loading/loading_screen.dart';
import 'package:bloc_image_uploader/views/login_view.dart';
import 'package:bloc_image_uploader/views/photo_gallery_view.dart';
import 'package:bloc_image_uploader/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      //? .. after creating the AppBloc we are adding the event here
      create: (_) => AppBloc()
        ..add(
          const AppEventInitialize(),
        ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Photo library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            if (appState.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: 'loading...',
              );
            } else {
              LoadingScreen.instance().hide();
            }
            final authError = appState.authError;
            if (authError != null) {
              showAuthErrorDialog(
                authError: authError,
                context: context,
              );
            }
          },
          builder: (context, appState) {
            if (appState is AppStateLoggedOut) {
              return const LoginView();
            } else if (appState is AppStateLoggedIn) {
              return const PhotoGalleryView();
            } else if (appState is AppStateIsInRegistrationView) {
              return const RegisterView();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
