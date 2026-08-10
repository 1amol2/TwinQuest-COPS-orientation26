// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const PairQuestApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TwinQuest',
//       theme: ThemeData(
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const PairQuestApp(),
//     );
//   }
// }
//
// class PairQuestApp extends StatelessWidget {
//   const PairQuestApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'PairQuest',
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFFAF4EC),
//       ),
//       home: const OnboardingScreen(),
//     );
//   }
// }
//
// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});
//
//   // Color constants matching the design palette
//   static const Color backgroundColor = Color(0xFFFAF4EC);
//   static const Color primaryBrown = Color(0xFF4E2B12);
//   static const Color secondaryText = Color(0xFF7D6758);
//   static const Color buttonBorder = Color(0xFFEADBCE);
//   static const Color indicatorInactive = Color(0xFFE2CFC0);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 32),
//
//               // --- App Header ---
//               const Text(
//                 'PairQuest',
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: primaryBrown,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Find your other half',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w400,
//                   color: secondaryText,
//                 ),
//               ),
//
//               const Spacer(),
//
//               // --- Central Illustration Area ---
//               // Replace Image.asset with your actual graphic asset (e.g. 'assets/images/pairquest_illustration.png')
//               Center(
//                 child: Image.network(
//                   'https://via.placeholder.com/320x300.png?text=PairQuest+Illustration',
//                   height: 280,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     height: 260,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF3E7DB),
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.bluetooth, size: 40, color: primaryBrown),
//                         SizedBox(height: 12),
//                         Text(
//                           'Illustration Asset Area\n(Replace with your graphic file)',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: secondaryText,
//                             fontSize: 14,
//                             height: 1.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               const Spacer(),
//
//               // --- Action Buttons ---
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Navigate to Join Event screen
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryBrown,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: const Text(
//                     'Join Event',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 14),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     // Open "How it works" guide
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: primaryBrown,
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     side: const BorderSide(color: buttonBorder, width: 1.5),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: const Text(
//                     'How it works?',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: primaryBrown,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 36),
//
//               // --- Page Indicator ---
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _buildPageDot(isActive: true),
//                   const SizedBox(width: 10),
//                   _buildPageDot(isActive: false),
//                   const SizedBox(width: 10),
//                   _buildPageDot(isActive: false),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Dot indicator widget
//   Widget _buildPageDot({required bool isActive}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       height: 8,
//       width: 8,
//       decoration: BoxDecoration(
//         color: isActive ? primaryBrown : indicatorInactive,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }