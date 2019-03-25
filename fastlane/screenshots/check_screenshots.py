from pprint import pprint
import os

devices = [
        'iPhone SE',
        'iPhone 8',
        'iPhone 8 Plus',
        'iPhone X',
        'iPhone XS Max',
        ]

screenshots = [
        '10_Wallet',
        '20_History',
        '30_Channels',
        '40_Receive',
        ]

expected = set()

for device in devices:
    for screenshot in screenshots:
        expected.add(f'{device}-{screenshot}.png')
        
print(expected)
subfolders = [f.path for f in os.scandir('.') if f.is_dir() ]

for language in subfolders:
    existing = set([os.path.basename(f.path) for f in os.scandir(language) if f.is_file() and f.path.endswith('.png') ])
    missing = expected.difference(existing)
    additional = existing.difference(expected)

    if missing or additional:
        print(f"\n{language}\n------------------------------------")
        exit_code = 1

    if missing:
        print("⚠️  Missing Screenshots:")
        pprint(missing)

    if additional:
        print("⚠️  Additional Screenshots:")
        pprint(additional)
