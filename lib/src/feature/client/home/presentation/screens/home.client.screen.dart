import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_banner.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_tile.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/core/seeder/requested_packages.seeder.dart';
import 'package:smart_reload_system/src/feature/client/chat/presentation/screens/widgets/assistant_entry.widget.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.state.dart';
import 'package:smart_reload_system/src/core/features/notification/presentation/screens/widget/notification_bell.widget.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  @override
  void initState() {
    super.initState();
    // Reset stale state on entry since HomeBloc is app-level and persists
    context.read<HomeBloc>().add(const HomeDataReset());
    // Fetch fresh data
    context.read<HomeBloc>().add(const HomeDataRequested());
  }

  bool seeding = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        String userName = "USER";

        if (sessionState is SessionAuthenticated) {
          userName = sessionState.user.fullName;
        }

        return Scaffold(
          appBar: customAppBar(
            title: userName,
            action: [NotificationBell()],
          ),
          body: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeFailure) {
                AppSnackbar.showError(context, state.message);
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeDataRequested());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  // Show shimmer loading
                  if (state is HomeLoading) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.ssm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBannerCard(),
                            const SizedBox(height: 16),
                            ShimmerLoading(
                              height: 18,
                              width: 120,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 12),
                            ShimmerVendorCard(),
                            ShimmerVendorCard(),
                            ShimmerVendorCard(),
                          ],
                        ),
                      ),
                    );
                  }

                  // Show actual content when success
                  if (state is HomeSuccess) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.ssm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10.0,
                          children: [
                            // Display banner news
                            if (state.bannerNews.isNotEmpty)...{
                              CustomBanner(
                                isNew: state.bannerNews.first.isNew,
                                title: state.bannerNews.first.title,
                                body: state.bannerNews.first.body,
                              ),
                              const SizedBox(height: 12),
                            },
                            if (kDebugMode && false)...{
                              Wrap(
                                spacing: 8,
                                children: [
                                  FilledButton(
                                    onPressed: seeding ? null : () async {
                                      setState(() => seeding = true);
                                      final n = await RequestedPackagesSeeder().seed();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text('Inserted $n docs')));
                                      }
                                      setState(() => seeding = false);
                                    },
                                    child: seeding ? CircularProgressIndicator(): const Text('Seed dummy data'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      final n = await RequestedPackagesSeeder().deleteSeeded();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text('Deleted $n docs')));
                                      }
                                    },
                                    child: const Text('Delete dummy data'),
                                  ),
                                ],
                              ),
                            },

                            const AssistantEntry(),
                            const SizedBox(height: 12),
                            // Display vendors
                            SubHeadlineText(text: "My Vendors"),

                            if (state.vendors.isNotEmpty) ...{
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10.0,
                                children: state.vendors.map((vendor) {
                                  return CustomTile(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteConstants.connectionClientScreen,
                                        arguments: vendor,
                                      );
                                    },
                                    title: vendor.vendorName,
                                    ref: vendor.vendorId,
                                    count: vendor.connectionCount,
                                  );
                                }).toList(),
                              ),
                            } else ...{
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: TitleText(
                                  text: 'No vendors available',
                                  isBold: false,
                                ),
                              ),
                            },
                          ],
                        ),
                      ),
                    );
                  }

                  // Fallback state
                  return FallbackWidget(
                      onPressed: () {
                        context.read<HomeBloc>().add(const HomeDataRequested());
                      }
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
