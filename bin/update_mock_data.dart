import 'dart:io';

void main() {
  final file = File('lib/data/datasources/mock_data.dart');
  var content = file.readAsStringSync();

  // Replace imageUrls arrays with rich Unsplash images
  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',\n          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',\n          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2'\n        ],");

  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2',\n          'https://images.unsplash.com/photo-1497366216548-37526070297c',\n          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd'\n        ],");

  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1510798831971-661eb04b3739',\n          'https://images.unsplash.com/photo-1449156001437-3a16c1dfbe2c',\n          'https://images.unsplash.com/photo-1518780664697-55e3ad937233'\n        ],");
      
  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',\n          'https://images.unsplash.com/photo-1505691938895-1758d7feb511',\n          'https://images.unsplash.com/photo-1484154218962-a197022b5858'\n        ],");

  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',\n          'https://images.unsplash.com/photo-1566073771259-6a8506099945',\n          'https://images.unsplash.com/photo-1551882547-ff40c0d13c05'\n        ],");

  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1505843513577-22bb7d21e455',\n          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af',\n          'https://images.unsplash.com/photo-1494526585095-c1b704648c5f'\n        ],");

  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1493809842364-78817add7ffb',\n          'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6',\n          'https://images.unsplash.com/photo-1481253127861-534498168948'\n        ],");

  content = content.replaceFirst(
      "        'imageUrls': [\n          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc'\n        ],",
      "        'imageUrls': [\n          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914',\n          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',\n          'https://images.unsplash.com/photo-1510798831971-661eb04b3739'\n        ],");

  file.writeAsStringSync(content);
}
