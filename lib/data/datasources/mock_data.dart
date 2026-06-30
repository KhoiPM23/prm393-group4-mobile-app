class MockData {
  static List<Map<String, dynamic>> getMockUsers() {
    return [
      {
        'id': 'u1',
        'name': 'Phan Minh Khôi',
        'email': 'khoi.phan@gmail.com',
        'password': 'khoi1234',
        'avatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'role': 'customer',
      },
      {
        'id': 'host1',
        'name': 'Lâm Nguyễn',
        'email': 'lam.host@email.com',
        'password': 'lamnguyen1234',
        'avatarUrl':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'role': 'host',
      }
    ];
  }

  static List<Map<String, dynamic>> getMockProperties() {
    const hostId = 'host1';
    const hostName = 'Lâm Nguyễn';
    const hostAvatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMsgKz42wG0';

    return [
      {
        'id': 'p1',
        'title': 'Luxury Apartment Hải Châu',
        'location': 'Hải Châu, Đà Nẵng',
        'pricePerNight': 1850000.0,
        'rating': 4.9,
        'reviewsCount': 128,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': hostAvatar,
        'imageUrls': [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
          'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858',
        ],
        'amenities': ['Khu BBQ', 'Báo khí CO', 'Lò sưởi trong nhà', 'Ban công', 'Cho phép thú cưng', 'Bồn tắm', 'Máy sấy tóc', 'Ăn sáng', 'View biển', 'Wifi', 'Bếp', 'Hồ bơi', 'Chỗ đậu xe', 'Máy lạnh', 'Bàn ủi', 'Lò sưởi', 'Máy giặt'],
        'description':
            'Căn hộ cao cấp tọa lạc ngay trung tâm quận Hải Châu, view trọn sông Hàn thơ mộng. Đầy đủ tiện nghi chuẩn thượng lưu.',
        'categories': ['Xu hướng'],
        'latitude': 16.0665, // Tọa độ thực Hải Châu
        'longitude': 108.2215,
        'city': 'Đà Nẵng',
        'district': 'Hải Châu',
        'rooms': [
          {
            'id': 'r1_p1',
            'title': 'Studio Cao Cấp',
            'type': 'Single',
            'pricePerNight': 1850000.0,
            'amenities': ['Máy sấy tóc', 'Hồ bơi', 'Báo khí CO', 'Lò sưởi trong nhà', 'Cho phép thú cưng', 'Chỗ đậu xe', 'Ăn sáng', 'Wifi'],
            'imageUrls': ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'],
            'description': 'Phòng studio rộng rãi với đầy đủ tiện nghi.'
          },
          {
            'id': 'r2_p1',
            'title': 'Căn Hộ 2 Phòng Ngủ',
            'type': 'Double',
            'pricePerNight': 2850000.0,
            'amenities': ['Lò sưởi', 'Bàn ủi', 'Chỗ đậu xe', 'Khu BBQ', 'Máy sấy tóc', 'Máy lạnh', 'Báo khí CO', 'Lò sưởi trong nhà'],
            'imageUrls': ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688'],
            'description': 'Phù hợp cho gia đình hoặc nhóm bạn.'
          }
        ]
      },
      {
        'id': 'p2',
        'title': 'Vibe Beachfront Villa',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 2500000.0,
        'rating': 4.8,
        'reviewsCount': 96,
        'hostName': 'Lâm Nguyễn',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'imageUrls': [
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
        ],
        'amenities': ['View biển', 'Máy giặt', 'Ban công', 'Khu BBQ', 'Gym', 'Chỗ đậu xe', 'Bàn làm việc', 'Máy lạnh', 'Ăn sáng', 'Bồn tắm', 'Máy sấy tóc', 'Báo khí CO', 'Hồ bơi', 'Lò sưởi', 'Báo khói', 'Bàn ủi'],
        'description':
            'Trải nghiệm không gian nghỉ dưỡng tuyệt hảo ngay sát bờ biển Mỹ Khê, quận Ngũ Hành Sơn.',
        'categories': ['Gần biển', 'Xu hướng'],
        'latitude': 16.0352, // Tọa độ thực Ngũ Hành Sơn (gần Resort)
        'longitude': 108.2483,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p2',
            'title': 'Phòng Deluxe Hướng Biển',
            'type': 'Double',
            'pricePerNight': 2500000.0,
            'amenities': ['Bàn ủi', 'Lò sưởi', 'Hồ bơi', 'Máy sấy tóc'],
            'imageUrls': ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
            'description': 'Thức dậy với tiếng sóng vỗ rì rào.'
          }
        ]
      },
      {
        'id': 'p3',
        'title': 'Sơn Trà Mountain Homestay',
        'location': 'Sơn Trà, Đà Nẵng',
        'pricePerNight': 1200000.0,
        'rating': 4.7,
        'reviewsCount': 42,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://images.unsplash.com/photo-1449156001437-3a16c1dfbe2c',
          'https://images.unsplash.com/photo-1510798831971-661eb04b3739',
          'https://images.unsplash.com/photo-1521401830884-6c03c1c87ebb',
        ],
        'amenities': ['Chỗ đậu xe', 'Máy lạnh', 'Bếp', 'Bồn tắm', 'Hồ bơi', 'Ban công', 'Khu BBQ', 'Bàn ủi', 'Ăn sáng', 'Wifi', 'Lò sưởi trong nhà', 'Báo khói', 'Máy giặt', 'Báo khí CO', 'Máy sấy tóc'],
        'description':
            'Homestay ẩn mình giữa thiên nhiên hoang sơ của bán đảo Sơn Trà, thích hợp cho việc chữa lành và trốn khói bụi đô thị.',
        'categories': ['Vùng núi', 'Độc đáo'],
        'latitude': 16.0982, // Tọa độ thực khu Sơn Trà
        'longitude': 108.2614,
        'city': 'Đà Nẵng',
        'district': 'Sơn Trà',
        'rooms': [
          {
            'id': 'r1_p3',
            'title': 'Phòng Nhà Gỗ',
            'type': 'Single',
            'pricePerNight': 1200000.0,
            'amenities': ['Máy sấy tóc', 'Máy giặt', 'Bếp', 'Bàn ủi', 'Wifi', 'Ăn sáng', 'Hồ bơi'],
            'imageUrls': ['https://images.unsplash.com/photo-1449156001437-3a16c1dfbe2c'],
            'description': 'Trải nghiệm cuộc sống gần gũi thiên nhiên.'
          }
        ]
      },
      {
        'id': 'p4',
        'title': 'Han River Premier Studio',
        'location': 'Hải Châu, Đà Nẵng',
        'pricePerNight': 1950000.0,
        'rating': 4.9,
        'reviewsCount': 85,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'imageUrls': [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
          'https://images.unsplash.com/photo-1598928506311-c55dd1b65e90',
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        ],
        'amenities': ['Máy giặt', 'Báo khói', 'Khu BBQ', 'Cho phép thú cưng', 'Gym', 'Máy sấy tóc', 'Ăn sáng', 'Lò sưởi trong nhà', 'Ban công', 'Bồn tắm', 'Hồ bơi', 'Wifi', 'Máy lạnh', 'View biển', 'Chỗ đậu xe', 'Bàn ủi', 'Bàn làm việc', 'Lò sưởi'],
        'description':
            'Studio hiện đại nằm sát đường Bạch Đằng, tầm nhìn panorama ngắm trọn vẹn cầu Rồng và sông Hàn thơ mộng.',
        'categories': ['Xu hướng', 'Độc đáo'],
        'latitude': 16.0757, // Khu vực đường Bạch Đằng, Hải Châu
        'longitude': 108.2238,
        'city': 'Đà Nẵng',
        'district': 'Hải Châu',
        'rooms': [
          {
            'id': 'r1_p4',
            'title': 'Studio Cao Cấp View Sông',
            'type': 'Studio',
            'pricePerNight': 1950000.0,
            'amenities': ['Máy sấy tóc', 'Máy lạnh', 'Bàn ủi', 'Chỗ đậu xe', 'Gym'],
            'imageUrls': ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'],
            'description': 'Phòng studio view trọn sông Hàn.'
          }
        ]
      },
      {
        'id': 'p5',
        'title': 'My Khe Beachfront Boutique Hotel',
        'location': 'Sơn Trà, Đà Nẵng',
        'pricePerNight': 1350000.0,
        'rating': 4.6,
        'reviewsCount': 112,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9', 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6'
        ],
        'amenities': ['Máy giặt', 'Báo khói', 'View biển', 'Ban công', 'Ăn sáng', 'Lò sưởi trong nhà', 'Khu BBQ', 'Bếp', 'Báo khí CO', 'Bồn tắm', 'Máy sấy tóc', 'Cho phép thú cưng', 'Gym'],
        'description':
            'Khách sạn phong cách Boutique trẻ trung nằm trên đường Võ Nguyên Giáp, đối diện bãi tắm Phạm Văn Đồng sầm uất.',
        'categories': ['Gần biển', 'Xu hướng'],
        'latitude': 16.0622, // Khu vực Võ Nguyên Giáp, Sơn Trà
        'longitude': 108.2461,
        'city': 'Đà Nẵng',
        'district': 'Sơn Trà',
        'rooms': [
          {
            'id': 'r1_p5',
            'title': 'Boutique Room',
            'type': 'Double',
            'pricePerNight': 1350000.0,
            'amenities': ['Máy giặt', 'Bếp', 'Lò sưởi trong nhà', 'Báo khói', 'Gym', 'Ăn sáng', 'Bồn tắm', 'Máy sấy tóc'],
            'imageUrls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945'],
            'description': 'Phòng phong cách boutique ấm cúng.'
          }
        ]
      },
      {
        'id': 'p6',
        'title': 'An Thượng Cozy Stay',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 950000.0,
        'rating': 4.5,
        'reviewsCount': 54,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'imageUrls': [
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'
        ],
        'amenities': ['Khu BBQ', 'Báo khí CO', 'Bàn làm việc', 'Máy giặt', 'Lò sưởi', 'Wifi', 'Bàn ủi', 'Bếp', 'Hồ bơi', 'Máy sấy tóc'],
        'description':
            'Căn hộ dịch vụ ấm cúng nằm ngay trung tâm khu phố Tây An Thượng, cách biển Mỹ Khê chỉ 3 phút đi bộ.',
        'categories': ['Gần biển'],
        'latitude': 16.0505, // Khu phố du lịch An Thượng, Ngũ Hành Sơn
        'longitude': 108.2445,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p6',
            'title': 'Phòng Cozy Single',
            'type': 'Single',
            'pricePerNight': 950000.0,
            'amenities': ['Hồ bơi', 'Khu BBQ', 'Báo khí CO', 'Bếp', 'Wifi', 'Máy sấy tóc'],
            'imageUrls': ['https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af'],
            'description': 'Phòng nhỏ gọn, tiện nghi.'
          }
        ]
      },
      {
        'id': 'p7',
        'title': 'Dragon Bridge Riverside House',
        'location': 'Sơn Trà, Đà Nẵng',
        'pricePerNight': 1600000.0,
        'rating': 4.8,
        'reviewsCount': 73,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750', 'https://images.unsplash.com/photo-1493809842364-78817add7ffb', 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00'
        ],
        'amenities': ['Máy lạnh', 'Báo khí CO', 'Khu BBQ', 'Bếp', 'Wifi', 'Hồ bơi', 'Gym', 'Lò sưởi', 'Bàn ủi', 'View biển', 'Báo khói', 'Bồn tắm', 'Máy giặt', 'Cho phép thú cưng', 'Ban công', 'Máy sấy tóc'],
        'description':
            'Nhà nguyên căn tọa lạc trên đường Trần Hưng Đạo, vị trí đắc địa để ngắm Cầu Rồng phun lửa và nước vào cuối tuần.',
        'categories': ['Độc đáo', 'Di sản'],
        'latitude': 16.0682, // Đường Trần Hưng Đạo sát Sông Hàn, Sơn Trà
        'longitude': 108.2325,
        'city': 'Đà Nẵng',
        'district': 'Sơn Trà',
        'rooms': [
          {
            'id': 'r1_p7',
            'title': 'Căn Hộ View Cầu Rồng',
            'type': 'Apartment',
            'pricePerNight': 1600000.0,
            'amenities': ['Báo khí CO', 'Máy lạnh', 'Máy sấy tóc', 'Ban công', 'Báo khói', 'Bồn tắm', 'Cho phép thú cưng'],
            'imageUrls': ['https://images.unsplash.com/photo-1493809842364-78817add7ffb'],
            'description': 'Tận hưởng view cầu Rồng từ ban công.'
          }
        ]
      },
      {
        'id': 'p8',
        'title': 'Hoa Xuan Green Villa',
        'location': 'Cẩm Lệ, Đà Nẵng',
        'pricePerNight': 2200000.0,
        'rating': 4.7,
        'reviewsCount': 29,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914', 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688', 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9'
        ],
        'amenities': ['Bàn làm việc', 'Gym', 'Báo khói', 'Ban công', 'Chỗ đậu xe', 'Khu BBQ', 'Wifi', 'Hồ bơi', 'Máy lạnh', 'Cho phép thú cưng', 'Báo khí CO', 'Lò sưởi', 'Bàn ủi', 'Bồn tắm', 'Máy giặt'],
        'description':
            'Biệt thự sinh thái yên tĩnh tại khu đô thị Hòa Xuân, không gian rộng rãi thoáng đãng phù hợp cho gia đình nghỉ dưỡng.',
        'categories': ['Xu hướng'],
        'latitude': 16.0125, // Khu đô thị đảo sinh thái Hòa Xuân, Cẩm Lệ
        'longitude': 108.2204,
        'city': 'Đà Nẵng',
        'district': 'Cẩm Lệ',
        'rooms': [
          {
            'id': 'r1_p8',
            'title': 'Green Villa Full House',
            'type': 'Villa',
            'pricePerNight': 2200000.0,
            'amenities': ['Bàn ủi', 'Ban công', 'Báo khí CO', 'Bồn tắm', 'Bàn làm việc'],
            'imageUrls': ['https://images.unsplash.com/photo-1580587771525-78b9dba3b914'],
            'description': 'Không gian xanh mát cho cả gia đình.'
          }
        ]
      },
      {
        'id': 'p9',
        'title': 'Shilla Monogram Quangnam Danang',
        'location': 'Điện Bàn, Quảng Nam',
        'pricePerNight': 3500000.0,
        'rating': 4.9,
        'reviewsCount': 210,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
        'imageUrls': [
          'https://images.unsplash.com/photo-1582719508461-905c673771fd',
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d'
        ],
        'amenities': ['Bồn tắm', 'Ban công', 'Máy sấy tóc', 'Lò sưởi trong nhà', 'Ăn sáng', 'Chỗ đậu xe', 'Bàn ủi', 'Bếp', 'Khu BBQ', 'Gym', 'Wifi', 'Báo khí CO', 'Báo khói', 'Máy giặt', 'Bàn làm việc', 'Lò sưởi', 'View biển'],
        'description': 'Khu nghỉ dưỡng 5 sao mang đậm phong cách Hàn Quốc kết hợp với nét duyên dáng của miền Trung Việt Nam.',
        'categories': ['Resort', 'Gần biển'],
        'latitude': 15.9328, // Tọa độ Điện Bàn
        'longitude': 108.3185,
        'city': 'Quảng Nam',
        'district': 'Điện Bàn',
        'rooms': [
          {
            'id': 'r1_p9',
            'title': 'Phòng Deluxe Hướng Biển',
            'type': 'Double',
            'pricePerNight': 3500000.0,
            'amenities': ['Lò sưởi', 'Ban công', 'Gym', 'Bàn làm việc', 'Báo khí CO', 'Máy giặt', 'Bồn tắm'],
            'imageUrls': ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
            'description': 'Phòng nghỉ sang trọng với tầm nhìn hướng ra đại dương.'
          }
        ]
      },
      {
        'id': 'p10',
        'title': 'Naman Retreat',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 4500000.0,
        'rating': 4.8,
        'reviewsCount': 345,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
        'imageUrls': [
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2'
        ],
        'amenities': ['View biển', 'Gym', 'Bàn ủi', 'Lò sưởi', 'Ban công', 'Máy sấy tóc', 'Cho phép thú cưng', 'Bồn tắm', 'Máy giặt', 'Lò sưởi trong nhà', 'Báo khí CO'],
        'description': 'Nơi trú ẩn hoàn hảo kết hợp giữa văn hóa Việt Nam truyền thống và kiến trúc tre đương đại.',
        'categories': ['Resort', 'Chăm sóc sức khỏe'],
        'latitude': 15.9866, // Tọa độ Ngũ Hành Sơn
        'longitude': 108.2831,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p10',
            'title': 'Babylon Room',
            'type': 'Double',
            'pricePerNight': 4500000.0,
            'amenities': ['Cho phép thú cưng', 'Ban công', 'Bồn tắm', 'Bàn ủi', 'Lò sưởi', 'Lò sưởi trong nhà', 'Báo khí CO'],
            'imageUrls': ['https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd'],
            'description': 'Thiết kế độc đáo hòa mình vào thiên nhiên.'
          }
        ]
      },
      {
        'id': 'p11',
        'title': 'Furama Resort Danang',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 3800000.0,
        'rating': 4.7,
        'reviewsCount': 512,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1566492031773-4f4e44671857',
        'imageUrls': [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945',
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7',
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4'
        ],
        'amenities': ['Máy sấy tóc', 'Bàn ủi', 'Khu BBQ', 'Báo khói', 'Lò sưởi', 'Bếp', 'Gym', 'Wifi', 'Máy lạnh', 'Chỗ đậu xe', 'Cho phép thú cưng', 'Máy giặt', 'View biển', 'Lò sưởi trong nhà', 'Báo khí CO', 'Hồ bơi', 'Ăn sáng'],
        'description': 'Khu nghỉ dưỡng di sản đầu tiên tại Việt Nam mang đậm phong cách Chăm Pa.',
        'categories': ['Resort', 'Sang trọng'],
        'latitude': 16.0357, // Tọa độ Ngũ Hành Sơn
        'longitude': 108.2505,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p11',
            'title': 'Ocean Suite',
            'type': 'Suite',
            'pricePerNight': 6800000.0,
            'amenities': ['Bếp', 'Hồ bơi', 'View biển', 'Ăn sáng', 'Lò sưởi trong nhà', 'Chỗ đậu xe', 'Gym', 'Báo khói'],
            'imageUrls': ['https://images.unsplash.com/photo-1566073771259-6a8506099945'],
            'description': 'Phòng Suite cao cấp với tiện nghi hoàng gia.'
          }
        ]
      },
      {
        'id': 'p12',
        'title': 'Hyatt Regency Danang',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 4200000.0,
        'rating': 4.9,
        'reviewsCount': 420,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79',
        'imageUrls': [
          'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6',
          'https://images.unsplash.com/photo-1540518614846-7eded433c457',
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461'
        ],
        'amenities': ['Báo khí CO', 'Wifi', 'Báo khói', 'Bàn ủi', 'Chỗ đậu xe', 'Máy lạnh', 'View biển', 'Máy giặt', 'Cho phép thú cưng', 'Bếp', 'Ban công', 'Khu BBQ', 'Lò sưởi', 'Gym', 'Hồ bơi', 'Ăn sáng', 'Máy sấy tóc', 'Bồn tắm'],
        'description': 'Thiên đường nghỉ dưỡng lý tưởng cho gia đình với hồ bơi cát mô phỏng bãi biển thu nhỏ.',
        'categories': ['Gia đình', 'Resort'],
        'latitude': 16.0163, // Tọa độ Ngũ Hành Sơn
        'longitude': 108.2612,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p12',
            'title': 'Guest Room Ocean View',
            'type': 'Double',
            'pricePerNight': 4200000.0,
            'amenities': ['View biển', 'Khu BBQ', 'Wifi', 'Ban công'],
            'imageUrls': ['https://images.unsplash.com/photo-1596394516093-501ba68a0ba6'],
            'description': 'Thức dậy cùng bình minh tuyệt đẹp trên biển.'
          }
        ]
      },
      {
        'id': 'p13',
        'title': 'Melia Danang Beach Resort',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 3200000.0,
        'rating': 4.6,
        'reviewsCount': 289,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e',
        'imageUrls': [
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2'
        ],
        'amenities': ['Báo khói', 'Cho phép thú cưng', 'Lò sưởi', 'Lò sưởi trong nhà', 'Wifi', 'Máy giặt', 'Gym', 'Ăn sáng', 'Khu BBQ', 'Máy sấy tóc', 'View biển', 'Bàn ủi', 'Bồn tắm', 'Ban công', 'Hồ bơi', 'Bàn làm việc', 'Chỗ đậu xe'],
        'description': 'Khu nghỉ dưỡng quốc tế nằm nép mình dưới chân ngọn núi Ngũ Hành Sơn hùng vĩ.',
        'categories': ['Resort', 'Cặp đôi'],
        'latitude': 16.0084, // Tọa độ Ngũ Hành Sơn
        'longitude': 108.2655,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p13',
            'title': 'Melia Guest Room',
            'type': 'Double',
            'pricePerNight': 3200000.0,
            'amenities': ['Lò sưởi trong nhà', 'View biển', 'Máy sấy tóc', 'Báo khói', 'Ăn sáng'],
            'imageUrls': ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
            'description': 'Thiết kế hiện đại mang phong cách Tây Ban Nha.'
          }
        ]
      },
      {
        'id': 'p14',
        'title': 'Vinpearl Resort & Spa Da Nang',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 6500000.0,
        'rating': 4.8,
        'reviewsCount': 310,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
        'imageUrls': [
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
          'https://images.unsplash.com/photo-1540518614846-7eded433c457',
          'https://images.unsplash.com/photo-1566073771259-6a8506099945'
        ],
        'amenities': ['Máy giặt', 'Chỗ đậu xe', 'Cho phép thú cưng', 'Bồn tắm', 'Lò sưởi trong nhà', 'Ăn sáng', 'Bàn làm việc', 'Báo khói', 'Khu BBQ', 'Wifi', 'Lò sưởi', 'Hồ bơi', 'Bếp', 'Ban công'],
        'description': 'Chuỗi biệt thự ven biển tuyệt đẹp mang kiến trúc tân cổ điển sang trọng.',
        'categories': ['Villa', 'Gia đình'],
        'latitude': 15.9922, // Tọa độ Ngũ Hành Sơn
        'longitude': 108.2750,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
        'rooms': [
          {
            'id': 'r1_p14',
            'title': 'Villa 3 Phòng Ngủ Hướng Biển',
            'type': 'Villa',
            'pricePerNight': 6500000.0,
            'amenities': ['Wifi', 'Cho phép thú cưng', 'Hồ bơi', 'Bồn tắm', 'Khu BBQ', 'Báo khói', 'Bàn làm việc'],
            'imageUrls': ['https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd'],
            'description': 'Sự lựa chọn hoàn hảo cho kỳ nghỉ dưỡng gia đình.'
          }
        ]
      },
      {
        'id': 'p15',
        'title': 'Grandvrio Ocean Resort Danang',
        'location': 'Điện Bàn, Quảng Nam',
        'pricePerNight': 2800000.0,
        'rating': 4.5,
        'reviewsCount': 175,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
        'imageUrls': [
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d',
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7',
          'https://images.unsplash.com/photo-1582719508461-905c673771fd'
        ],
        'amenities': ['Máy sấy tóc', 'Cho phép thú cưng', 'Bếp', 'View biển', 'Báo khí CO', 'Khu BBQ', 'Máy giặt', 'Máy lạnh', 'Lò sưởi', 'Wifi', 'Báo khói', 'Lò sưởi trong nhà', 'Ban công', 'Bàn ủi', 'Bàn làm việc', 'Hồ bơi'],
        'description': 'Trải nghiệm văn hóa và dịch vụ chuẩn Nhật Bản ngay tại miền Trung Việt Nam.',
        'categories': ['Resort', 'Thư giãn'],
        'latitude': 15.9392, // Tọa độ Điện Bàn
        'longitude': 108.3150,
        'city': 'Quảng Nam',
        'district': 'Điện Bàn',
        'rooms': [
          {
            'id': 'r1_p15',
            'title': 'Phòng Deluxe',
            'type': 'Double',
            'pricePerNight': 2800000.0,
            'amenities': ['Cho phép thú cưng', 'Máy lạnh', 'Máy sấy tóc', 'Bàn làm việc'],
            'imageUrls': ['https://images.unsplash.com/photo-1571896349842-33c89424de2d'],
            'description': 'Phòng nghỉ với nét trang trí tối giản, thanh lịch.'
          }
        ]
      },
      {
        'id': 'p16',
        'title': 'Le Belhamy Hoi An Resort and Spa',
        'location': 'Điện Bàn, Quảng Nam',
        'pricePerNight': 1500000.0,
        'rating': 4.3,
        'reviewsCount': 112,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1566492031773-4f4e44671857',
        'imageUrls': [
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2',
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4'
        ],
        'amenities': ['Khu BBQ', 'Wifi', 'Báo khí CO', 'View biển', 'Cho phép thú cưng', 'Bếp', 'Máy sấy tóc', 'Máy giặt', 'Hồ bơi', 'Bàn ủi', 'Ban công', 'Gym', 'Bàn làm việc', 'Lò sưởi trong nhà', 'Báo khói', 'Chỗ đậu xe', 'Máy lạnh', 'Ăn sáng'],
        'description': 'Khu nghỉ dưỡng mang âm hưởng kiến trúc cổ điển xen lẫn nhiệt đới, trải dài trên bãi biển Hà My.',
        'categories': ['Gần biển', 'Tiết kiệm'],
        'latitude': 15.9221, // Tọa độ Điện Bàn
        'longitude': 108.3225,
        'city': 'Quảng Nam',
        'district': 'Điện Bàn',
        'rooms': [
          {
            'id': 'r1_p16',
            'title': 'Hoi An Garden Room',
            'type': 'Double',
            'pricePerNight': 1500000.0,
            'amenities': ['Báo khí CO', 'Bếp', 'Cho phép thú cưng', 'Bàn ủi'],
            'imageUrls': ['https://images.unsplash.com/photo-1499793983690-e29da59ef1c2'],
            'description': 'Đắm mình trong không gian yên tĩnh của khu vườn nhiệt đới.'
          }
        ]
      },
      {
        'id': 'p17',
        'title': 'Four Seasons Resort The Nam Hai',
        'location': 'Điện Bàn, Quảng Nam',
        'pricePerNight': 9500000.0,
        'rating': 5.0,
        'reviewsCount': 620,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79',
        'imageUrls': [
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
          'https://images.unsplash.com/photo-1566073771259-6a8506099945',
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd'
        ],
        'amenities': ['Ăn sáng', 'Báo khí CO', 'Máy giặt', 'Bàn làm việc', 'View biển', 'Máy lạnh', 'Lò sưởi trong nhà', 'Hồ bơi', 'Máy sấy tóc', 'Gym', 'Ban công', 'Chỗ đậu xe', 'Bàn ủi', 'Cho phép thú cưng', 'Báo khói', 'Lò sưởi', 'Wifi'],
        'description': 'Đỉnh cao của sự xa hoa và riêng tư, The Nam Hai là một kiệt tác kiến trúc ven biển.',
        'categories': ['Siêu sang', 'Villa'],
        'latitude': 15.9100, // Tọa độ Điện Bàn
        'longitude': 108.3275,
        'city': 'Quảng Nam',
        'district': 'Điện Bàn',
        'rooms': [
          {
            'id': 'r1_p17',
            'title': 'One Bedroom Villa',
            'type': 'Villa',
            'pricePerNight': 9500000.0,
            'amenities': ['Bàn làm việc', 'View biển', 'Lò sưởi', 'Máy lạnh'],
            'imageUrls': ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
            'description': 'Villa độc lập với thiết kế đỉnh cao và không gian mở.'
          }
        ]
      },
      {
        'id': 'p18',
        'title': 'Mulberry Collection Silk Village',
        'location': 'Hội An, Quảng Nam',
        'pricePerNight': 1200000.0,
        'rating': 4.6,
        'reviewsCount': 185,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e',
        'imageUrls': [
          'https://images.unsplash.com/photo-1540518614846-7eded433c457',
          'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6',
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461'
        ],
        'amenities': ['Máy lạnh', 'Bàn ủi', 'Ăn sáng', 'Wifi', 'Khu BBQ', 'Báo khí CO', 'Hồ bơi', 'Bồn tắm', 'Bàn làm việc', 'Cho phép thú cưng', 'Bếp', 'View biển', 'Lò sưởi', 'Gym', 'Báo khói', 'Máy sấy tóc', 'Ban công', 'Lò sưởi trong nhà'],
        'description': 'Khu nghỉ dưỡng lấy cảm hứng từ làng nghề lụa truyền thống của Hội An, không gian yên bình tĩnh lặng.',
        'categories': ['Văn hóa', 'Gia đình'],
        'latitude': 15.8824, // Tọa độ Hội An
        'longitude': 108.3168,
        'city': 'Quảng Nam',
        'district': 'Hội An',
        'rooms': [
          {
            'id': 'r1_p18',
            'title': 'Premier Balcony Room',
            'type': 'Double',
            'pricePerNight': 1200000.0,
            'amenities': ['Ban công', 'Bồn tắm', 'Máy lạnh', 'Lò sưởi trong nhà', 'View biển', 'Máy sấy tóc'],
            'imageUrls': ['https://images.unsplash.com/photo-1540518614846-7eded433c457'],
            'description': 'Phòng nghỉ êm ái với họa tiết lụa tơ tằm tinh tế.'
          }
        ]
      }
    ];
  }

  static List<Map<String, dynamic>> getMockBookings() {
    return [
      {
        'id': 'b1',
        'orderCode': 10001,
        'userId': 'u1',
        'propertyId': 'p1',
        'property': getMockProperties()[0],
        'checkIn': '2026-10-12T14:00:00Z',
        'checkOut': '2026-10-15T12:00:00Z',
        'guests': 2,
        'basePrice': 1850000.0,
        'serviceFee': 150000.0,
        'tax': 185000.0,
        'discountAmount': 0.0,
        'totalPrice': 5885000.0,
        'status': 'confirmed',
        'updatedAt': '2026-10-10T10:00:00Z',
        'paymentMethod': 'MoMo',
        'transactionId': 'TRX-999-001',
      },
      {
        'id': 'b2',
        'orderCode': 10002,
        'userId': 'u1',
        'propertyId': 'p2',
        'property': getMockProperties()[1],
        'checkIn': '2026-08-05T14:00:00Z',
        'checkOut': '2026-08-08T12:00:00Z',
        'guests': 4,
        'basePrice': 2500000.0,
        'serviceFee': 200000.0,
        'tax': 250000.0,
        'discountAmount': 500000.0,
        'totalPrice': 7450000.0,
        'status': 'completed',
        'updatedAt': '2026-08-09T09:00:00Z',
        'paymentMethod': 'Bank Transfer',
        'transactionId': 'TRX-888-002',
      }
    ];
  }
  static List<Map<String, dynamic>> getMockMessages() => [];
}
