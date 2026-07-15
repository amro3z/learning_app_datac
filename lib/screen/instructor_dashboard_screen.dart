import 'package:flutter/material.dart';
import 'package:training/data/models/dashboard_models.dart';
import 'package:training/helper/base.dart';
import 'package:training/widgets/floating_glass_bar.dart';
import 'package:training/widgets/instructor/course_status_card.dart';
import 'package:training/widgets/instructor/dashboard_header.dart';
import 'package:training/widgets/instructor/overview_grid.dart';
import 'package:training/widgets/instructor/quick_summary_list.dart';
import 'package:training/widgets/instructor/section_title.dart';
import 'package:training/widgets/instructor/student_progress_card.dart';

class InstructorHome extends StatefulWidget {
  const InstructorHome({super.key});

  @override
  State<InstructorHome> createState() => _InstructorHomeState();
}

class _InstructorHomeState extends State<InstructorHome> {
  int currentIndex = 0;

  static const overviewItems = [
    OverviewStat(
      value: '24',
      label: 'Total Courses',
      icon: Icons.menu_book_rounded,
    ),
    OverviewStat(
      value: '1,248',
      label: 'Total Students',
      icon: Icons.groups_rounded,
    ),
    OverviewStat(
      value: '156',
      label: 'Total Lessons',
      icon: Icons.play_circle_fill_rounded,
    ),
    OverviewStat(
      value: '4.7',
      label: 'Average Rating',
      icon: Icons.star_rounded,
    ),
  ];

  static const courseStatusItems = [
    CourseStatusItem(label: 'Published Courses', count: 16, percent: 66.7),
    CourseStatusItem(label: 'Draft Courses', count: 5, percent: 20.8),
    CourseStatusItem(label: 'Pending Review', count: 3, percent: 12.5),
  ];

  static const progressItems = [
    ProgressStat(
      value: '156',
      label: 'New Enrollments',
      change: '+12%',
      icon: Icons.person_add_alt_1_rounded,
    ),
    ProgressStat(
      value: '532',
      label: 'Completed Lessons',
      change: '+18%',
      icon: Icons.menu_book_rounded,
    ),
    ProgressStat(
      value: '298',
      label: 'Quiz Attempts',
      change: '+9%',
      icon: Icons.assignment_rounded,
    ),
  ];

  static const summaryItems = [
    SummaryItem(
      tag: 'Top Course',
      title: 'Web Development Bootcamp',
      subtitle: '875 Students • 4.8 ★',
      imageUrl: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6',
      icon: Icons.workspace_premium_rounded,
    ),
    SummaryItem(
      tag: 'Latest Course',
      title: 'UI/UX Design Fundamentals',
      subtitle: '12 Students • Published 2 days ago',
      imageUrl: 'https://images.unsplash.com/photo-1559028012-481c04fa702d',
      icon: Icons.save_outlined,
    ),
    SummaryItem(
      tag: 'Latest Student',
      title: 'Ahmed Mostafa',
      subtitle: 'Joined 1 hour ago',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      icon: Icons.person_outline_rounded,
    ),
    SummaryItem(
      tag: 'Latest Review',
      title: 'Web Development Bootcamp',
      subtitle: '★★★★★ 5.0 • Great course!',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      icon: Icons.comment_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _InstructorDashboardPage(),
      const _PlaceholderPage(title: 'My Courses'),
      const _PlaceholderPage(title: 'Create Course'),
      const _PlaceholderPage(title: 'Manage Courses'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: pages[currentIndex]),
          FloatingGlassBar(
            currentIndex: currentIndex,
            onItemSelected: (index) {
              if (currentIndex == index) return;

              setState(() {
                currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _InstructorDashboardPage extends StatelessWidget {
  const _InstructorDashboardPage();

  @override
  Widget build(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.03,
          screenHeight * 0.018,
          screenWidth * 0.03,
          screenHeight * 0.13,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(
              instructorName: 'Instructor',
              avatarUrl:
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
            ),

            SizedBox(height: screenHeight * 0.018),

            const SectionTitle(title: 'Overview'),

            const OverviewGrid(items: _InstructorHomeState.overviewItems),

            SizedBox(height: screenHeight * 0.012),

            const SectionTitle(title: 'Course Status'),

            const CourseStatusCard(
              items: _InstructorHomeState.courseStatusItems,
              total: 24,
            ),

            SizedBox(height: screenHeight * 0.012),

            const SectionTitle(title: 'Student Progress'),

            const StudentProgressCard(
              items: _InstructorHomeState.progressItems,
            ),

            SizedBox(height: screenHeight * 0.008),

            const SectionTitle(title: 'Quick Summary'),

            const QuickSummaryList(items: _InstructorHomeState.summaryItems),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: getScreenHeight(context) * 0.10),
        child: Center(
          child: defaultText(
            context: context,
            text: title,
            size: responsiveWidth(context, 0.052, min: 18, max: 24),
            bold: true,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
