# NOTE: Also published as under MIT license as
# https://gist.github.com/oseiskar/ce37d53f26d9e6dabb5ceeb67f807c16
"""
Look into a directory with shared libraries using Linux SO_VERSION suffixes
e.g., libfoo.so.1.2 and remove them -> libfoo.so, by renaming files and
modifying the DT_SONAME fiels in the ELF binaries.

NOTE: This should (obviously) be done before compiling libraries OR executables
that link to the libraries in the target directory. Existing libraries or
executables that may link to these shared libraries are not modified to use the
shortened SONAMEs, even if those dependent libraries are in the target folder.

NOTE: This may require the publication of this Python script under LGPL if
used on LGPL-licensed libraries.
"""
import itertools
import os
import sys
import struct

def shorten_soname(so_filename, short_name=None, dryrun=False):
    """
    Replace the DT_SONAME field stored in the given ELF file with "short_name"
    (e.g., libfoo.so) which is assumed to be a prefix of the soname found in
    the file (e.g., libfoo.so.1)

    This works with ARM ELFs too but cuts some corners (directly find the
    SONAME string from SHT_STRTAB instead of looking up its true index from
    the .dynamic section.
    """
    # see, e.g., http://www.sco.com/developers/devspecs/gabi41.pdf
    # or https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
    # for descriptions of the ELF format
    #
    # There also exists an utility called "patchelf" with can do the same
    # thing with the --set-soname option, but, at the time of writing, it
    # does not support ARM binaries

    log = lambda x: sys.stdout.write(\
        {False: '', True: 'DRYRUN '}[dryrun] + \
        so_filename + ': ' + str(x) + '\n')

    def fail(msg):
        raise RuntimeError(so_filename + ' is not a valid ELF shared object file: ' + msg)

    if short_name is None:
        short_name = os.path.basename(so_filename).partition('.so')[0] + '.so'

    if dryrun:
        openmode = 'rb'
    else:
        openmode = 'rb+'
    with open(so_filename, openmode) as f:
        if f.read(4) != b'\x7fELF': fail('invalid magic number')
        byte = f.read(1)

        if byte == b'\x01':
            # 32 bit
            section_header_offset = 0x20
            word_size = 4
            read_word = lambda: struct.unpack('<I', f.read(word_size))[0]
        elif byte == b'\x02':
            # 64 bit
            section_header_offset = 0x28
            word_size = 8
            read_word = lambda: struct.unpack('<Q', f.read(word_size))[0]
        else: fail('invalid class ' + str(byte))

        if f.read(1) != b'\x01': fail('unsupported endianess')
        read_uint32 = lambda: struct.unpack('<I', f.read(4))[0]
        read_uint16 = lambda: struct.unpack('<H', f.read(2))[0]

        f.seek(section_header_offset)
        e_shoff = read_word()
        f.read(10) # skip
        e_shentsize = read_uint16()
        e_shnum = read_uint16()

        f.seek(e_shoff)
        for i in range(e_shnum):
            f.read(4) # skip name
            sh_type = read_uint32()
            if sh_type == 0x3: # SHT_STRTAB
                read_word() # skip flags
                read_word() # skip addr
                strtab_offset = read_word()
                strtab_size = read_word()
                break
            f.read(e_shentsize - 8) # skip
        else:
            fail('no string table found')

        f.seek(strtab_offset)

        def check_end():
            if f.tell() > strtab_offset + strtab_size:
                fail('read past the end of SHT_STRTAB')

        def bytes_to_str(s):
            bs = b''.join(s)
            try:
                return str(bs, encoding='ascii') # Python 3
            except:
                return str(bs) # Python 2

        # cutting some corners here: should read the actual offset of
        # the soname from the ".dynamic" table instead of guessing which
        # string it is
        def find_soname():
            while True:
                s = []
                b = f.read(1)
                string = ''
                while b != b'\x00': # O(n^2) search, should be fine
                    check_end()
                    s.append(b)
                    string = bytes_to_str(s)
                    if string.startswith(short_name):
                        return True
                    b = f.read(1)
                # print('skipping ' + string)

        find_soname()
        soname_end = f.tell()
        # print('found soname at offset %d' % soname_end)
        b = f.read(1)
        rest = []
        while b != b'\x00':
            check_end()
            rest.append(b)
            b = f.read(1)
        nulls = b'\x00'*len(rest)
        log('replacing "' + bytes_to_str(rest) + \
            '" at %d with %d null bytes' % (soname_end, len(nulls)))

        f.seek(soname_end)
        if not dryrun: f.write(nulls)

def shorten_sonames_in_folder(target_folder, dryrun=False):
    log = lambda x: sys.stdout.write({False: '', True: 'DRYRUN '}[dryrun] + str(x) + '\n')
    so_files = [f for f in os.listdir(target_folder) if '.so' in f]
    get_libname = lambda x: x.partition('.')[0]
    for libname, files in itertools.groupby(sorted(so_files), get_libname):
        files = list(files)
        root_name = files[0]
        if len(files) == 1:
            log(root_name + ' is OK, no suffix')
            continue
        actual_libfile = os.path.join(target_folder, files[-1])

        for f in files[:-1]:
            path = os.path.join(target_folder, f)
            log('removing ' + path)
            if not dryrun: os.remove(path)

        shorten_soname(actual_libfile, root_name, dryrun)
        target_name = os.path.join(target_folder, root_name)
        log('renaming %s -> %s' % (actual_libfile, target_name))
        if not dryrun: os.rename(actual_libfile, target_name)

if __name__ == '__main__':
    import argparse
    p = argparse.ArgumentParser(__doc__)
    p.add_argument('target',
        help='Target file or folder, modified in-place unless --dryrun is given')
    p.add_argument('--dryrun', action='store_true',
        help='Dry-run mode: Test modifications without writing anything')
    args = p.parse_args()
    if os.path.isdir(args.target):
        shorten_sonames_in_folder(args.target, dryrun=args.dryrun)
    else:
        shorten_soname(args.target, dryrun=args.dryrun)
