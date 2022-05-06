"""AutoBridge"""

from setuptools import find_packages, setup

with open('README.md', encoding='utf-8') as f:
  long_description = f.read()

setup(
    name='autobridge',
    version='0.0.20220506.dev1',
    description='AutoBridge',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/Licheng-Guo/AutoBridge',
    author='Licheng Guo',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Topic :: System :: Hardware',
    ],
    packages=find_packages(),
    python_requires='>=3.6',
    install_requires=[
        'mip',
        'pyverilog',
        'prettytable',
    ],
    entry_points={
        'console_scripts': [],
    },
)
