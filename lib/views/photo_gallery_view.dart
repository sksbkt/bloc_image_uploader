import 'package:bloc_image_uploader/bloc/app_bloc.dart';
import 'package:bloc_image_uploader/bloc/app_event.dart';
import 'package:bloc_image_uploader/bloc/app_state.dart';
import 'package:bloc_image_uploader/views/storage_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

class PhotoGalleryView extends HookWidget {
  const PhotoGalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //? with using memoized we are avoiding creating an object
    //? again but we are calling back same instance of it(as long as key is the same)
    final picker = useMemoized(() => ImagePicker(), [key]);
    final contextRead = context.read<AppBloc>();
    final images = context.watch<AppBloc>().state.images ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Photo gallery',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image == null) {
                return;
              }

              contextRead
                  .add(AppEventUploadImage(filePathToUpload: image.path));
            },
            icon: const Icon(
              Icons.upload,
            ),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(8),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: images
            .map(
              (img) => StorageImageView(image: img),
            )
            .toList(),
      ),
    );
  }
}
