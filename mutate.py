import argparse

FILE_PATH = './src/data/cv_data.json'

def toggle_email(fpath: str, x: str, y: str):
    with open(fpath, 'r') as f:
        content = f.read()
    if x in content:
        content = content.replace(x, y)
    elif y in content:
        content = content.replace(y, x)
    else:
        raise ValueError('Neither x nor y found in file')
    with open(fpath, 'w') as f:
        f.write(content)

def main():
    parser = argparse.ArgumentParser(description='Toggle email in a file.')
    parser.add_argument('x', type=str, help='First email to toggle.')
    parser.add_argument('y', type=str, help='Second email to toggle.')
    parser.add_argument('--fpath', type=str, default=FILE_PATH, help='Path to the file. Defaults to ./src/data/cv_data.json')
    args = parser.parse_args()
    toggle_email(args.fpath, args.x, args.y)

if __name__ == "__main__":
    main()