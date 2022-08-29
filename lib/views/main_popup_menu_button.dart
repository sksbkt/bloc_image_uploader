import 'package:bloc_image_uploader/bloc/app_bloc.dart';
import 'package:bloc_image_uploader/bloc/app_event.dart';
import 'package:bloc_image_uploader/dialogs/delete_account_dialog.dart';
import 'package:bloc_image_uploader/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MenuAction { logOut, deleteAccount }

class MainPopupMenuButton extends StatelessWidget {
  const MainPopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //* temporary workaround for the issue calling context.read during an async call
    final contextRead = context.read<AppBloc>();
    return PopupMenuButton<MenuAction>(
      onSelected: (value) async {
        switch (value) {
          case MenuAction.logOut:
            final shouldLogOut = await showLogOutDialog(context);
            //* temporary workaround for the issue calling context.read during an async call
            if (shouldLogOut) {
              contextRead.add(
                const AppEventLogOut(),
              );
              // context.read<AppBloc>().add(
              //       const AppEventLogOut(),
              //     );
            }
            break;
          case MenuAction.deleteAccount:
            final showDeleteAccount = await showDeleteAccountDialog(context);
            //* temporary workaround for the issue calling context.read during an async call
            if (showDeleteAccount) {
              contextRead.add(
                const AppEventDeleteAccount(),
              );
              // context.read<AppBloc>().add(
              //       const AppEventLogOut(),
              //     );
            }
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<MenuAction>(
            value: MenuAction.logOut,
            child: Text('log out'),
          ),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.deleteAccount,
            child: Text('Delete account'),
          ),
        ];
      },
    );
  }
}
