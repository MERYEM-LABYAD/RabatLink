import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// Import de tes écrans
import '../profile/profile_screen.dart';
import '../chat/chat_list_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../events/events_screen.dart';
import '../events/event_details_screen.dart';
import '../marketplace/product_details_screen.dart';
import '../chat/chat_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _pages = [
      _HomeTab(onNavigate: (index, {String? quartier}) {
        setState(() => _currentIndex = index);
        if (quartier != null && index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                currentUserId: uid,
                isPublic: true,
                targetId: quartier,
              ),
            ),
          );
        }
      }),
      ChatListScreen(currentUserId: uid, quartiers: const ['Agdal', 'Hay Riad', 'Souissi', 'Hassan']),
      const MarketplaceScreen(),
      const EventsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey.withOpacity(0.5),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: '•'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: '•'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: '•'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: '•'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: '•'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final Function(int, {String? quartier}) onNavigate;
  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String username = 'Citoyen';
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  final List<Map<String, String>> quartiers = [
    {"name": "Agdal", "image": "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=300"},
    {"name": "Hay Riad", "image": "https://images.unsplash.com/photo-1558882224-dda166733046?w=300"},
    {"name": "Souissi", "image": "https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=300"},
    {"name": "Hassan", "image": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && doc.exists) {
        setState(() => username = doc.data()?['username'] ?? 'Citoyen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.lightGreen.withValues(alpha: 0.03),
            AppColors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: LOGO AVEC EFFET VERT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Effet de glow vert derrière
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightGreen.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 140,
                        width: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_city, color: AppColors.primary, size: 36),
                              SizedBox(width: 12),
                              Text(
                                'RabatLink',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- GREETINGS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Rabat vous attend,\n$username.',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- CAROUSEL QUARTIERS AUTO-SCROLL CLIQUABLE ---
              SizedBox(
                height: 110,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 24),
                  itemCount: quartiers.length * 100,
                  itemBuilder: (context, index) {
                    final quartier = quartiers[index % quartiers.length];
                    return GestureDetector(
                      onTap: () {
                        // Pause le scroll
                        _scrollTimer?.cancel();
                        // Navigation vers le chat
                        widget.onNavigate(1, quartier: quartier['name']!);
                        // Redémarre après 3 secondes
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) _startAutoScroll();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.lightGreen.withValues(alpha: 0.2),
                                foregroundImage: NetworkImage(quartier['image']!),
                                child: const Icon(Icons.location_city, color: AppColors.primary, size: 20),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              quartier['name']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // --- ACTIONS CHIC ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildChicAction(Icons.storefront_rounded, "Marché", AppColors.primary, () => widget.onNavigate(2)),
                    _buildChicAction(Icons.chat_bubble_rounded, "Chat", AppColors.secondary, () => widget.onNavigate(1)),
                    _buildChicAction(Icons.event_rounded, "Events", AppColors.lightGreen, () => widget.onNavigate(3)),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- DERNIERS PRODUITS AJOUTÉS ---
              _buildSectionTitle("Derniers produits"),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('createdAt', descending: true)
                    .limit(2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptySection("Aucun produit disponible");
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var product = doc.data() as Map<String, dynamic>;
                      return _buildProductCard(context, product, doc.id);
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              // --- DERNIERS ÉVÉNEMENTS ---
              _buildSectionTitle("Prochains événements"),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('createdAt', descending: true)
                    .limit(2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptySection("Aucun événement prévu");
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var event = doc.data() as Map<String, dynamic>;
                      return _buildEventCard(context, event, doc.id);
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),

              // --- NOUVELLE SECTION: COMMERÇANTS POPULAIRES ---
              _buildSectionTitle("Commerçants actifs"),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'commercant')
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptySection("Aucun commerçant pour le moment");
                  }

                  return SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var merchant = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return _buildMerchantCard(merchant);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // --- NOUVELLE SECTION: STATISTIQUES RABAT ---
              _buildSectionTitle("RabatLink en chiffres"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.lightGreen.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, userSnapshot) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('products').snapshots(),
                        builder: (context, productSnapshot) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('events').snapshots(),
                            builder: (context, eventSnapshot) {
                              int userCount = userSnapshot.data?.docs.length ?? 0;
                              int productCount = productSnapshot.data?.docs.length ?? 0;
                              int eventCount = eventSnapshot.data?.docs.length ?? 0;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(Icons.people, userCount.toString(), "Membres"),
                                  _buildStatColumn(Icons.shopping_bag, productCount.toString(), "Produits"),
                                  _buildStatColumn(Icons.event, eventCount.toString(), "Événements"),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- FOOTER: À PROPOS DE RABATLINK ---
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "RabatLink",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Connectons Rabat ensemble\nMarketplace • Événements • Communauté",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, String productId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: productId,
              productData: product,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product['imageUrl'] ?? 'https://via.placeholder.com/100',
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 70,
                  width: 70,
                  color: AppColors.lightGreen.withValues(alpha: 0.2),
                  child: const Icon(Icons.image, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Produit',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['price'] ?? '0'} DH',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event, String eventId) {
    DateTime? eventDate = (event['date'] as Timestamp?)?.toDate();
    String formattedDate = eventDate != null
        ? DateFormat('dd MMM').format(eventDate)
        : "Bientôt";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventId: eventId,
              eventData: event,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                event['imageUrl'] ?? 'https://via.placeholder.com/100',
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 70,
                  width: 70,
                  color: AppColors.lightGreen.withValues(alpha: 0.2),
                  child: const Icon(Icons.event, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Événement',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(Map<String, dynamic> merchant) {
    String name = merchant['username'] ?? merchant['name'] ?? 'Commerçant';
    String ville = merchant['ville'] ?? 'Rabat';

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 12, color: AppColors.grey),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  ville,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildChicAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 90,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: AppColors.grey.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}