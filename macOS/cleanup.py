import os
import re
import shutil


home = os.environ['HOME']
rel_log_dir = [
    'Library/Application Support/Code/logs/',
    'Library/Caches/com.crashlytics.data/',
    'Library/Caches/com.plausiblelabs.crashreporter.data/',
    'Library/Developer/CoreSimulator/Caches/dyld/18G103/',
    'Library/Containers/com.netease.163music/Data/Documents/storage/Logs/',
    'Library/Application Support/com.microsoft.rdc.osx.beta/com.microsoft.appcenter/crasheslogbuffer/',
    'Library/Containers/com.netease.163music/Data/Library/Caches/com.crashlytics.data/',
    'Library/Containers/com.netease.163music/Data/Documents/storage/Logs/',
    'Library/Application Support/Code/logs',
    'Library/Application Support/Code/Crashpad'
]


def rm_pattern_files(search_dict: dict):
    for src, patterns in search_dict.items():
        directory = os.path.join(home, src)
        if os.path.exists(directory):
            for root, dirs, files in os.walk(directory):
                for f in files:
                    for p in patterns:
                        if re.match(p, f):
                            full_path = os.path.join(root, f)
                            os.remove(full_path)


search_info = {
    'Library/Caches/com.microsoft.VSCode.ShipIt/': [r".*\.log"],
    'Library/Application Support/Code': [r".*\.log"],
    'Library/Application Support/calibre-ebook.com/calibre': [r".*\.log"],
    'Library/Containers/com.tencent.xinWeChat/Data/Library/Caches/com.tencent.xinWeChat/2.0b4.0.9/log/': [r'.*\.xlog'],
    'Library/Caches/JetBrains': [r'.*\.log']
}

chromium_cache = [
    'Library/Application Support/Code/Cache/',
    'Library/Caches/BraveSoftware/Brave-Browser/',
    'Library/Caches/Microsoft Edge',
    'Library/Caches/Google/Chrome'
]


def main():
    for file in os.listdir('/Library/Logs/DiagnosticReports'):
        if file.endswith('.diag'):
            os.remove(os.path.join('/Library/Logs/DiagnosticReports', file))
    shutil.rmtree('/Library/Logs/Microsoft', ignore_errors=True)
    shutil.rmtree('/Users/prinwis/Library/Caches/Firefox/Profiles/n1ghn2p9.default-release/cache2', ignore_errors=True)

    for i in rel_log_dir:
        full_path = os.path.join(home, i)
        if os.path.exists(full_path):
            shutil.rmtree(os.path.join(home, i), ignore_errors=False)

    for i in chromium_cache:
        search_info[os.path.join(home, i)] = [r'.*_[0-9s]$']

    rm_pattern_files(search_info)


main()
