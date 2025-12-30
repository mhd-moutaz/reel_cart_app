// lib/screens/reels_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _reels = [];
  bool _isLoading = true;
  Map<int, VideoPlayerController?> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _loadReelsData();
  }

  Future<void> _loadReelsData() async {
    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/videos/reels_data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        _reels = jsonData.map((item) => {
          'videoPath': item['videoPath'] as String,
          'title': item['title'] as String,
          'description': item['description'] as String,
          'price': item['price'] as String,
          'likes': item['likes'] as int,
          'liked': item['liked'] as bool,
          'color': Color(int.parse(item['color'].substring(2), radix: 16)),
        }).toList();
        _isLoading = false;
      });

      // Initialize first video
      if (_reels.isNotEmpty) {
        _initializeVideo(0);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading reels data: $e');
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (_videoControllers[index] != null) {
      _videoControllers[index]!.play();
      return;
    }

    try {
      final controller = VideoPlayerController.asset(_reels[index]['videoPath']);
      await controller.initialize();
      controller.setLooping(true);
      
      setState(() {
        _videoControllers[index] = controller;
      });
      
      controller.play();
    } catch (e) {
      print('Error initializing video at index $index: $e');
      // Video file might not exist, continue without it
    }
  }

  void _pauseAllVideos() {
    _videoControllers.forEach((index, controller) {
      controller?.pause();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoControllers.forEach((index, controller) {
      controller?.dispose();
    });
    super.dispose();
  }

  void _showProductDetails() {
    if (_reels.isEmpty) return;
    final reel = _reels[_currentPage];
    _pauseAllVideos();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductSheet(reel),
    ).then((_) {
      // Resume video when sheet is closed
      _videoControllers[_currentPage]?.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
              ),
            )
          : _reels.isEmpty
              ? const Center(
                  child: Text(
                    'No videos found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Stack(
                  children: [
                    // 1. Background Gradient (Dark Theme)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A), Colors.black],
                        ),
                      ),
                    ),

                    // 2. Videos / Reels PageView
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: _reels.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        _pauseAllVideos();
                        _initializeVideo(index);
                      },
                      itemBuilder: (context, index) {
                        return _buildReelItem(index);
                      },
                    ),

                    // 3. Floating Overlay Info (Store Name & Title)
                    _buildOverlayContent(),

                    // 4. Interaction Bar (Right Side)
                    _buildSideActions(),

                    // 5. Main Action Button (Bottom)
                    _buildMainActionButton(),
                  ],
                ),
    );
  }

  Widget _buildReelItem(int index) {
    final reel = _reels[index];
    final controller = _videoControllers[index];

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            reel['color'].withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: controller != null && controller.value.isInitialized
          ? GestureDetector(
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                  if (!controller.value.isPlaying)
                    Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 80,
                      ),
                    ),
                ],
              ),
            )
          : Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 80,
              ),
            ),
    );
  }

  Widget _buildOverlayContent() {
    if (_reels.isEmpty) return const SizedBox.shrink();
    
    return Positioned(
      left: 20,
      bottom: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Featured Product',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _reels[_currentPage]['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              _reels[_currentPage]['description'],
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideActions() {
    if (_reels.isEmpty) return const SizedBox.shrink();
    
    bool isLiked = _reels[_currentPage]['liked'];
    return Positioned(
      right: 20,
      bottom: 120,
      child: Column(
        children: [
          _buildSideButton(
            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isLiked ? Colors.redAccent : Colors.white,
            label: _reels[_currentPage]['likes'].toString(),
            onTap: () {
              setState(() {
                _reels[_currentPage]['liked'] = !isLiked;
                _reels[_currentPage]['likes'] += isLiked ? -1 : 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _showProductDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shopping_bag_outlined, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'View Product Details',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProductSheet(Map<String, dynamic> reel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Text(reel['title'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(reel['price'], style: const TextStyle(color: Color(0xFF10B981), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(reel['description'], style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.5)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Add to Shopping Cart', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
