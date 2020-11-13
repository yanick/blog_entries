function! FileToPackage()
    call Nvimx_request( 'load_plugin', 'FileToPackageName' )
    call Nvimx_request('file_to_package_name')
endfunction
