from setuptools import setup
from setuptools.extension import Extension

try:
    from Cython.Build import cythonize
except ImportError:
    def cythonize(*args, **kwargs):
        return []


extensions = [
    Extension(
        "pyfastmp3decoder._backend",
        sources=["lib/*.pyx"],
        language="c",
        include_dirs=[
            "lib",
             "minimp3"
        ],
    )
]


setup(
    packages=['pyfastmp3decoder'],
    package_dir={
        'pyfastmp3decoder': './src/pyfastmp3decoder',
    },
    ext_modules=cythonize(extensions),
)
