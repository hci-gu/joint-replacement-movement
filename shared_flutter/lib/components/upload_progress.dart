import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class UploadProgress extends HookConsumerWidget {
  const UploadProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<double> height = useState(32);
    Future? upload = ref.watch(dataUploadProvider);

    useEffect(() {
      if (upload != null) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          height.value = 32;
        });
        upload.then((value) {
          Future.delayed(const Duration(milliseconds: 500)).then((_) {
            height.value = 0;
          });
        });
      } else {
        height.value = 0;
      }
      return () {};
    }, [upload]);

    if (upload == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: upload,
      builder: (context, snapshot) {
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        return SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 0,
          child: OverflowBox(
            maxHeight: 32,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.bounceOut,
              width: double.infinity,
              height: height.value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: CupertinoColors.activeGreen.withOpacity(0.6),
              ),
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: isLoading
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  Text(
                    isLoading ? 'Uppladdning pågår...' : 'Uppladdning klar!',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLoading)
                    const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
