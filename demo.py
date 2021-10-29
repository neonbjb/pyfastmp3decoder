from pyfastmp3decoder.mp3decoder import load_mp3
import librosa
import numpy
import soundfile
from time import time
from tqdm import tqdm

if __name__ == '__main__':
    from tqdm import tqdm  # Not in requirements.txt

    # Demonstrates the decoding speed differences between librosa and this library.
    file = 'testdata/test_stereo.mp3'
    start = time()
    for k in tqdm(list(range(50))):
        pcm, sr = load_mp3(file, 11000)
    soundfile.write('demo_out.wav', numpy.transpose(pcm, (1,0)), sr)
    print(f'tinymp3 elapsed: {time() -start}')

    start = time()
    for k in tqdm(list(range(50))):
        pcm, sr = librosa.load(file)
    print(f'librosa elapsed: {time() -start}')