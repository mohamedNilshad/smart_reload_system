import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_banner.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_tile.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home.state.dart';

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
            action: [
              IconButton(
                onPressed: () {},
                color: AppColors.darkGrey,
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 30),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                            if (state.bannerNews.isNotEmpty)
                              ...state.bannerNews.map((news) {
                                return CustomBanner(
                                  isNew: news.isNew,
                                  title: news.title,
                                  body: news.body,
                                );
                              }).toList(),
                            const SizedBox(height: 12),
                            // Display vendors
                            SubHeadlineText(text: "My Vendors"),
                            if (state.vendors.isNotEmpty) ...{
                              ...state.vendors.map((vendor) {
                                return CustomTile(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteConstants.connectionClientScreen,
                                      arguments: (name: vendor.vendorName, clientVendorId: vendor.clientVendorId),
                                    );
                                  },
                                  title: vendor.vendorName,
                                  ref: vendor.vendorId,
                                  count: vendor.connectionCount,
                                );
                              }).toList(),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TitleText(
                          text: 'Unable to load data',
                          isBold: false,
                        ),
                        const SizedBox(height: 16),
                        CircleAvatar(
                          backgroundColor: AppColors.secondary.withValues(
                            alpha: 0.2,
                          ),
                          radius: 30,
                          child: IconButton(
                            onPressed: () {
                              context.read<HomeBloc>().add(
                                const HomeDataRequested(),
                              );
                            },
                            icon: const Icon(Icons.refresh, size: 30),
                          ),
                        ),
                      ],
                    ),
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
