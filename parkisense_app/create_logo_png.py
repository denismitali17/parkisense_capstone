from PIL import Image, ImageDraw, ImageFont
import os
import math

def create_logo(size):
    # Create image with gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient (simplified as solid colors for compatibility)
    # Light blue to cyan gradient
    for y in range(size):
        r = int(74 + (0 - 74) * y / size)
        g = int(144 + (180 - 144) * y / size)
        b = int(226 + (216 - 226) * y / size)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))
    
    # Draw sound waves (white curves)
    center_x, center_y = size // 2, size // 2
    wave_color = (255, 255, 255, 230)
    stroke_width = max(2, size // 64)
    
    # Draw 4 sound wave curves
    for i in range(4):
        y_offset = -60 * size // 512 + i * 40 * size // 512
        points = []
        step = max(1, 5 * size // 512)  # Ensure step is at least 1
        for x in range(-80 * size // 512, 80 * size // 512, step):
            y = y_offset + 20 * math.sin(x * 0.05) * size // 512
            points.append((center_x + x, center_y + y))
        
        if len(points) > 1:
            draw.line(points, fill=wave_color, width=stroke_width, joint='curve')
    
    # Draw microphone (white)
    mic_width = 60 * size // 512
    mic_height = 100 * size // 512
    mic_x = center_x - mic_width // 2
    mic_y = center_y - mic_height // 2 - 10 * size // 512
    
    # Mic body (rounded rectangle)
    draw.rounded_rectangle(
        [(mic_x, mic_y), (mic_x + mic_width, mic_y + mic_height)],
        radius=mic_width // 2,
        fill=(255, 255, 255, 255)
    )
    
    # Mic stand
    stand_width = 30 * size // 512
    stand_height = 40 * size // 512
    stand_x = center_x - stand_width // 2
    stand_y = mic_y + mic_height
    draw.rectangle([(stand_x, stand_y), (stand_x + stand_width, stand_y + stand_height)], fill=(255, 255, 255, 255))
    
    # Mic base
    base_width = 80 * size // 512
    base_height = 15 * size // 512
    base_x = center_x - base_width // 2
    base_y = stand_y + stand_height
    draw.rounded_rectangle(
        [(base_x, base_y), (base_x + base_width, base_y + base_height)],
        radius=5 * size // 512,
        fill=(255, 255, 255, 255)
    )
    
    # Draw "PS" text
    try:
        # Try to use a system font, fall back to default if not available
        font_size = 80 * size // 512
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            try:
                font = ImageFont.truetype("Arial.ttf", font_size)
            except:
                font = ImageFont.load_default()
        
        text = "PS"
        text_bbox = draw.textbbox((0, 0), text, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
        
        text_x = center_x - text_width // 2
        text_y = center_y + 120 * size // 512
        
        draw.text((text_x, text_y), text, fill=(255, 255, 255, 255), font=font, font_weight='bold')
    except:
        # Fallback: draw simple text without font
        text = "PS"
        text_x = center_x - 20 * size // 512
        text_y = center_y + 120 * size // 512
        draw.text((text_x, text_y), text, fill=(255, 255, 255, 255))
    
    return img

# Define sizes for Android launcher icons
sizes = [
    ("parkisense_app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
    ("parkisense_app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
    ("parkisense_app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
    ("parkisense_app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
    ("parkisense_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
]

# Create directories if they don't exist
for path, size in sizes:
    os.makedirs(os.path.dirname(path), exist_ok=True)

# Create PNG for each size
for path, size in sizes:
    img = create_logo(size)
    img.save(path)
    print(f"Created: {path} ({size}x{size})")

print("All launcher icons created successfully!")
