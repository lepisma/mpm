from setuptools import find_packages, setup

with open("README.rst") as readme_file:
    readme = readme_file.read()

project_url = "https://github.com/"
project_url += "lepisma/mpm"

setup(
    name="mpm",
    version="0.1.0",
    description="Music package manager",
    long_description=readme,
    author="Abhinav Tushar",
    author_email="abhinav.tushar.vs@gmail.com",
    url=project_url,
    install_requires=[
        "docopt",
        "clint",
        "mediafile",
        "youtube_dl",
        "pyyaml",
        "tinydb"
    ],
    keywords="",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "mpm=mpm.command:cli"
        ]
    },
    classifiers=(
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Natural Language :: English",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3 :: Only"
    ))
