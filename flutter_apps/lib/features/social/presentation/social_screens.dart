import 'package:flutter/widgets.dart';

import '../../home/presentation/home_screens.dart';
import 'social_tab.dart';

class CrewScreen extends StatelessWidget {
  const CrewScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell(initialIndex: 2);
}

class PostUploadScreen extends StatelessWidget {
  const PostUploadScreen({super.key});
  @override
  Widget build(BuildContext context) => const SocialComposeScreen();
}

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const MainShell(initialIndex: 2, initialSocialView: SocialView.feed);
}

class CrewExploreScreen extends StatelessWidget {
  const CrewExploreScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const MainShell(initialIndex: 2, initialSocialView: SocialView.explore);
}
