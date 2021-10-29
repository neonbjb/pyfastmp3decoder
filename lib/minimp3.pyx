"""
Wrappers for the minimp3 library
"""
from array import array

from libc.string cimport memcpy
from cpython cimport array


cdef extern from *:
    """
    /* In order to get the minimp3 symbols to build, we must define the
     * MINIMP3_IMPLEMENTATION macro.
     */
    #define MINIMP3_IMPLEMENTATION
    """

cdef extern from "minimp3.h":

    ctypedef struct mp3dec_frame_info_t:
        int frame_bytes
        int channels
        int hz
        int layer
        int bitrate_kbps


    ctypedef struct mp3dec_t:
        float mdct_overlap[1][1]
        float qmf_state[1]
        int reserv
        int free_format_bytes
        unsigned char header[1]
        unsigned char reserv_buf[1]

    cdef const size_t MINIMP3_MAX_SAMPLES_PER_FRAME

    void mp3dec_init(mp3dec_t* dec)

    int mp3dec_decode_frame(mp3dec_t* dec, unsigned char* mp3, int mp3_bytes, short* pcm, mp3dec_frame_info_t* info)


# Initialize the decoder structure
cdef mp3dec_t MP3_DECODER
mp3dec_init(&MP3_DECODER)

cdef size_t MAX_BUFFER_SIZE = MINIMP3_MAX_SAMPLES_PER_FRAME * 100

cdef int decode_frame(unsigned char* buffer, int mp3_size,
                      short *pcm,
                      mp3dec_frame_info_t* frame_info) except -1:
    """
    Attempt to decode a single frame

    The operation may fail if insufficient data are available to read a frame,
    when this happens, the function will either raise InsufficientData (in the
    event that a frame is either not done being read, or some data has been
    skipped), or InvalidData, in the event of another type of error.
    """
    cdef int samples = mp3dec_decode_frame(&MP3_DECODER,
                                           buffer,
                                           mp3_size,
                                           pcm,
                                           frame_info)

    if frame_info.frame_bytes:
        if not samples:
            raise InsufficientData("Decoder skipped ID3 or invalid data")
    else:
        raise InvalidDataError("No data read into frame")

    return samples


cdef size_t refill_buffer(mp3_fobj, array.array buffer, size_t buf_size):
    """
    Load more data into the buffer array
    """
    cdef int old_buffer_len = len(buffer)
    cdef int bytes_read = buf_size

    try:
        buffer.fromfile(mp3_fobj, buf_size)
    except EOFError:
        bytes_read = len(buffer) - old_buffer_len

    return bytes_read


cpdef load_frame(mp3_fobj, size_t buf_size=MINIMP3_MAX_SAMPLES_PER_FRAME):
    """
    Load a single frame from the file-like ``mp3_fobj``

    ``mp3_fobj`` will be read in chunks of size ``buf_size`` and decoded until
    a full frame has been populated, at which point the function returns an
    an array of `short` containing the frame data.
    """
    cdef mp3dec_frame_info_t frame_info

    # Buffers
    cdef array.array pcm = array.array('h')
    cdef array.array buffer = array.array('B')

    cdef size_t pos = mp3_fobj.tell()
    cdef size_t samples = 0
    cdef size_t mp3_size = 0

    while True:
        mp3_size = refill_buffer(mp3_fobj, buffer, buf_size)
        if mp3_size == 0:
            return array.array('h'), 0, 0, 0

        try:
            array.resize(pcm, MINIMP3_MAX_SAMPLES_PER_FRAME)
            bufferData = buffer.data.as_uchars[0:mp3_size]
            samples = decode_frame(bufferData, mp3_size,
                                   pcm.data.as_shorts,
                                   &frame_info)
        except InsufficientData:
            pass
        except InvalidDataError:
            mp3_fobj.seek(pos)
        else:
            break
        finally:
            pos += frame_info.frame_bytes

    cdef size_t num_vals
    if samples:
        num_vals = frame_info.channels * samples
        pcm = pcm[0:num_vals]

    mp3_fobj.seek(pos)
    return pcm, frame_info.hz, frame_info.channels, frame_info.bitrate_kbps


class InsufficientData(ValueError):
    pass

class InvalidDataError(ValueError):
    pass
