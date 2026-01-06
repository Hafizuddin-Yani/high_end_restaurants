// import 'package:uuid/uuid.dart';
import '../../domain/models.dart';
import '../../data/repositories.dart';

Future<void> seedSampleData(DatabaseRepository repo) async {
  final packages = [
    const MenuPackage(
      id: 'pkg_nasilemak_royal',
      name: 'Royal Nasi Lemak',
      description:
          'The national treasure elevated. Fragrant coconut milk rice served with sambal udang petai (prawns), wagyu beef rendang, crispy anchovies, peanuts, and a perfectly mollet egg. Wrapt in banana leaf.',
      imageUrl:
          'https://images.unsplash.com/photo-1626202163589-3597d519b780?q=80&w=2000&auto=format&fit=crop', // Nasi Lemak
      pricePerGuest: 85.00,
      dietaryInfo: ['Spicy', 'Contains Nuts', 'Shellfish'],
    ),
    const MenuPackage(
      id: 'pkg_wagyu_satay',
      name: 'Wagyu Satay Platter',
      description:
          'Marinated A5 Wagyu beef and organic chicken skewers, grilled over charcoal. Served with a rich handcrafted spicy peanut sauce, compressed rice cakes, and pickled cucumber relish.',
      imageUrl:
          'https://images.unsplash.com/photo-1628294895950-98052523e036?q=80&w=2000&auto=format&fit=crop', // Satay/Grilled
      pricePerGuest: 150.00,
      dietaryInfo: ['Contains Nuts', 'Gluten-Free'],
    ),
    const MenuPackage(
      id: 'pkg_lobster_laksa',
      name: 'Sarawak Lobster Laksa',
      description:
          'A luxurious take on the Sarawak classic. Vermicelli noodles in a robust, aromatic prawn and chicken broth, topped with a whole butter-poached lobster tail, shredded chicken, and fresh coriander.',
      imageUrl:
          'https://images.unsplash.com/photo-1596450516147-36209b5ce444?q=80&w=2000&auto=format&fit=crop', // Laksa
      pricePerGuest: 180.00,
      dietaryInfo: ['Spicy', 'Shellfish'],
    ),
    const MenuPackage(
      id: 'pkg_rendang_tok',
      name: 'Heritage Beef Rendang Tok',
      description:
          'Slow-cooked for 48 hours, this dry curry features melt-in-your-mouth beef cuts in a complex spice paste with toasted coconut (kerisik), turmeric leaf, and kaffir lime.',
      imageUrl:
          'https://images.unsplash.com/photo-1606443429388-348e36e395fd?q=80&w=2000&auto=format&fit=crop', // Curry/Rendang style
      pricePerGuest: 120.00,
      dietaryInfo: ['Spicy', 'Gluten-Free'],
    ),
    const MenuPackage(
      id: 'pkg_premium_chicken_rice',
      name: 'Emperor\'s Chicken Rice',
      description:
          'Organic free-range corn-fed chicken, poached to silken perfection. Served with aromatic jasmine rice cooked in chicken stock, house-made chili garlic sauce, and ginger puree.',
      imageUrl:
          'https://images.unsplash.com/photo-1574548680182-132da92c9085?q=80&w=2000&auto=format&fit=crop', // Chicken Rice
      pricePerGuest: 65.00,
      dietaryInfo: ['Halal'],
    ),
    const MenuPackage(
      id: 'pkg_char_kway_teow',
      name: 'Signature Char Kway Teow',
      description:
          'Flat rice noodles stir-fried over extreme heat (Wok Hei) with tiger prawns, scallops, cockles, Chinese sausage, egg, and bean sprouts. A smoky, savory delight.',
      imageUrl:
          'https://images.unsplash.com/photo-1552590635-27c2c2128abf?q=80&w=2000&auto=format&fit=crop', // Noodles
      pricePerGuest: 75.00,
      dietaryInfo: ['Shellfish', 'Contains Egg'],
    ),
    const MenuPackage(
      id: 'pkg_nasi_kerabu',
      name: 'Blue Diamond Nasi Kerabu',
      description:
          'Butterfly pea flower rice served with grilled spiced fish (Percik), salted egg, fish crackers, and a medley of finely chopped aromatic local herbs and vegetables.',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1694697686500-1493630f9d92?q=80&w=2000&auto=format&fit=crop', // Rice dish
      pricePerGuest: 90.00,
      dietaryInfo: ['Spicy', 'Gluten-Free'],
    ),
    const MenuPackage(
      id: 'pkg_durian_tasting',
      name: 'Musang King Indulgence',
      description:
          'The King of Fruits reimagined. A tasting platter featuring Musang King crepe, durian mousse, and fresh premium durian pulp. Paired with mangosteen sorbet to cool the palate.',
      imageUrl:
          'https://images.unsplash.com/photo-1587825130836-96860af7c98c?q=80&w=2000&auto=format&fit=crop', // Dessert/Fruit
      pricePerGuest: 200.00,
      dietaryInfo: ['Vegetarian', 'Distinctive Aroma'],
    ),
  ];

  for (final pkg in packages) {
    await repo.addPackage(pkg);
  }
  await seedSampleUsers(repo);
}

Future<void> seedSampleUsers(DatabaseRepository repo) async {
  final users = [
    AppUser(
      id: 'user_alice_editor',
      email: 'alice@luxe.com',
      name: 'Alice Chen',
      role: 'editor',
      status: 'active',
      lastLogin: DateTime.now().subtract(const Duration(hours: 4)),
      avatarUrl: 'https://i.pravatar.cc/150?u=alice',
    ),
    AppUser(
      id: 'user_bob_guest',
      email: 'bob@guest.com',
      name: 'Bob Smith',
      role: 'user',
      status: 'active',
      lastLogin: DateTime.now().subtract(const Duration(days: 2)),
      avatarUrl: 'https://i.pravatar.cc/150?u=bob',
    ),
    AppUser(
      id: 'user_charlie_banned',
      email: 'charlie@bad.com',
      name: 'Charlie Bad',
      role: 'user',
      status: 'banned',
      lastLogin: DateTime.now().subtract(const Duration(days: 30)),
      avatarUrl: 'https://i.pravatar.cc/150?u=charlie',
    ),
    AppUser(
      id: 'user_david_admin',
      email: 'david@admin.com',
      name: 'David Admin',
      role: 'admin',
      status: 'active',
      lastLogin: DateTime.now(),
      avatarUrl: 'https://i.pravatar.cc/150?u=david',
    ),
  ];

  for (final user in users) {
    // We use updateUser as upsert
    await repo.updateUser(user);
  }
}
