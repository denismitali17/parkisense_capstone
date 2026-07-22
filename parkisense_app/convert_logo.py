from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM
from PIL import Image
import os

# Read SVG
drawing = svg2rlg("parkisense_app/assets/images/app_logo.svg")

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

# Convert to PNG for each size
for path, size in sizes:
    # Render to PNG
    renderPM.drawToFile(drawing, path, fmt='PNG')
    
    # Resize to exact dimensions
    img = Image.open(path)
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    img.save(path)
    print(f"Created: {path} ({size}x{size})")

print("All launcher icons created successfully!")
