## pyfastmp3decoder: A fast MP3 decoder for python, using minimp3

This project builds upon https://github.com/pyminimp3/pyminimp3 by fixing several bugs which
make the latter repo unusable (thanks to an investigation by newdive@ for this). It also wraps
the library in an API that mirrors the librosa API for loading MP3 files.

On my system, this library loads MP3 files 4x faster than librosa or other libraries which
use the FFMPEG backend. Smaller files see even greater speed boosts.

## Installation

```
pip install cython
git clone https://github.com/neonbjb/pyfastmp3decoder.git
cd pyfastmp3decoder
git submodule update --init --recursive
python setup.py install
```

## Demo

See demo.py.

`python demo.py`

## License

This project is licensed under the Apache Software License 2.0.
