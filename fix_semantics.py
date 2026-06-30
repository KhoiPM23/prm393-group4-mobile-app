import os

map_path = r"d:\Workspace\FPTU_documents\Ky_8_SU26\PRM393\Mobile_Project\prm393-group4-mobile-app\lib\presentation\module_3_map\explore_map_screen.dart"
intro_path = r"d:\Workspace\FPTU_documents\Ky_8_SU26\PRM393\Mobile_Project\prm393-group4-mobile-app\lib\presentation\module_3_map\explore_map_intro_screen.dart"

# Fix Map Screen
with open(map_path, "r", encoding="utf-8") as f:
    map_content = f.read()

if "ExcludeSemantics(" not in map_content:
    map_content = map_content.replace(
        "child: FlutterMap(",
        "child: ExcludeSemantics(child: FlutterMap("
    )
    # add the closing bracket for ExcludeSemantics
    map_content = map_content.replace(
        "userAgentPackageName: 'com.vibelocals.app'),",
        "userAgentPackageName: 'com.vibelocals.app'),"
    )
    # Wait, the closing bracket for FlutterMap is at the end of the children list
    # The children list ends with `],`
    # Let's just do a regex replace or manual string replace
    old_flutter_map = """            Positioned.fill(
              child: FlutterMap("""
    new_flutter_map = """            Positioned.fill(
              child: ExcludeSemantics(
                child: FlutterMap("""
    map_content = map_content.replace(old_flutter_map, new_flutter_map)
    
    old_flutter_map_end = """                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. CÁC THÀNH PHẦN KHÁC NẰM ĐÈ LÊN TRÊN (OVERLAYS)"""
    new_flutter_map_end = """                      );
                    },
                  ),
                ],
              ),
              ),
            ),

            // 2. CÁC THÀNH PHẦN KHÁC NẰM ĐÈ LÊN TRÊN (OVERLAYS)"""
    map_content = map_content.replace(old_flutter_map_end, new_flutter_map_end)
    
    with open(map_path, "w", encoding="utf-8") as f:
        f.write(map_content)

# Fix Intro Screen
with open(intro_path, "r", encoding="utf-8") as f:
    intro_content = f.read()

old_calendar = "initialSelectedRange: PickerDateRange(_selectedDateRange?.start, _selectedDateRange?.end),"
if old_calendar in intro_content:
    intro_content = intro_content.replace(old_calendar, "")
    with open(intro_path, "w", encoding="utf-8") as f:
        f.write(intro_content)
    
print("Semantics fixed successfully.")
