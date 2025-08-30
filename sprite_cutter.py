"""
Automatic Sprite Sheet Cutter for Lumengarten App
Cuts sprite sheets into individual tiles
"""

from PIL import Image
import os

def cut_crystals_spritesheet():
    """Cut crystals_spritesheet.png into individual crystals"""
    
    # Load the sprite sheet
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/crystals/crystals_spritesheet.png"
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
        
    img = Image.open(sprite_path)
    
    # Crystal grid: 6 columns x 6 rows
    # Each crystal: ~128x128 pixels
    cols, rows = 6, 6
    crystal_width = img.width // cols
    crystal_height = img.height // rows
    
    # Crystal types and colors
    crystal_types = ['pyramid', 'sphere', 'cube', 'hexagon']
    crystal_colors = ['amethyst', 'emerald', 'sapphire', 'amber', 'mixed1', 'mixed2']
    
    for row in range(rows):
        for col in range(cols):
            # Calculate crop box
            left = col * crystal_width
            top = row * crystal_height
            right = left + crystal_width
            bottom = top + crystal_height
            
            # Crop the crystal
            crystal = img.crop((left, top, right, bottom))
            
            # Generate filename
            if row < 4 and col < 4:  # Main crystals
                color = ['amethyst', 'emerald', 'sapphire', 'amber'][row]
                crystal_type = ['pyramid', 'sphere', 'cube', 'hexagon'][col]
                state = 'glowing' if (col + row) % 2 == 1 else 'dormant'
                filename = f"crystal_{color}_{crystal_type}_{state}.png"
            else:
                filename = f"crystal_extra_{row}_{col}.png"
            
            # Save crystal
            output_path = f"lumengarten_app/assets/images/games/labyrinth/crystals/{filename}"
            crystal.save(output_path, "PNG")
            print(f"Saved: {filename}")

def cut_flowers_spritesheet():
    """Cut flowers_spritesheet.png into individual flowers"""
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/flowers/flowers_spritesheet.png"
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
        
    img = Image.open(sprite_path)
    
    # Flower grid: 2 columns x 6 rows
    cols, rows = 2, 6
    flower_width = img.width // cols
    flower_height = img.height // rows
    
    # Flower colors
    flower_colors = ['red', 'orange', 'yellow', 'green', 'blue', 'purple']
    flower_states = ['closed', 'bloomed']
    
    for row in range(rows):
        for col in range(cols):
            # Calculate crop box
            left = col * flower_width
            top = row * flower_height
            right = left + flower_width
            bottom = top + flower_height
            
            # Crop the flower
            flower = img.crop((left, top, right, bottom))
            
            # Generate filename
            color = flower_colors[row]
            state = flower_states[col]
            filename = f"flower_{color}_{state}.png"
            
            # Save flower
            output_path = f"lumengarten_app/assets/images/games/labyrinth/flowers/{filename}"
            flower.save(output_path, "PNG")
            print(f"Saved: {filename}")

def cut_hedge_spritesheet():
    """Cut hedge_style_sprite_sheet.png into individual tiles"""
    
    sprite_path = "lumengarten_app/assets/images/games/labyrinth/tiles/hedge_style_sprite_sheet.png"
    if not os.path.exists(sprite_path):
        print(f"File not found: {sprite_path}")
        return
        
    img = Image.open(sprite_path)
    
    # Hedge grid: 6 columns x 6 rows (seasons + tile types)
    cols, rows = 6, 6
    tile_width = img.width // cols
    tile_height = img.height // rows
    
    # Seasons and tile types
    seasons = ['spring', 'summer', 'autumn', 'winter']
    tile_types = ['straight', 'corner', 't_junction', 'crossroads', 'path', 'dead_end']
    
    for row in range(min(4, rows)):  # Only first 4 rows (seasons)
        for col in range(cols):
            # Calculate crop box
            left = col * tile_width
            top = row * tile_height
            right = left + tile_width
            bottom = top + tile_height
            
            # Crop the tile
            tile = img.crop((left, top, right, bottom))
            
            # Generate filename
            season = seasons[row]
            tile_type = tile_types[col]
            filename = f"hedge_{season}_{tile_type}.png"
            
            # Save tile
            output_path = f"lumengarten_app/assets/images/games/labyrinth/tiles/{filename}"
            tile.save(output_path, "PNG")
            print(f"Saved: {filename}")

if __name__ == "__main__":
    print("Starting sprite sheet cutting...")
    
    try:
        cut_crystals_spritesheet()
        cut_flowers_spritesheet() 
        cut_hedge_spritesheet()
        print("✅ All sprite sheets processed successfully!")
    except Exception as e:
        print(f"❌ Error: {e}")