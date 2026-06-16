class MockData {
  static List<Map<String, dynamic>> getMockUsers() {
    return [
      {
        'id': 'u1',
        'name': 'Phan Minh Khôi',
        'email': 'khoi.phan@email.com',
        'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
      }
    ];
  }

  static List<Map<String, dynamic>> getMockProperties() {
    return [
      {
        'id': 'p1',
        'title': 'Pine Mist Cabin',
        'location': 'Đà Lạt',
        'pricePerNight': 1850000.0,
        'rating': 4.9,
        'reviewsCount': 128,
        'hostName': 'Minh Khôi',
        'hostAvatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc',
        ],
        'amenities': ['Wifi', 'Bếp', 'Máy sưởi', 'Chỗ đậu xe'],
        'description': 'Một cabin ấm cúng giữa rừng thông Đà Lạt, nơi bạn có thể thư giãn và tận hưởng không khí trong lành. Nội thất gỗ sang trọng mang đến cảm giác gần gũi với thiên nhiên.',
      },
      {
        'id': 'p2',
        'title': 'Villa Hội An Heritage',
        'location': 'Hội An',
        'pricePerNight': 1500000.0,
        'rating': 4.8,
        'reviewsCount': 96,
        'hostName': 'Lâm Nguyễn',
        'hostAvatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
        'imageUrls': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ',
        ],
        'amenities': ['Hồ bơi', 'Ăn sáng', 'Máy lạnh', 'Sân vườn'],
        'description': 'Trải nghiệm không gian hoài cổ nhưng đầy đủ tiện nghi hiện đại tại lòng phố cổ Hội An.',
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
        'content': 'Chào bạn! Tôi là Lâm. Cảm ơn bạn đã đặt phòng. Tôi có thể giúp gì cho bạn không?',
        'timestamp': '2026-06-16T14:20:00Z',
        'isRead': true,
      },
      {
        'id': 'm2',
        'senderId': 'u1',
        'receiverId': 'host1',
        'content': 'Chào Lâm, mình muốn hỏi nhà mình có thể nhận phòng sớm được không ạ?',
        'timestamp': '2026-06-16T14:22:00Z',
        'isRead': true,
      }
    ];
  }
}
