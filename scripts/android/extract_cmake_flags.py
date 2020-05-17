"""
Convert CMake flags to plain compiler options (not pretty)
"""
import os, shutil, subprocess, sys, tempfile
from os.path import join

def write_file(name, s):
    with open(name, 'wt') as f:
        f.write(s)

def read_file(name):
    with open(name) as f: return f.read()

work = tempfile.mkdtemp()

write_file(join(work, 'CMakeLists.txt'), 'add_library(dummy __A__.c __B__.cpp)\n')
write_file(join(work, '__A__.c'), 'void main() {}\n')
write_file(join(work, '__B__.cpp'), 'void main() {}\n')
subprocess.check_output('cd "%s" && cmake %s .' % (work, os.environ['CMAKE_FLAGS'].replace('\n', ' ')), shell=True)

makefile = read_file(join(work, 'CMakeFiles', 'dummy.dir', 'build.make'))
flagfile = read_file(join(work, 'CMakeFiles', 'dummy.dir', 'flags.make'))
linkfile = read_file(join(work, 'CMakeFiles', 'dummy.dir', 'link.txt'))

flag_vars = {}
#flag_vars['AR'] = linkfile.split('\n')[0].split()[0]
flag_vars['RANLIB'] = linkfile.split('\n')[1].split()[0]
bindir = os.path.dirname(flag_vars['RANLIB'])
ranlib_arch = os.path.basename(flag_vars['RANLIB']).split('-ranlib')[0]

for line in flagfile.split('\n'):
    line = line.strip()
    if len(line) > 0 and line[0] != '#':
        key, _, value = line.partition(' =')
        value = value.strip()
        if len(value) > 0: flag_vars[key] = value

for line in makefile.split('\n'):
    line = line.strip()
    for flagsname, ccname, tag in [('C_FLAGS', 'CC', '__.c.o'), ('CXX_FLAGS', 'CXX', '__.cpp.o')]:
        if 'bin/clang' in line and tag in line:
            clang = line.split()[0]
            flags = line.partition(' -o ')[0].partition(' ')[-1]
            flags = flags.partition('$(')[0]
            flag_vars[flagsname] = (flag_vars.get(flagsname, '') + ' ' + flags.strip()).strip()
            flag_vars[ccname] = clang

# for some reason, the binaries that seem to work in CMake do not work
# with normal Make
#sys.stderr.write(str(flag_vars)+'\n')
arch = {
    'arm-linux-androideabi': 'armv7a-linux-androideabi23', # TODO: fix this mapping
    'aarch64-linux-android': 'aarch64-linux-android23'
}[ranlib_arch]

flag_vars['CC'] = join(bindir, arch + '-clang')
flag_vars['CXX'] = join(bindir, arch + '-clang++')
sysroot = bindir.replace('/bin', '/sysroot')
flag_vars['CPP_INCLUDE_DIR'] = join(sysroot, 'usr/include/c++/v1')

for kv in flag_vars.items():
    print("%s=\"%s\"" % kv)

shutil.rmtree(work)
