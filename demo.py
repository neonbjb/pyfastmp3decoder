from pyfastmp3decoder.mp3decoder import load_mp3
from time import time
from tqdm import tqdm
import librosa

if __name__ == '__main__':
    from tqdm import tqdm  # Not in requirements.txt

    # Demonstrates the decoding speed differences between librosa and this library.
    file = 'testdata/test.mp3'
    start = time()
    for k in tqdm(list(range(100))):
        pcm, sr = load_mp3(file)
    print(f'tinymp3 elapsed: {time( ) -start}')

    start = time()
    for k in tqdm(list(range(100))):
        pcm, sr = librosa.load(file)
    print(f'librosa elapsed: {time( ) -start}')