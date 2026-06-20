class MockData {
  static List<Map<String, dynamic>> getMockUsers() {
    return [
      {
        'id': 'u1',
        'name': 'Phan Minh Khôi',
        'email': 'khoi.phan@email.com',
        'avatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
      }
    ];
  }

  static List<Map<String, dynamic>> getMockProperties() {
    return [
      {
        'id': 'p1',
        'title': 'Luxury Apartment Hải Châu',
        'location': 'Hải Châu, Đà Nẵng',
        'pricePerNight': 1850000.0,
        'rating': 4.9,
        'reviewsCount': 128,
        'hostName': 'Minh Khôi',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'
        ],
        'amenities': ['Wifi', 'Bếp', 'Máy lạnh', 'Chỗ đậu xe', 'Hồ bơi'],
        'description':
            'Căn hộ cao cấp tọa lạc ngay trung tâm quận Hải Châu, view trọn sông Hàn thơ mộng. Đầy đủ tiện nghi chuẩn thượng lưu.',
        'latitude': 16.0665, // Tọa độ thực Hải Châu
        'longitude': 108.2215,
        'city': 'Đà Nẵng',
        'district': 'Hải Châu',
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
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ'
        ],
        'amenities': ['Hồ bơi', 'Ăn sáng', 'Máy lạnh', 'Sân vườn', 'Sát biển'],
        'description':
            'Trải nghiệm không gian nghỉ dưỡng tuyệt hảo ngay sát bờ biển Mỹ Khê, quận Ngũ Hành Sơn.',
        'latitude': 16.0352, // Tọa độ thực Ngũ Hành Sơn (gần Resort)
        'longitude': 108.2483,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
      },
      {
        'id': 'p3',
        'title': 'Sơn Trà Mountain Homestay',
        'location': 'Sơn Trà, Đà Nẵng',
        'pricePerNight': 1200000.0,
        'rating': 4.7,
        'reviewsCount': 42,
        'hostName': 'Minh Khôi',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'
        ],
        'amenities': ['Wifi', 'Máy lạnh', 'Sân vườn'],
        'description':
            'Homestay ẩn mình giữa thiên nhiên hoang sơ của bán đảo Sơn Trà, thích hợp cho việc chữa lành và trốn khói bụi đô thị.',
        'latitude': 16.0982, // Tọa độ thực khu Sơn Trà
        'longitude': 108.2614,
        'city': 'Đà Nẵng',
        'district': 'Sơn Trà',
      },
      {
        'id': 'p4',
        'title': 'Han River Premier Studio',
        'location': 'Hải Châu, Đà Nẵng',
        'pricePerNight': 1950000.0,
        'rating': 4.9,
        'reviewsCount': 85,
        'hostName': 'Tuấn Anh',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ'
        ],
        'amenities': ['Wifi', 'Máy giặt', 'Máy lạnh', 'View sông Hàn', 'Gym'],
        'description':
            'Studio hiện đại nằm sát đường Bạch Đằng, tầm nhìn panorama ngắm trọn vẹn cầu Rồng và sông Hàn thơ mộng.',
        'latitude': 16.0757, // Khu vực đường Bạch Đằng, Hải Châu
        'longitude': 108.2238,
        'city': 'Đà Nẵng',
        'district': 'Hải Châu',
      },
      {
        'id': 'p5',
        'title': 'My Khe Beachfront Boutique Hotel',
        'location': 'Sơn Trà, Đà Nẵng',
        'pricePerNight': 1350000.0,
        'rating': 4.6,
        'reviewsCount': 112,
        'hostName': 'Hoàng Nam',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'
        ],
        'amenities': [
          'Wifi',
          'Ăn sáng',
          'Máy lạnh',
          'Sát bãi tắm',
          'Bar tầng mái'
        ],
        'description':
            'Khách sạn phong cách Boutique trẻ trung nằm trên đường Võ Nguyên Giáp, đối diện bãi tắm Phạm Văn Đồng sầm uất.',
        'latitude': 16.0622, // Khu vực Võ Nguyên Giáp, Sơn Trà
        'longitude': 108.2461,
        'city': 'Đà Nẵng',
        'district': 'Sơn Trà',
      },
      {
        'id': 'p6',
        'title': 'An Thượng Cozy Stay',
        'location': 'Ngũ Hành Sơn, Đà Nẵng',
        'pricePerNight': 950000.0,
        'rating': 4.5,
        'reviewsCount': 54,
        'hostName': 'Phương Thảo',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ'
        ],
        'amenities': [
          'Wifi',
          'Bếp chung',
          'Máy lạnh',
          'Thuê xe máy',
          'Gần phố Tây'
        ],
        'description':
            'Căn hộ dịch vụ ấm cúng nằm ngay trung tâm khu phố Tây An Thượng, cách biển Mỹ Khê chỉ 3 phút đi bộ.',
        'latitude': 16.0505, // Khu phố du lịch An Thượng, Ngũ Hành Sơn
        'longitude': 108.2445,
        'city': 'Đà Nẵng',
        'district': 'Ngũ Hành Sơn',
      },
      {
        'id': 'p7',
        'title': 'Dragon Bridge Riverside House',
        'location': 'Sơn Trà, Đà Nẵng',
        'pricePerNight': 1600000.0,
        'rating': 4.8,
        'reviewsCount': 73,
        'hostName': 'Quốc Bảo',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'
        ],
        'amenities': [
          'Wifi',
          'Bếp riêng',
          'Máy lạnh',
          'Ban công',
          'View cầu Rồng'
        ],
        'description':
            'Nhà nguyên căn tọa lạc trên đường Trần Hưng Đạo, vị trí đắc địa để ngắm Cầu Rồng phun lửa và nước vào cuối tuần.',
        'latitude': 16.0682, // Đường Trần Hưng Đạo sát Sông Hàn, Sơn Trà
        'longitude': 108.2325,
        'city': 'Đà Nẵng',
        'district': 'Sơn Trà',
      },
      {
        'id': 'p8',
        'title': 'Hoa Xuan Green Villa',
        'location': 'Cẩm Lệ, Đà Nẵng',
        'pricePerNight': 2200000.0,
        'rating': 4.7,
        'reviewsCount': 29,
        'hostName': 'Minh Khôi',
        'hostAvatar':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'
        ],
        'amenities': [
          'Wifi',
          'Hồ bơi riêng',
          'Sân vườn BBQ',
          'Gara ô tô',
          'Máy lạnh'
        ],
        'description':
            'Biệt thự sinh thái yên tĩnh tại khu đô thị Hòa Xuân, không gian rộng rãi thoáng đãng phù hợp cho gia đình nghỉ dưỡng.',
        'latitude': 16.0125, // Khu đô thị đảo sinh thái Hòa Xuân, Cẩm Lệ
        'longitude': 108.2204,
        'city': 'Đà Nẵng',
        'district': 'Cẩm Lệ',
      }
    ];
  }

  static List<Map<String, dynamic>> getMockBookings() {
    return [
      {
        'id': 'b1',
        'property': getMockProperties()[0],
        'checkIn': '2026-10-12T14:00:00Z',
        'checkOut': '2026-10-15T12:00:00Z',
        'guests': 2,
        'totalPrice': 5550000.0,
        'status': 'Sắp đi',
      },
      {
        'id': 'b2',
        'property': getMockProperties()[1],
        'checkIn': '2026-08-05T14:00:00Z',
        'checkOut': '2026-08-08T12:00:00Z',
        'guests': 4,
        'totalPrice': 4500000.0,
        'status': 'Đã hoàn thành',
      }
    ];
  }

  static List<Map<String, dynamic>> getMockMessages() {
    return [
      {
        'id': 'm1',
        'senderId': 'host1',
        'receiverId': 'u1',
        'content':
            'Chào bạn! Tôi là Lâm. Cảm ơn bạn đã đặt phòng. Tôi có thể giúp gì cho bạn không?',
        'timestamp': '2026-06-16T14:20:00Z',
        'isRead': true,
      },
      {
        'id': 'm2',
        'senderId': 'u1',
        'receiverId': 'host1',
        'content':
            'Chào Lâm, mình muốn hỏi nhà mình có thể nhận phòng sớm được không ạ?',
        'timestamp': '2026-06-16T14:22:00Z',
        'isRead': true,
      }
    ];
  }
}
