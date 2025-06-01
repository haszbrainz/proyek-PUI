// import 'package:flutter/material.dart';
// import 'item.dart';
// import 'type.dart';

// class RecommendationGrid extends StatefulWidget {
//   const RecommendationGrid({super.key});

//   @override
//   State<RecommendationGrid> createState() => _RecommendationGridState();
// }

// class _RecommendationGridState extends State<RecommendationGrid> {
//   final List<RecommendationCard> recommendations = [
//     RecommendationCard(
//       title: 'Retro vibes and cool m...',
//       imageUrl: 'assets/images/apparel-1.png',
//       isRecommended: true,
//       aspectRatio: 4/5,
//     ),
//     RecommendationCard(
//       title: 'Casual trendy wear an...',
//       imageUrl: 'assets/images/apparel-2.png',
//       isRecommended: false,
//       aspectRatio: 1.0,
//     ),
//     RecommendationCard(
//       title: 'Classic style shirt',
//       imageUrl: 'assets/images/apparel-3.png',
//       isRecommended: false,
//       aspectRatio: 1.0,
//     ),
//     RecommendationCard(
//       title: 'Modern fit outfit',
//       imageUrl: 'assets/images/apparel-4.png',
//       isRecommended: true,
//       aspectRatio: 4/5,
//     ),
//     RecommendationCard(
//       title: 'Summer collection',
//       imageUrl: 'assets/images/apparel-1.png',
//       isRecommended: true,
//       aspectRatio: 4/5,
//     ),
//     RecommendationCard(
//       title: 'Winter essentials',
//       imageUrl: 'assets/images/apparel-2.png',
//       isRecommended: false,
//       aspectRatio: 1.0,
//     ),
//   ];

//   // Define consistent spacing constants
//   final double horizontalGap = 12.0;
//   final double verticalGap = 16.0;

//   @override
//   Widget build(BuildContext context) {
//     // Separate items into left and right columns
//     final leftColumnItems = <RecommendationCard>[];
//     final rightColumnItems = <RecommendationCard>[];
    
//     for (int i = 0; i < recommendations.length; i++) {
//       if (i % 2 == 0) {
//         leftColumnItems.add(recommendations[i]);
//       } else {
//         rightColumnItems.add(recommendations[i]);
//       }
//     }
    
//     // Determine max number of items in either column
//     final int maxItemsPerColumn = (recommendations.length / 2).ceil();
    
//     return Expanded(
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Left column
//               Expanded(
//                 child: Column(
//                   children: List.generate(leftColumnItems.length, (index) {
//                     final bool isLastItem = index == leftColumnItems.length - 1;
//                     return Column(
//                       children: [
//                         RecomBoxItem(
//                           text: leftColumnItems[index].title,
//                           imgPath: leftColumnItems[index].imageUrl,
//                           isRecommended: leftColumnItems[index].isRecommended,
//                           aspectRatio: leftColumnItems[index].aspectRatio,
//                           onTap: () {
//                             // Handle item tap
//                           },
//                         ),
//                         if (!isLastItem) SizedBox(height: verticalGap),
//                       ],
//                     );
//                   }),
//                 ),
//               ),
              
//               // Gap between columns
//               SizedBox(width: horizontalGap),
              
//               // Right column
//               Expanded(
//                 child: Column(
//                   children: List.generate(rightColumnItems.length, (index) {
//                     final bool isLastItem = index == rightColumnItems.length - 1;
//                     return Column(
//                       children: [
//                         RecomBoxItem(
//                           text: rightColumnItems[index].title,
//                           imgPath: rightColumnItems[index].imageUrl,
//                           isRecommended: rightColumnItems[index].isRecommended,
//                           aspectRatio: rightColumnItems[index].aspectRatio,
//                           onTap: () {
//                             // Handle item tap
//                           },
//                         ),
//                         if (!isLastItem) SizedBox(height: verticalGap),
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }