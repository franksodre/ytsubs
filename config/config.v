module config
import os

pub const workdir = os.getwd()
pub const separator = "/"

pub const save_dir = workdir + separator + "save/"
pub const save_formatted = workdir + separator + "save/%(title)s.%(ext)s"
pub const port = 8080

pub const metafile = workdir + separator + "metafile.json"
pub const cookies = workdir + "/assets/cookies.txt"
pub const ytdlp_bin = workdir + "/bin/yt-dlp"
