# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['nord_nm_gui.py'],
             pathex=['.'],
             binaries=[],
             datas=[('nordvpnicon.png', '.'), ('nord-logo.png', '.')],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='nord_nm_gui',
          debug='all',
          bootloader_ignore_signals=False,
          strip=False,
          upx=False,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=True )
