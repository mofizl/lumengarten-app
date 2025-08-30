#!/usr/bin/env python3
"""
Sprite Sheet Extractor for Lumengarten Labyrinth Game
Extracts individual sprites from sprite sheets for use in Flutter/Flame
"""

from PIL import Image
import os

def create_directory_if_not_exists(path):
    """Create directory if it doesn't exist"""
    if not os.path.exists(path):
        os.makedirs(path)
        print(f"Created directory: {path}")

def extract_crystals():
    """Extract crystals from crystals_spritesheet.png"""
    print("Extracting crystals...")
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/crystals/crystals_spritesheet.png"
    output_dir = "lumengarten_app/assets/images/games/labyrinth/crystals/individual/"
    
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
    
    create_directory_if_not_exists(output_dir)
    
    img = Image.open(sprite_path)
    cols, rows = 6, 6
    crystal_width = img.width // cols
    crystal_height = img.height // rows
    
    # Crystal mapping based on sprite sheet analysis
    crystal_types = ['pyramid', 'sphere', 'cube', 'hexagon']
    crystal_colors = ['amethyst', 'emerald', 'sapphire', 'amber']
    
    extracted_count = 0
    
    for row in range(min(4, rows)):  # Only first 4 rows (main crystals)
        for col in range(min(4, cols)):  # Only first 4 cols (main types)
            left = col * crystal_width
            top = row * crystal_height
            right = left + crystal_width
            bottom = top + crystal_height
            
            crystal = img.crop((left, top, right, bottom))
            
            color = crystal_colors[row]
            crystal_type = crystal_types[col]
            state = 'glowing' if (col + row) % 2 == 1 else 'dormant'
            filename = f"crystal_{color}_{crystal_type}_{state}.png"
            
            output_path = os.path.join(output_dir, filename)
            crystal.save(output_path, "PNG")
            print(f"  Saved: {filename}")
            extracted_count += 1
    
    print(f"Extracted {extracted_count} crystal sprites")

def extract_flowers():
    """Extract flowers from flowers_spritesheet.png"""
    print("Extracting flowers...")
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/flowers/flowers_spritesheet.png"
    output_dir = "lumengarten_app/assets/images/games/labyrinth/flowers/individual/"
    
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
    
    create_directory_if_not_exists(output_dir)
    
    img = Image.open(sprite_path)
    cols, rows = 2, 6
    flower_width = img.width // cols
    flower_height = img.height // rows
    
    flower_colors = ['red', 'orange', 'green', 'yellow', 'blue', 'purple']
    flower_states = ['closed', 'bloomed']
    
    extracted_count = 0
    
    for row in range(rows):
        for col in range(cols):
            left = col * flower_width
            top = row * flower_height
            right = left + flower_width
            bottom = top + flower_height
            
            flower = img.crop((left, top, right, bottom))
            
            color = flower_colors[row]
            state = flower_states[col]
            filename = f"flower_{color}_{state}.png"
            
            output_path = os.path.join(output_dir, filename)
            flower.save(output_path, "PNG")
            print(f"  Saved: {filename}")
            extracted_count += 1
    
    print(f"Extracted {extracted_count} flower sprites")

def extract_hedges():
    """Extract hedge tiles from hedge_style_sprite_sheet.png"""
    print("Extracting hedge tiles...")
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/tiles/hedge_style_sprite_sheet.png"
    output_dir = "lumengarten_app/assets/images/games/labyrinth/tiles/individual/"
    
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
    
    create_directory_if_not_exists(output_dir)
    
    img = Image.open(sprite_path)
    cols, rows = 6, 6
    tile_width = img.width // cols
    tile_height = img.height // rows
    
    seasons = ['spring', 'summer', 'late_summer', 'early_autumn', 'autumn', 'winter']
    tile_types = ['straight', 'corner', 't_junction', 'crossroads', 'path', 'dead_end']
    
    extracted_count = 0
    
    for row in range(min(6, rows)):
        for col in range(cols):
            left = col * tile_width
            top = row * tile_height
            right = left + tile_width
            bottom = top + tile_height
            
            tile = img.crop((left, top, right, bottom))
            
            season = seasons[row]
            tile_type = tile_types[col]
            filename = f"hedge_{season}_{tile_type}.png"
            
            output_path = os.path.join(output_dir, filename)
            tile.save(output_path, "PNG")
            print(f"  Saved: {filename}")
            extracted_count += 1
    
    print(f"Extracted {extracted_count} hedge sprites")

def extract_portals():
    """Extract portals from portalset_spritesheet.png"""
    print("Extracting portals...")
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/portalset_spritesheet.png"
    output_dir = "lumengarten_app/assets/images/games/labyrinth/portals/individual/"
    
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
    
    create_directory_if_not_exists(output_dir)
    
    img = Image.open(sprite_path)
    cols, rows = 2, 5
    portal_width = img.width // cols
    portal_height = img.height // rows
    
    portal_names = [
        ['portal_spring', 'portal_summer'],
        ['portal_summer_warm', 'portal_autumn_cool'],
        ['portal_autumn_warm', 'portal_autumn_cool'],
        ['portal_late_autumn', 'portal_winter'],
        ['portal_winter_alt1', 'portal_winter_alt2']
    ]
    
    extracted_count = 0
    
    for row in range(rows):
        for col in range(cols):
            left = col * portal_width
            top = row * portal_height
            right = left + portal_width
            bottom = top + portal_height
            
            portal = img.crop((left, top, right, bottom))
            
            filename = f"{portal_names[row][col]}.png"
            
            output_path = os.path.join(output_dir, filename)
            portal.save(output_path, "PNG")
            print(f"  Saved: {filename}")
            extracted_count += 1
    
    print(f"Extracted {extracted_count} portal sprites")

def extract_backgrounds():
    """Extract garden backgrounds from garten hintergrund_spritesheet.png"""
    print("Extracting garden backgrounds...")
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/garten hintergrund_spritesheet.png"
    output_dir = "lumengarten_app/assets/images/games/labyrinth/backgrounds/individual/"
    
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
    
    create_directory_if_not_exists(output_dir)
    
    img = Image.open(sprite_path)
    cols, rows = 4, 3
    bg_width = img.width // cols
    bg_height = img.height // rows
    
    background_names = [
        ['platform_basic', 'platform_crystals', 'platform_stairs', 'waterfall_left'],
        ['waterfall_pool', 'waterfall_magical', 'magic_tree', 'big_tree'],
        ['grass_mound', 'rainbow', 'magic_light', 'ancient_tree']
    ]
    
    extracted_count = 0
    
    for row in range(rows):
        for col in range(cols):
            left = col * bg_width
            top = row * bg_height
            right = left + bg_width
            bottom = top + bg_height
            
            background = img.crop((left, top, right, bottom))
            
            filename = f"bg_{background_names[row][col]}.png"
            
            output_path = os.path.join(output_dir, filename)
            background.save(output_path, "PNG")
            print(f"  Saved: {filename}")
            extracted_count += 1
    
    print(f"Extracted {extracted_count} background sprites")

def main():
    """Main extraction process"""
    print("Starting Sprite Extraction for Dunkis Labyrinth...")
    print("=" * 50)
    
    try:
        extract_crystals()
        print()
        extract_flowers()
        print()
        extract_hedges()
        print()
        extract_portals()
        print()
        extract_backgrounds()
        
        print("=" * 50)
        print("All sprites extracted successfully!")
        print("Ready for Flame Engine integration!")
        
    except Exception as e:
        print(f"Error during extraction: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()