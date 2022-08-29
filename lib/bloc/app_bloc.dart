import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_image_uploader/auth/auth_error.dart';
import 'package:bloc_image_uploader/bloc/app_event.dart';
import 'package:bloc_image_uploader/bloc/app_state.dart';
import 'package:bloc_image_uploader/utils/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppStateLoggedOut(isLoading: false)) {
    on<AppEventGoToRegistration>(
      (event, emit) {
        emit(
          const AppStateIsInRegistrationView(
            isLoading: false,
          ),
        );
      },
    );
    on<AppEventLogin>(
      (event, emit) async {
        emit(
          const AppStateLoggedOut(
            isLoading: true,
          ),
        );
        try {
          final email = event.email;
          final password = event.password;
          final userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          final user = userCredential.user!;
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: images,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedOut(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );
    on<AppEventGoToLogin>(
      (event, emit) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      },
    );
    on<AppEventRegister>(
      ((event, emit) async {
        emit(
          const AppStateIsInRegistrationView(
            isLoading: true,
          ),
        );
        final email = event.email;
        final password = event.password;
        try {
          //? register user
          final credentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // final userId = credentials.user!.uid;
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: credentials.user!,
              images: const [],
            ),
          );
        } on FirebaseAuthException catch (e) {
          print('ERROR ' + e.message.toString());
          emit(
            AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      }),
    );
    on<AppEventInitialize>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
        } else {
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: images,
            ),
          );
        }
      },
    );
    //? when user delete its account
    //* there is another method of doing it and its via "firebase metadata" please look it up
    on<AppEventLogOut>((event, emit) async {
      emit(
        const AppStateLoggedOut(
          isLoading: true,
        ),
      );
      //? log the user out in FirebaseAuth
      await FirebaseAuth.instance.signOut();

      //? log out (AppStateLoggedOut)
      emit(
        const AppStateLoggedOut(
          isLoading: false,
        ),
      );
    });

    on<AppEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        //? toggle logged out state if there is no current user logged in
        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
          return;
        }
        //? start loading
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        //? delete the user folder ("reference" in firebase terms)
        try {
          final folderContents =
              await FirebaseStorage.instance.ref(user.uid).listAll();
          for (final item in folderContents.items) {
            await item.delete().catchError(
                  (_) {},
                );
            //! in a real world scenario we want to handle the errors
            //! or else we will have dormant files
            //! remaining after the deletion of user

            await FirebaseStorage.instance
                .ref(user.uid)
                .delete()
                .catchError((_) {});
            //? delete the user it self
            await user.delete().onError((error, stackTrace) {});

            //? log the user out in FirebaseAuth
            await FirebaseAuth.instance.signOut();

            //? log out (AppStateLoggedOut)
            emit(
              const AppStateLoggedOut(
                isLoading: false,
              ),
            );
          }
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          //? we might not be able to delete the folder
          //? log the user out
          //* we could try to toggle AppStateLoggedIn with an auth error
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
        }
      },
    );

    //? handle uploading images
    on<AppEventUploadImage>(
      ((event, emit) async {
        final user = state.user;
        //? it will log the user out if you don't have an actual user logged in
        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
          return;
        }
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        //? upload a file
        final file = File(event.filePathToUpload);
        await uploadImage(file: file, userId: user.uid);

        //? after file uploaded get the latest references
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images,
          ),
        );
      }),
    );
  }

  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
          .ref(userId)
          .list()
          .then((listResult) => listResult.items);
}
