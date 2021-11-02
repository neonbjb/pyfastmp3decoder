from time import time

import librosa
from ._backend import load_frame
import numpy


def load_mp3(path, sample_rate=None, return_sr=True, return_stats=False):
    """
    Decodes the MP3 file at path, returning the decoded file as a numpy float array as well as some extraneous data
    if requested (see params). Shape of output is (channels,pcm_length).

    :param path: MP3 file path.
    :param sample_rate: If specified, the returned data will be resampled to this sample rate.
    :param return_sr: If true, sample rate is returned alongside audio data. True by default to mirror librosa API.
    :param return_stats: If true, sample rate, channels and bitrate are returned alongside audio data. Mutually exclusive with return_sr.
    """
    with open(path, 'rb') as f:
        hz, chans, bitrate = 0,0,0
        data = []
        while True:
            pcm, h, c, b = load_frame(f)
            if len(pcm) == 0:
                break
            else:
                hz = h
                chans = c
                bitrate = b
            data.extend(pcm)

        np_pcm = numpy.asarray(data, dtype=float) / 32767
        if chans > 1:
            np_pcm = numpy.reshape(np_pcm, (np_pcm.shape[0]//chans, chans))
            np_pcm = numpy.transpose(np_pcm, (1,0))
        if sample_rate is not None and sample_rate != hz:
            np_pcm = librosa.resample(np_pcm, hz, sample_rate)
            hz = sample_rate
        if return_sr:
            return np_pcm, hz
        elif return_stats:
            return np_pcm, hz, chans, bitrate
        return np_pcm
