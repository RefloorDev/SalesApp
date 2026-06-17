import os

def modify_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = content
    for target, replacement in replacements:
        if target in modified:
            modified = modified.replace(target, replacement)
            print(f"Replaced target in {filepath}")
        else:
            print(f"Warning: target not found in {filepath}: {target}")
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(modified)

main_storyboard = "/Users/bincycaliyar/Desktop/Project/Refloor Kavya 3.3.7/SalesApp/Refloor/StoryBoard/Base.lproj/Main.storyboard"
main1_storyboard = "/Users/bincycaliyar/Desktop/Project/Refloor Kavya 3.3.7/SalesApp/Refloor/StoryBoard/Base.lproj/Main1.storyboard"

print("Modifying Main.storyboard...")
modify_file(main_storyboard, [
    ('<constraint firstAttribute="width" constant="250" id="9Dl-Do-klR"/>', '<constraint firstAttribute="width" id="9Dl-Do-klR"/>')
])

print("Modifying Main1.storyboard...")
modify_file(main1_storyboard, [
    ('<view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="aRm-ft-T3N">', '<view hidden="YES" contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="aRm-ft-T3N">'),
    ('<constraint firstAttribute="width" constant="250" id="9Dl-Do-klR"/>', '<constraint firstAttribute="width" id="9Dl-Do-klR"/>')
])
